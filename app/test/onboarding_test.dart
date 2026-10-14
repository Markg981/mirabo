import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/main.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/ui/parent/onboarding_screen.dart';
import 'package:mirabo/ui/parent/profile_form.dart';

class _FakeDb implements LocalDb {
  _FakeDb({Map<String, String>? settings}) : settings = settings ?? {};

  final Map<String, String> settings;

  @override
  Future<List<ChildProfile>> profiles() async => const [];
  @override
  Future<String?> setting(String key) async => settings[key];
  @override
  Future<void> setSetting(String key, String value) async => settings[key] = value;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRepo implements StoryRepository {
  _FakeRepo(this.story);
  final Story story;
  @override
  List<Story> storiesIn(String lang) => [story];
  @override
  List<Companion> companionsIn(String lang) => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Onboarding dell'adulto: si vede una volta, ogni passo si salta, nessun profilo prima della fine.
void main() {
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;
  final folder = '${root.path}/content/stories/sassolino-magico';
  final meta = Story.fromJson(jsonDecode(File('$folder/story.json').readAsStringSync()) as Map<String, dynamic>);
  final activity = HomeActivity.fromJson(jsonDecode(File('$folder/home-activity.json').readAsStringSync()) as Map<String, dynamic>);
  final variant = StoryVariant.fromJson(jsonDecode(File('$folder/5-7.json').readAsStringSync()) as Map<String, dynamic>);
  final story = Story(
    id: meta.id,
    version: meta.version,
    title: meta.title,
    world: meta.world,
    topic: meta.topic,
    variantFiles: meta.variantFiles,
    formats: meta.formats,
    togetherOnly: meta.togetherOnly,
    keyPhrase: meta.keyPhrase,
    parentCardFile: meta.parentCardFile,
    sources: meta.sources,
    variants: {AgeBand.b5to7: variant},
    homeActivity: activity,
  );

  Future<(AppState, _FakeDb)> start(WidgetTester tester, {_FakeDb? db}) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Il modulo del bambino ha un avviso di debug sui ListTile (preesistente, non legato all'onboarding).
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('ListTile background color')) return;
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);
    final d = db ?? _FakeDb();
    final state = AppState(db: d, repo: _FakeRepo(story));
    await state.init();
    addTearDown(state.dispose);
    await tester.pumpWidget(MiraboApp(state: state));
    await tester.pumpAndSettle();
    return (state, d);
  }

  testWidgets('percorso completo: promessa, lingua e fascia, assaggio, attività, prova con tuo figlio', (tester) async {
    final (state, db) = await start(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(ProfileForm), findsNothing);

    await tester.tap(find.byKey(const Key('onboarding-next'))); // promessa -> lingua e fascia
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onb-band-3-5')));
    await tester.tap(find.byKey(const Key('onb-lang-en')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding-next'))); // assaggio della storia
    await tester.pumpAndSettle();
    expect(find.text(story.title), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next'))); // attività e materiale
    await tester.pumpAndSettle();
    expect(find.textContaining('• '), findsWidgets);

    await tester.tap(find.byKey(const Key('onboarding-next'))); // prova con tuo figlio
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding-go')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileForm), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(state.onboardingBand, AgeBand.b3to5);
    expect(state.onboardingLanguage, AppLanguage.en);
    expect(db.settings[AppState.onboardingSeenKey], '1');
  });

  testWidgets('si può saltare subito e viene ricordato', (tester) async {
    final (state, db) = await start(tester);
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileForm), findsOneWidget);
    expect(state.onboardingSeen, isTrue);
    expect(db.settings[AppState.onboardingSeenKey], '1');
  });

  testWidgets('chi lo ha già visto non lo rivede', (tester) async {
    await start(tester, db: _FakeDb(settings: {AppState.onboardingSeenKey: '1'}));
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(ProfileForm), findsOneWidget);
  });
}
