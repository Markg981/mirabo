import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'content/story_repository.dart';
import 'data/local_db.dart';
import 'theme.dart';
import 'ui/child/home_screen.dart';
import 'ui/parent/profile_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  final db = await LocalDb.open();
  final repo = StoryRepository();
  await repo.load();
  final state = AppState(db: db, repo: repo);
  await state.init();
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
            ),
            locale: const Locale('it'),
            supportedLocales: const [Locale('it')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: profile == null ? const ProfileForm(firstRun: true) : const HomeScreen(),
          );
        },
      ),
    );
  }
}
