import 'package:flutter/material.dart';

import '../data/local_db.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

/// I dati salvati non si aprono (secure storage che non risponde, spazio
/// finito, database di una versione più recente). Non si cancella niente e
/// non si fa finta di niente: lo si dice all'adulto e si può riprovare
/// (docs/release-engineering.md, "Errori di salvataggio").
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.warning_amber_rounded, size: 40),
                    const SizedBox(height: 12),
                    Text(l.startupFailedTitle, style: text.headlineSmall),
                    const SizedBox(height: 12),
                    Text(
                      error is DatabaseTooNewException ? l.startupTooNewBody : l.startupFailedBody,
                      key: const Key('startup-failure-body'),
                      style: text.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    if (error is! DatabaseTooNewException)
                      FilledButton(key: const Key('startup-retry'), onPressed: onRetry, child: Text(l.startupRetry)),
                  ]),
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
