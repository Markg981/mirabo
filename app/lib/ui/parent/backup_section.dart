import 'package:flutter/material.dart';

import 'adult_gate.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/backup_codec.dart';
import '../../data/backup_store.dart';
import '../../l10n/l10n.dart';

/// Backup su Google Drive nell'area genitore: stato e comandi.
class BackupSection extends StatelessWidget {
  const BackupSection({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final backup = state.backup;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: backup,
      builder: (context, _) {
        final last = backup.lastBackup;
        final lastText = last == null
            ? l.backupNever
            : l.backupLast(DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm().format(last));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(backup.enabled ? Icons.cloud_done_rounded : Icons.cloud_off_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  backup.enabled ? '${l.backupOnAccount(backup.account ?? '')}\n$lastText' : l.backupOff,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (backup.busy) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            ]),
            if (backup.enabled && backup.lastAutoFailed) ...[
              const SizedBox(height: 8),
              Text(l.backupAutoFailed, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: backup.enabled
                  ? [
                      FilledButton.icon(
                        icon: const Icon(Icons.backup_rounded),
                        label: Text(l.backupNow),
                        onPressed: backup.busy ? null : () => _backupNow(context),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.settings_backup_restore_rounded),
                        label: Text(l.backupRestore),
                        onPressed: backup.busy ? null : () async { if (await AdultGate.confirm(context) && context.mounted) await restoreFromDrive(context); },
                      ),
                      TextButton(
                        onPressed: backup.busy ? null : () => _disable(context),
                        child: Text(l.backupDisable),
                      ),
                    ]
                  : [
                      FilledButton.icon(
                        icon: const Icon(Icons.add_to_drive_rounded),
                        label: Text(l.backupEnable),
                        onPressed: backup.busy ? null : () async { if (await AdultGate.confirm(context) && context.mounted) await _enable(context); },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.settings_backup_restore_rounded),
                        label: Text(l.backupRestore),
                        onPressed: backup.busy ? null : () async { if (await AdultGate.confirm(context) && context.mounted) await restoreFromDrive(context); },
                      ),
                    ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _backupNow(BuildContext context) async {
    if (await _guard(context, state.backup.backupNow) && context.mounted) _toast(context, context.l10n.backupDone);
  }

  Future<void> _enable(BuildContext context) async {
    final l = context.l10n;
    final backup = state.backup;
    if (!await _guard(context, backup.connect) || !context.mounted) return;
    List<int>? remote;
    if (!await _guard(context, () async => remote = await backup.remoteBackup()) || !context.mounted) return;

    // Account già usato (altro tablet, reinstallazione): meglio non sovrascrivere senza chiedere.
    if (remote != null) {
      final choice = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.backupExistsTitle),
          content: Text(l.backupExists),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.backupExistsReplace)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.backupExistsRestore)),
          ],
        ),
      );
      if (choice == null || !context.mounted) return;
      if (choice) return restoreFromDrive(context, file: remote);
    }

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PasswordDialog(
        title: l.backupPasswordTitle,
        hint: l.backupPasswordHint,
        confirm: true,
        onSubmit: (pw) async {
          try {
            await backup.enable(pw);
            return null;
          } catch (e) {
            debugPrint('Attivazione backup non riuscita: $e');
            return l.backupError;
          }
        },
      ),
    );
    if (ok == true && context.mounted) _toast(context, l.backupDone);
  }

  Future<void> _disable(BuildContext context) async {
    final l = context.l10n;
    final deleteRemote = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.backupDisableTitle),
        content: Text(l.backupDisableConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.backupDisableDelete),
          ),
          FilledButton(onPressed: () => Navigator.pop(context, false), child: Text(l.backupDisableKeep)),
        ],
      ),
    );
    if (deleteRemote == null || !context.mounted) return;
    await _guard(context, () => state.backup.disable(deleteRemote: deleteRemote));
  }
}

/// Ripristino da Drive: dall'area genitore o dalla prima schermata di un
/// tablet nuovo. [file] è il backup già scaricato, se c'è.
Future<void> restoreFromDrive(BuildContext context, {List<int>? file}) async {
  final state = AppStateScope.read(context);
  final backup = state.backup;
  final l = context.l10n;
  if (file == null) {
    if (!await _guard(context, backup.connect) || !context.mounted) return;
    if (!await _guard(context, () async => file = await backup.remoteBackup()) || !context.mounted) return;
    if (file == null) return _toast(context, l.backupNone);
  }

  if (state.profiles.isNotEmpty) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.backupRestoreConfirmTitle),
        content: Text(l.backupRestoreConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.backupExistsRestore)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
  }

  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PasswordDialog(
      title: l.backupRestorePasswordTitle,
      hint: l.backupRestorePasswordHint,
      confirm: false,
      onSubmit: (pw) async {
        try {
          await backup.restore(file!, pw);
          return null;
        } on WrongPasswordException {
          return l.backupWrongPassword;
        } catch (e) {
          debugPrint('Ripristino non riuscito: $e');
          return l.backupError;
        }
      },
    ),
  );
  if (ok != true) return;
  await state.reloadAfterRestore();
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  Navigator.of(context).popUntil((r) => r.isFirst);
  messenger.showSnackBar(SnackBar(content: Text(l.backupRestored)));
}

/// Esegue un'operazione di rete; l'annullamento dell'accesso non è un errore,
/// tutto il resto diventa un messaggio. False se non è andata a buon fine.
Future<bool> _guard(BuildContext context, Future<void> Function() f) async {
  try {
    await f();
    return true;
  } on BackupCancelled {
    // Il genitore ha annullato l'accesso: non è un errore.
  } catch (e) {
    debugPrint('Backup: $e');
    if (context.mounted) _toast(context, context.l10n.backupError);
  }
  return false;
}

void _toast(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// Password del backup. [onSubmit] restituisce un messaggio d'errore da
/// mostrare nel dialogo, oppure null se è andata bene (il dialogo si chiude con true).
class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.title, required this.hint, required this.confirm, required this.onSubmit});
  final String title;
  final String hint;
  final bool confirm;
  final Future<String?> Function(String password) onSubmit;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _pw = TextEditingController();
  final _repeat = TextEditingController();
  bool _working = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _pw.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final pw = _pw.text;
    if (widget.confirm && pw.length < BackupCodec.minPasswordLength) {
      return setState(() => _error = l.backupPasswordShort(BackupCodec.minPasswordLength));
    }
    if (widget.confirm && pw != _repeat.text) return setState(() => _error = l.backupPasswordMismatch);
    if (pw.isEmpty) return;
    setState(() {
      _working = true;
      _error = null;
    });
    final error = await widget.onSubmit(pw);
    if (!mounted) return;
    if (error == null) return Navigator.pop(context, true);
    setState(() {
      _working = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.hint),
            const SizedBox(height: 16),
            TextField(
              controller: _pw,
              obscureText: _obscure,
              autofocus: true,
              enabled: !_working,
              decoration: InputDecoration(
                labelText: l.backupPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: widget.confirm ? null : (_) => _submit(),
            ),
            if (widget.confirm) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _repeat,
                obscureText: _obscure,
                enabled: !_working,
                decoration: InputDecoration(labelText: l.backupPasswordRepeat),
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _working ? null : () => Navigator.pop(context, false), child: Text(l.cancel)),
        FilledButton(
          onPressed: _working ? null : _submit,
          child: _working
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
              : Text(l.backupContinue),
        ),
      ],
    );
  }
}
