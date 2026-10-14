import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  final db = await LocalDb.open();
  final repo = StoryRepository();
  await repo.load();
  final state = AppState(db: db, repo: repo);
  await state.init();
  await state.backup.load();
  // Backup automatico (se attivo e vecchio di un giorno) all'apertura e al ritorno in primo piano.
  unawaited(state.backup.autoBackup());
  AppLifecycleListener(onResume: () => unawaited(state.backup.autoBackup()));
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
            ),
            // Lato bambino: la lingua del bambino che gioca. Prima di sceglierlo
            // (primo avvio, "Chi gioca oggi?") quella del tablet.
            locale: profile == null || state.needsChildChoice
                ? (state.onboardingLanguage ?? AppLanguage.ofDevice()).locale
                : AppLanguage.fromCode(profile.language).locale,
            supportedLocales: [for (final l in AppLanguage.values) l.locale],
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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
