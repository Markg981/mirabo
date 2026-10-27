import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../data/local_db.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

/// I dati salvati non si aprono (secure storage che non risponde, spazio
/// finito, database di una versione più recente). Non si cancella niente e
/// non si fa finta di niente: lo si dice all'adulto e si può riprovare
/// (docs/release-engineering.md, "Errori di salvataggio").
///
/// Se riprovare non basta, un percorso per adulti (avviso, conferma esplicita,
/// poi il pulsante: il PIN potrebbe non essere leggibile) azzera i dati con
/// [LocalDb.eraseStorage] e riparte.
class StartupFailureApp extends StatefulWidget {
  const StartupFailureApp({super.key, required this.error, required this.onRetry, this.onErase = LocalDb.eraseStorage});

  final Object error;
  final VoidCallback onRetry;
  final Future<void> Function() onErase;

  @override
  State<StartupFailureApp> createState() => _StartupFailureAppState();
}

class _StartupFailureAppState extends State<StartupFailureApp> {
  bool _adult = false;
  bool _understood = false;
  bool _erasing = false;
  bool _eraseFailed = false;

  Future<void> _erase() async {
    setState(() {
      _erasing = true;
      _eraseFailed = false;
    });
    try {
      await widget.onErase();
    } catch (_) {
      if (mounted) {
        setState(() {
          _erasing = false;
          _eraseFailed = true;
        });
      }
      return;
    }
    widget.onRetry();
  }

  String _kind(AppLocalizations l) => switch (widget.error) {
        PlatformException() => l.startupErrKeystore,
        DatabaseException() => l.startupErrDatabase,
        FormatException() => l.startupErrFormat,
        _ => l.startupErrOther,
      };

  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    return MaterialApp(
      title: 'Mirabò',
      debugShowCheckedModeBanner: false,
      theme: miraboTheme(dyslexiaFont: false, lowStimulation: true),
      locale: AppLanguage.ofDevice().locale,
      supportedLocales: [for (final l in AppLanguage.values) l.locale],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(builder: (context) {
        final l = context.l10n;
        final text = Theme.of(context).textTheme;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.warning_amber_rounded, size: 40),
                    const SizedBox(height: 12),
                    Text(l.startupFailedTitle, style: text.headlineSmall),
                    const SizedBox(height: 12),
                    Text(
                      error is DatabaseTooNewException ? l.startupTooNewBody : l.startupFailedBody,
                      key: const Key('startup-failure-body'),
                      style: text.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(l.startupErrorKind(_kind(l)), key: const Key('startup-error-kind'), style: text.bodyMedium),
                    const SizedBox(height: 20),
                    if (error is! DatabaseTooNewException)
                      FilledButton(key: const Key('startup-retry'), onPressed: widget.onRetry, child: Text(l.startupRetry)),
                    const SizedBox(height: 12),
                    if (!_adult)
                      TextButton(
                        key: const Key('startup-adult'),
                        onPressed: () => setState(() => _adult = true),
                        child: Text(l.startupAdultOptions),
                      )
                    else ...[
                      Text(l.startupEraseWarning, key: const Key('startup-erase-warning'), style: text.bodyMedium),
                      CheckboxListTile(
                        key: const Key('startup-erase-confirm'),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _understood,
                        onChanged: _erasing ? null : (v) => setState(() => _understood = v ?? false),
                        title: Text(l.startupEraseConfirm),
                      ),
                      if (_eraseFailed) Text(l.startupEraseFailed, key: const Key('startup-erase-failed')),
                      OutlinedButton(
                        key: const Key('startup-erase'),
                        onPressed: _understood && !_erasing ? _erase : null,
                        child: Text(l.startupErase),
                      ),
                    ],
                  ])),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Fascia in alto quando un salvataggio non è riuscito ([AppState.saveFailure]):
/// resta finché l'adulto non la chiude.
class SaveFailureBanner extends StatelessWidget {
  const SaveFailureBanner({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      key: const Key('save-failure-banner'),
      color: scheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(child: Text(l.saveFailedBanner, style: TextStyle(color: scheme.onErrorContainer))),
            TextButton(onPressed: onDismiss, child: Text(l.saveFailedDismiss)),
          ]),
        ),
      ),
    );
  }
}
