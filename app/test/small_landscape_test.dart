import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/activity.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/models/themes.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/child/home_screen.dart';

/// Layout su schermo piccolo in landscape (telefono, 844x390): niente overflow.
class _Repo implements StoryRepository {
  @override
  List<Story> get stories => const [];
  @override
  List<Activity> get activities => const [];
  @override
  ThemeCatalog themes = ThemeCatalog.fromJson({
    'version': 1,
    'themes': <String>[],
    'cells': <Map<String, dynamic>>[],
  });
  @override
  List<Story> storiesIn(String lang) => const [];
  @override
  List<Activity> activitiesIn(String lang) => const [];
  @override
  List<Companion> companionsIn(String lang) => const [
        Companion(
          id: CompanionId.bo,
          name: 'Bo',
          kind: 'mammut',
          tagline: '',
          growth: ['piccolo', 'cresce', 'grande', 'grandissimo'],
        ),
      ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Db implements LocalDb {
  _Db(this.profile);
  ChildProfile profile;
  @override
  Future<List<ChildProfile>> profiles() async => [profile];
  @override
  Future<String?> setting(String key) async => null;
  @override
  Future<void> updateProfile(ChildProfile p) async => profile = p;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final size in [
    const Size(844, 390),
    const Size(667, 375),
    const Size(800, 240),
    const Size(640, 200),
  ]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets(
        'casa a ${size.width.toInt()}x${size.height.toInt()} testo x$scale: nessun overflow',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final p = const ChildProfile(
            id: 1,
            name: 'Emma',
            ageBand: AgeBand.b3to5,
            companion: CompanionId.bo,
            aloneSessionMinutes: 0,
          ).withShelf(const []);
          final state = AppState(
            db: _Db(p),
            repo: _Repo(),
            nameVoice: NameVoice(
              cacheDir: () async => throw const FileSystemException('no'),
            ),
          );
          await state.init();
          addTearDown(state.dispose);
          await tester.pumpWidget(
            AppStateScope(
              state: state,
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('it'),
                theme: miraboTheme(dyslexiaFont: false, lowStimulation: false),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const HomeScreen(),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
