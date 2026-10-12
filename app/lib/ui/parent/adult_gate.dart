import 'dart:math';

import '../../l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Gate adulti: una moltiplicazione semplice da scrivere entro pochi secondi.
/// Facile per un adulto, impraticabile per un bambino di 3-7 anni. Nessuna password.
class AdultGate {
  static Future<void> open(BuildContext context, {required VoidCallback then}) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => const AdultLocale(child: _GateDialog()));
    if (ok == true) then();
  }
}

class _GateDialog extends StatefulWidget {
  const _GateDialog();
  @override
  State<_GateDialog> createState() => _GateDialogState();
}

class _GateDialogState extends State<_GateDialog> {
  late final int _a = 3 + Random().nextInt(7); // 3..9
  late final int _b = 4 + Random().nextInt(6); // 4..9
  final _controller = TextEditingController();
  bool _wrong = false;

  void _check() {
    if (int.tryParse(_controller.text.trim()) == _a * _b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.gateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.gateQuestion('$_a', '$_b'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
            onSubmitted: (_) => _check(),
            decoration: InputDecoration(errorText: _wrong ? context.l10n.gateWrong : null),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.cancel)),
        FilledButton(onPressed: _check, child: Text(context.l10n.gateEnter)),
      ],
    );
  }
}
