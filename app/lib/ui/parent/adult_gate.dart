import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../data/adult_pin.dart';
import '../../l10n/l10n.dart';

/// Gate dell'area adulta con PIN (docs/adult-gate.md). Non è un consenso
/// genitoriale verificabile: tiene lontano il bambino, nient'altro.
class AdultGate {
  /// Sostituibili nei test.
  static AdultPin pin = AdultPin();
  static Future<bool> Function(String reason) deviceAuth = _localAuth;

  /// Entra nell'area adulta: chiede il PIN (o lo fa creare al primo ingresso).
  /// Firma storica, usata anche da altri flussi.
  static Future<void> open(BuildContext context, {required VoidCallback then}) async {
    if (await confirm(context) && context.mounted) then();
  }

  /// Chiede sempre il PIN, anche se l'adulto è già dentro: per le operazioni
  /// sensibili (eliminare un profilo, backup su Drive, cambio PIN) e per il
  /// rientro dopo che l'app è stata in background.
  static Future<bool> confirm(BuildContext context) async {
    final setup = !await pin.isSet;
    if (!context.mounted) return false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdultLocale(child: _GateDialog(setup: setup)),
    );
    return ok == true;
  }

  /// Cambio PIN: serve il PIN attuale, poi quello nuovo.
  static Future<bool> changePin(BuildContext context) async {
    if (!await confirm(context) || !context.mounted) return false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AdultLocale(child: _GateDialog(setup: true)),
    );
    return ok == true;
  }

  static Future<bool> _localAuth(String reason) async {
    try {
      final auth = LocalAuthentication();
      if (!await auth.isDeviceSupported()) return false;
      return await auth.authenticate(localizedReason: reason);
    } catch (_) {
      return false;
    }
  }
}

class _GateDialog extends StatefulWidget {
  const _GateDialog({required this.setup});
  final bool setup;
  @override
  State<_GateDialog> createState() => _GateDialogState();
}

class _GateDialogState extends State<_GateDialog> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  late bool _setup = widget.setup;
  String? _error;
  Duration _lock = Duration.zero;
  Timer? _timer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (!_setup) _refreshLock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _refreshLock() async {
    _lock = await AdultGate.pin.remainingLock();
    _timer?.cancel();
    if (_lock > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        final left = await AdultGate.pin.remainingLock();
        if (!mounted) return;
        setState(() => _lock = left);
        if (left == Duration.zero) _timer?.cancel();
      });
    }
    if (mounted) setState(() {});
  }

  String _fmt(Duration d) {
    final s = d.inSeconds + (d.inMilliseconds % 1000 > 0 ? 1 : 0);
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (_busy) return;
    final text = _pin.text.trim();
    if (_setup) {
      if (!AdultPin.isValidFormat(text)) return setState(() => _error = l.gatePinFormat);
      if (text != _confirm.text.trim()) return setState(() => _error = l.gatePinMismatch);
      setState(() => _busy = true);
      await AdultGate.pin.set(text);
      if (mounted) Navigator.of(context).pop(true);
      return;
    }
    setState(() => _busy = true);
    final r = await AdultGate.pin.verify(text);
    if (!mounted) return;
    _pin.clear();
    switch (r) {
      case PinResult.ok:
        Navigator.of(context).pop(true);
        return;
      case PinResult.wrong:
        setState(() {
          _busy = false;
          _error = l.gatePinWrong;
        });
      case PinResult.locked:
        await _refreshLock();
        if (mounted) {
          setState(() {
            _busy = false;
            _error = null;
          });
        }
    }
  }

  /// Recupero: l'autenticazione del dispositivo (se c'è) permette di scegliere
  /// un PIN nuovo. Non cancella nulla del bambino.
  Future<void> _forgot() async {
    final l = context.l10n;
    final ok = await AdultGate.deviceAuth(l.gateDeviceReason);
    if (!mounted) return;
    if (!ok) return setState(() => _error = l.gateForgotUnavailable);
    await AdultGate.pin.reset();
    if (!mounted) return;
    _timer?.cancel();
    setState(() {
      _setup = true;
      _lock = Duration.zero;
      _error = null;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locked = _lock > Duration.zero;
    InputDecoration deco(String label) => InputDecoration(labelText: label, counterText: '');
    final formatters = [FilteringTextInputFormatter.digitsOnly];
    return AlertDialog(
      title: Text(_setup ? l.gateSetupTitle : l.gateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_setup) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(l.gateSetupBody)),
          TextField(
            controller: _pin,
            enabled: !locked && !_busy,
            autofocus: true,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            maxLength: AdultPin.maxLength,
            keyboardType: TextInputType.number,
            inputFormatters: formatters,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 6),
            onSubmitted: (_) => _setup ? null : _submit(),
            decoration: deco(l.gatePinLabel),
          ),
          if (_setup) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _confirm,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              maxLength: AdultPin.maxLength,
              keyboardType: TextInputType.number,
              inputFormatters: formatters,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 6),
              onSubmitted: (_) => _submit(),
              decoration: deco(l.gatePinConfirmLabel),
            ),
          ],
          if (locked) Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.gatePinWait(_fmt(_lock)))),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          if (!_setup) TextButton(onPressed: _forgot, child: Text(l.gateForgot)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.cancel)),
        FilledButton(onPressed: locked || _busy ? null : _submit, child: Text(l.gateEnter)),
      ],
    );
  }
}

/// Avvolge le pagine di ingresso all'area adulta: se l'app resta in background
/// più di [timeout], al ritorno chiede di nuovo il PIN; se si annulla, si torna
/// alla schermata del bambino. Coprendo i ritorni da browser, stampa e
/// condivisione di sistema (docs/adult-gate.md).
class AdultGuard extends StatefulWidget {
  const AdultGuard({super.key, required this.child, this.timeout = const Duration(seconds: 60)});
  final Widget child;
  final Duration timeout;

  @override
  State<AdultGuard> createState() => _AdultGuardState();
}

class _AdultGuardState extends State<AdultGuard> with WidgetsBindingObserver {
  DateTime? _leftAt;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _leftAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final left = _leftAt;
      _leftAt = null;
      if (left != null && DateTime.now().difference(left) >= widget.timeout) _regate();
    }
  }

  Future<void> _regate() async {
    if (_asking || !mounted) return;
    _asking = true;
    final nav = Navigator.of(context, rootNavigator: true);
    final ok = await AdultGate.confirm(context);
    _asking = false;
    if (!ok && mounted) nav.popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
