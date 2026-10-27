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
  /// sensibili (eliminare un profilo, backup su Drive, cambio PIN, codice e
  /// recupero con il blocco del tablet, cancellazione dei dati) e per il
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

  /// Come [confirm], ma subito dopo un reset col blocco del tablet chiede
  /// anche il vecchio codice di recupero: chi conosce solo lo sblocco del
  /// tablet non può rigenerare il codice, spegnere il recupero o chiudere
  /// l'avviso (docs/adult-gate.md).
  static Future<bool> confirmProtected(BuildContext context) async {
    if (!await confirm(context) || !context.mounted) return false;
    if (!await pin.recoveryProtected || !context.mounted) return true;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AdultLocale(child: _OldCodeDialog()),
    );
    return ok == true;
  }

  /// Un nuovo codice di recupero (il vecchio smette di valere), dopo il PIN.
  static Future<void> newRecoveryCode(BuildContext context) async {
    if (!await confirmProtected(context) || !context.mounted) return;
    final code = await pin.newRecoveryCode();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdultLocale(
        child: AlertDialog(
          title: Text(context.l10n.gateRecoveryTitle),
          content: _RecoveryCodeBody(code: code),
          actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.gateRecoveryWritten))],
        ),
      ),
    );
  }

  /// Accende o spegne il recupero con il blocco del tablet, dopo il PIN.
  static Future<bool> setDeviceRecovery(BuildContext context, bool on) async {
    // Accenderlo non toglie nulla all'adulto: il vecchio codice serve per spegnerlo.
    if (!await (on ? confirm(context) : confirmProtected(context))) return false;
    await pin.setDeviceRecovery(on);
    return true;
  }

  /// Chiude l'avviso di un reset: serve il PIN (e, subito dopo un reset col
  /// blocco del tablet, il vecchio codice di recupero).
  static Future<bool> dismissResetNotice(BuildContext context) async {
    if (!await confirmProtected(context)) return false;
    await pin.clearResetNotice();
    return true;
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

enum _Phase { setup, verify, recover, showCode }

class _GateDialog extends StatefulWidget {
  const _GateDialog({required this.setup});
  final bool setup;
  @override
  State<_GateDialog> createState() => _GateDialogState();
}

class _GateDialogState extends State<_GateDialog> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  late _Phase _phase = widget.setup ? _Phase.setup : _Phase.verify;
  String? _error;
  String? _code;
  bool _deviceRecovery = false;
  Duration _lock = Duration.zero;
  Timer? _timer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (_phase == _Phase.verify) _refreshLock();
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
    switch (_phase) {
      case _Phase.showCode:
        Navigator.of(context).pop(true);
        return;
      case _Phase.setup:
        if (!AdultPin.isValidFormat(text)) return setState(() => _error = l.gatePinFormat);
        if (text != _confirm.text.trim()) return setState(() => _error = l.gatePinMismatch);
        setState(() => _busy = true);
        await AdultGate.pin.set(text);
        // Senza codice di recupero (primo PIN, o codice appena usato) se ne
        // crea uno e si mostra una volta sola.
        final code = await AdultGate.pin.hasRecoveryCode ? null : await AdultGate.pin.newRecoveryCode();
        if (!mounted) return;
        if (code == null) {
          Navigator.of(context).pop(true);
          return;
        }
        return setState(() {
          _code = code;
          _phase = _Phase.showCode;
          _error = null;
          _busy = false;
        });
      case _Phase.verify:
      case _Phase.recover:
        setState(() => _busy = true);
        final recovering = _phase == _Phase.recover;
        final r = recovering ? await AdultGate.pin.recover(text) : await AdultGate.pin.verify(text);
        if (!mounted) return;
        _pin.clear();
        switch (r) {
          case PinResult.ok when recovering:
            return _chooseNewPin();
          case PinResult.ok:
            Navigator.of(context).pop(true);
            return;
          case PinResult.wrong:
            setState(() {
              _busy = false;
              _error = recovering ? l.gateRecoveryWrong : l.gatePinWrong;
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
  }

  void _chooseNewPin() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.setup;
      _lock = Duration.zero;
      _error = null;
      _busy = false;
    });
  }

  /// "Ho dimenticato il PIN": il codice di recupero c'è sempre; il blocco del
  /// tablet solo se l'adulto non l'ha spento. Non si cancella nulla del bambino.
  Future<void> _forgot() async {
    final device = await AdultGate.pin.deviceRecovery;
    if (!mounted) return;
    _pin.clear();
    setState(() {
      _phase = _Phase.recover;
      _deviceRecovery = device;
      _error = null;
    });
  }

  Future<void> _deviceRecover() async {
    final l = context.l10n;
    // Come PIN e codice di recupero, rispetta l'attesa da blocco.
    if ((await AdultGate.pin.remainingLock()) > Duration.zero) {
      return _refreshLock();
    }
    final ok = await AdultGate.deviceAuth(l.gateDeviceReason);
    if (!mounted) return;
    if (!ok) return setState(() => _error = l.gateForgotUnavailable);
    await AdultGate.pin.reset(how: RecoveryChannel.device);
    if (mounted) _chooseNewPin();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locked = _lock > Duration.zero;
    InputDecoration deco(String label) => InputDecoration(labelText: label, counterText: '');
    final digits = [FilteringTextInputFormatter.digitsOnly];
    TextField pinField(TextEditingController c, String label, {bool autofocus = false, VoidCallback? onDone}) => TextField(
          controller: c,
          enabled: !locked && !_busy,
          autofocus: autofocus,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          maxLength: AdultPin.maxLength,
          keyboardType: TextInputType.number,
          inputFormatters: digits,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 6),
          onSubmitted: (_) => onDone?.call(),
          decoration: deco(label),
        );
    final title = switch (_phase) {
      _Phase.setup => l.gateSetupTitle,
      _Phase.verify => l.gateTitle,
      _Phase.recover => l.gateForgot,
      _Phase.showCode => l.gateRecoveryTitle,
    };
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (_phase) {
              _Phase.setup => Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(l.gateSetupBody)),
                  pinField(_pin, l.gatePinLabel, autofocus: true),
                  const SizedBox(height: 8),
                  pinField(_confirm, l.gatePinConfirmLabel, onDone: _submit),
                ]),
              _Phase.verify => pinField(_pin, l.gatePinLabel, autofocus: true, onDone: _submit),
              _Phase.recover => Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(l.gateRecoveryAsk)),
                  TextField(
                    key: const Key('recovery-code'),
                    controller: _pin,
                    enabled: !locked && !_busy,
                    autofocus: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, letterSpacing: 3),
                    onSubmitted: (_) => _submit(),
                    decoration: deco(l.gateRecoveryLabel),
                  ),
                  if (_deviceRecovery)
                    TextButton(onPressed: _busy ? null : _deviceRecover, child: Text(l.gateUseDevice))
                  else
                    Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.gateDeviceOff)),
                ]),
              _Phase.showCode => _RecoveryCodeBody(code: _code ?? ''),
            },
            if (locked) Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.gatePinWait(_fmt(_lock)))),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            if (_phase == _Phase.verify) TextButton(onPressed: _forgot, child: Text(l.gateForgot)),
          ],
        ),
      ),
      actions: [
        if (_phase != _Phase.showCode) TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.cancel)),
        FilledButton(
          onPressed: locked || _busy ? null : _submit,
          child: Text(_phase == _Phase.showCode ? l.gateRecoveryWritten : l.gateEnter),
        ),
      ],
    );
  }
}

/// Chiede il vecchio codice di recupero per le modifiche protette dopo un
/// reset. Rispetta le attese tra tentativi, come PIN e recupero.
class _OldCodeDialog extends StatefulWidget {
  const _OldCodeDialog();
  @override
  State<_OldCodeDialog> createState() => _OldCodeDialogState();
}

class _OldCodeDialogState extends State<_OldCodeDialog> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (_busy) return;
    setState(() => _busy = true);
    final r = await AdultGate.pin.verifyRecoveryCode(_code.text);
    if (!mounted) return;
    if (r == PinResult.ok) {
      Navigator.of(context).pop(true);
      return;
    }
    final wait = r == PinResult.locked ? await AdultGate.pin.remainingLock() : Duration.zero;
    if (!mounted) return;
    _code.clear();
    setState(() {
      _busy = false;
      _error = wait > Duration.zero ? l.gatePinWait('${wait.inSeconds + 1} s') : l.gateRecoveryWrong;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.gateRecoveryLabel),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(l.gateRecoveryAsk)),
        TextField(
          key: const Key('old-recovery-code'),
          controller: _code,
          enabled: !_busy,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, letterSpacing: 3),
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(labelText: l.gateRecoveryLabel, counterText: ''),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.cancel)),
        FilledButton(onPressed: _busy ? null : _submit, child: Text(l.gateEnter)),
      ],
    );
  }
}

/// Il codice di recupero appena creato, mostrato una volta sola.
class _RecoveryCodeBody extends StatelessWidget {
  const _RecoveryCodeBody({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.l10n.gateRecoveryBody),
        const SizedBox(height: 16),
        Center(
          child: SelectableText(code,
              key: const Key('recovery-shown'), style: const TextStyle(fontSize: 30, letterSpacing: 4, fontWeight: FontWeight.w700)),
        ),
      ]);
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
