import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/cloud_backup.dart';
import '../../l10n/l10n.dart';
import 'adult_gate.dart';

/// "I tuoi dati" nell'area genitore: cancellazione completa su questo tablet,
/// cancellazione separata del backup su Drive e cosa resta fuori dall'app.
/// Vedi docs/data-deletion.md.
class DataDeletionSection extends StatelessWidget {
  const DataDeletionSection({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final error = Theme.of(context).colorScheme.error;
    final style = OutlinedButton.styleFrom(
      foregroundColor: error,
      side: BorderSide(color: error.withValues(alpha: 0.5), width: 1.5),
    );
    return ListenableBuilder(
      listenable: state.backup,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                style: style,
                icon: const Icon(Icons.delete_forever_rounded),
                label: Text(l.parentWipe),
                // Primo passo: di nuovo il gate adulto. Secondo: scrivere la parola.
                onPressed: () => AdultGate.open(context, then: () => _confirmWipe(context)),
              ),
              if (state.backup.enabled)
                OutlinedButton.icon(
                  style: style,
                  icon: const Icon(Icons.cloud_off_rounded),
                  label: Text(l.dataRemoteButton),
                  onPressed: state.backup.busy ? null : () => AdultGate.open(context, then: () => _confirmRemote(context)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l.dataOutsideTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l.dataOutsideBody),
        ],
      ),
    );
  }

  Future<void> _confirmWipe(BuildContext context) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _TypeWordDialog(title: l.dataWipeTitle, body: l.dataWipeBody, word: l.dataWipeWord),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    String message;
    try {
      await state.wipeAll();
      message = l.dataWipeDone;
    } catch (e) {
      debugPrint('Cancellazione non riuscita: $e');
      message = l.dataWipeFailed;
    }
    navigator.popUntil((r) => r.isFirst);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmRemote(BuildContext context) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.dataRemoteTitle),
        content: Text(l.dataRemoteBody(state.backup.account ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.dataRemoteButton),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final success = await deleteRemoteBackup(state.backup);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(success ? Icons.check_circle_rounded : Icons.error_rounded,
            color: success ? null : Theme.of(context).colorScheme.error),
        content: Text(success ? l.dataRemoteDone : l.dataRemoteFailed),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

/// Cancella il file su Drive, poi scollega l'account e revoca il permesso.
/// False se non riesce (rete assente, accesso scaduto...): in quel caso non
/// cambia niente e si può riprovare.
Future<bool> deleteRemoteBackup(CloudBackup backup) async {
  try {
    await backup.disable(deleteRemote: true);
    return true;
  } catch (e) {
    debugPrint('Eliminazione del backup su Drive non riuscita: $e');
    return false;
  }
}

class _TypeWordDialog extends StatefulWidget {
  const _TypeWordDialog({required this.title, required this.body, required this.word});
  final String title;
  final String body;
  final String word;

  @override
  State<_TypeWordDialog> createState() => _TypeWordDialogState();
}

class _TypeWordDialogState extends State<_TypeWordDialog> {
  final _controller = TextEditingController();

  bool get _matches => _controller.text.trim().toLowerCase() == widget.word.toLowerCase();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.body),
            const SizedBox(height: 16),
            Text(l.dataWipeTypePrompt(widget.word), style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
          child: Text(l.parentWipeYes),
        ),
      ],
    );
  }
}
