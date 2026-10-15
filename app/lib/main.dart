import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'features.dart';
import 'data/usage_tracker.dart';
import 'content/story_repository.dart';
import 'data/local_db.dart';
import 'l10n/l10n.dart';
import 'models/profile.dart';
import 'theme.dart';
import 'ui/child/choose_child_screen.dart';
import 'ui/child/goodbye_screen.dart';
import 'ui/child/home_screen.dart';
import 'ui/parent/onboarding_screen.dart';
import 'ui/parent/profile_form.dart';
import 'ui/startup_failure.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await start();
}

/// Apre i dati e avvia l'app. Se i dati salvati non si aprono non si cancella
/// niente e non si riparte da zero: una schermata lo dice e si può riprovare.
Future<void> start() async {
  final LocalDb db;
  final AppState state;
  try {
    db = await LocalDb.open();
    final repo = StoryRepository();
    await repo.load();
    state = AppState(db: db, repo: repo);
    await state.init();
  } catch (e, st) {
    debugPrint('Avvio non riuscito: $e\n$st');
    runApp(StartupFailureApp(error: e, onRetry: start));
    return;
  }
  if (Features.cloudBackup) {
    await state.backup.load();
    // Backup automatico (se attivo e vecchio di un giorno) all'apertura e al ritorno in primo piano.
    unawaited(state.backup.autoBackup());
  } else {
    // Fuori dall'MVP: nessun accesso a Google. Account e chiave lasciati da una
    // versione precedente si tolgono dal deposito sicuro (la copia su Drive resta
    // del genitore: l'area adulta dice come eliminarla).
    await state.backup.forget();
  }
  // "Insieme" scade se l'app resta a lungo in background (AppState.togetherLapse).
  AppLifecycleListener(
    onHide: state.appHidden,
    onResume: () {
      state.appResumed();
      if (Features.cloudBackup) unawaited(state.backup.autoBackup());
    },
  );
  unawaited(state.checkVoices());
  // Tempo con l'app in primo piano, per bambino (solo per l'area genitori).
  state.usage = UsageTracker(db: db, profileId: () => state.currentProfile?.id)..start();
  // Quando cambia il bambino il tratto fin lì va a quello di prima.
  state.addListener(() => state.usage?.tick());
  runApp(MiraboApp(state: state));
}

class MiraboApp extends StatelessWidget {
  const MiraboApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final profile = state.currentProfile;
          return MaterialApp(
            title: 'Mirabò',
            debugShowCheckedModeBanner: false,
            theme: miraboTheme(
              dyslexiaFont: profile?.dyslexiaFont ?? false,
              lowStimulation: profile?.lowStimulation ?? false,
              interaction: profile?.interaction ?? const InteractionProfile(),
              voiceMissing: profile != null && state.voiceMissingFor(profile),
            ),
            // Lato bambino: la lingua del bambino che gioca. Prima di sceglierlo
            // (primo avvio, "Chi gioca oggi?") quella del tablet.
            locale: profile == null || state.needsChildChoice
                ? (state.onboardingLanguage ?? AppLanguage.ofDevice()).locale
                : AppLanguage.fromCode(profile.language).locale,
            supportedLocales: [for (final l in AppLanguage.values) l.locale],
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Un salvataggio non riuscito si vede su ogni schermata, finché l'adulto non lo chiude.
            builder: (context, child) => state.saveFailure == null
                ? child!
                : Column(children: [
                    SaveFailureBanner(onDismiss: state.dismissSaveFailure),
                    Expanded(child: child!),
                  ]),
            home: profile == null
                ? (state.onboardingSeen
                    ? ProfileForm(
                        firstRun: true,
                        initialLanguage: state.onboardingLanguage,
                        initialBand: state.onboardingBand,
                      )
                    : const OnboardingScreen())
                : state.aloneGoodbye
                    ? const GoodbyeScreen()
                    : state.needsChildChoice
                        ? const ChooseChildScreen()
                        : const HomeScreen(),
          );
        },
      ),
    );
  }
}
