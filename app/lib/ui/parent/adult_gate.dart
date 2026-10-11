import 'dart:math';

import 'package:flutter/material.dart';

/// Gate adulti: una moltiplicazione semplice da scrivere entro pochi secondi.
/// Facile per un adulto, impraticabile per un bambino di 3-7 anni. Nessuna password.
class AdultGate {
  static Future<void> open(BuildContext context, {required VoidCallback then}) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => const _GateDialog());
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
      title: const Text('Area per i grandi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Quanto fa $_a × $_b?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
            onSubmitted: (_) => _check(),
            decoration: InputDecoration(errorText: _wrong ? 'Riprova' : null),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
        FilledButton(onPressed: _check, child: const Text('Entra')),
      ],
    );
  }
}
