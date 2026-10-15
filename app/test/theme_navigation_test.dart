import 'dart:convert';
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

Story _story(String id, {String world = 'emozioni', bool togetherOnly = false, String? gesture = 'Fare il respiro del vulcano.'}) =>
    Story.fromJson({
      'id': id,
      'version': 1,
      'title': 'Storia $id',
      'world': world,
      'topic': 't',
      'ageBands': {'3-5': 'v.json', '6-7': 'v.json'},
      'formats': ['read'],
      'togetherOnly': togetherOnly,
      'keyPhrase': 'k',
      'gesture': gesture,
      'parentCard': 'p.md',
    });

Activity _activity(String id, {String offscreen = 'Giocare a turni con un timer.'}) => Activity.fromJson({
      'id': id,
      'version': 1,
      'title': 'Attività $id',
      'area': 'sociale',
      'skill': 'x',
      'type': 'tapMatch',
      'ageBands': ['3-5', '6-7'],
      'intro': {'bo': 'b', 'pilu': 'p', 'tango': 't'},
      'outro': {'bo': 'b', 'pilu': 'p', 'tango': 't'},
      'offscreen': offscreen,
      'levels': <Map<String, dynamic>>[],
    });

final _catalog = ThemeCatalog.fromJson({
  'version': 1,
  'themes': ['emozioni-relazioni', 'natura-viventi', 'autonomia-scuola'],
  'cells': [
    {
      'theme': 'emozioni-relazioni',
      'band': '3-5',
      'story': ['story:lia'],
      'game': ['activity:omar'],
      'practice': ['gesture:lia', 'offscreen:omar'],
    },
    {
      'theme': 'natura-viventi',
      'band': '3-5',
      'story': ['story:goccia'],
      'game': <String>[],
      'practice': ['gesture:goccia', 'activity:versare', 'story:che-non-esiste'],
    },
    {'theme': 'un-tema-futuro', 'band': '3-5', 'story': ['story:lia'], 'game': <String>[], 'practice': <String>[]},
  ],
});

class _Repo implements StoryRepository {
  _Repo(this.stories, this.activities);
  @override
  final List<Story> stories;
  @override
  final List<Activity> activities;
  @override
  ThemeCatalog themes = _catalog;

  @override
  List<Story> storiesIn(String lang) => stories;
  @override
  List<Activity> activitiesIn(String lang) => activities;
  @override
  List<Companion> companionsIn(String lang) => const [
        Companion(id: CompanionId.bo, name: 'Bo', kind: 'mammut', tagline: '', growth: ['piccolo', 'cresce', 'grande', 'grandissimo']),
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

_Repo _repo() => _Repo(
      [_story('lia'), _story('goccia', world: 'ambiente')],
      [_activity('omar'), _activity('versare')],
    );

List<String> _keys(Map<ExperienceMode, List<ThemeExperience>> m, ExperienceMode mode) => [for (final e in m[mode]!) e.key];

void main() {
  test('un tema raccoglie storia, gioco e cosa da provare per identificatore stabile', () {
    final r = _repo();
    final emo = _catalog.resolve(ChildTheme.emozioniRelazioni, AgeBand.b3to5, stories: r.stories, activities: r.activities);
    expect(_keys(emo, ExperienceMode.story), ['story:lia']);
    expect(_keys(emo, ExperienceMode.game), ['activity:omar']);
    expect(_keys(emo, ExperienceMode.practice), ['gesture:lia', 'offscreen:omar']);
    final practice = emo[ExperienceMode.practice]!;
    expect((practice[0] as ThemePractice).instruction, 'Fare il respiro del vulcano.');
    expect((practice[1] as ThemePractice).instruction, 'Giocare a turni con un timer.');

    // Un riferimento che non si trova resta fuori; una modalità vuota resta vuota.
    final nat = _catalog.resolve(ChildTheme.naturaViventi, AgeBand.b3to5, stories: r.stories, activities: r.activities);
    expect(_keys(nat, ExperienceMode.game), isEmpty);
    expect(_keys(nat, ExperienceMode.practice), ['gesture:goccia', 'activity:versare']);

    // Fascia senza cella: tre modalità vuote, nessun errore.
    final big = _catalog.resolve(ChildTheme.autonomiaScuola, AgeBand.b8to10, stories: r.stories, activities: r.activities);
    expect(big.keys, ExperienceMode.values);
    expect(big.values.every((l) => l.isEmpty), isTrue);
  });

  test('il gesto segue la sua storia: senza storia permessa non c\'è nemmeno il gesto', () {
    final r = _repo();
    final emo = _catalog.resolve(ChildTheme.emozioniRelazioni, AgeBand.b3to5, stories: const [], activities: r.activities);
    expect(_keys(emo, ExperienceMode.story), isEmpty);
    expect(_keys(emo, ExperienceMode.practice), ['offscreen:omar']);
  });

  test('la matrice educativa usa i tre temi che l\'app conosce, per tutte le fasce', () {
    final matrix = jsonDecode(File('../content/education/matrix.json').readAsStringSync()) as Map<String, dynamic>;
    expect((matrix['themes'] as Map<String, dynamic>).keys.map(ChildTheme.byId), everyElement(isNotNull));
    // Stessa trasformazione di check_goals.navigation (studio/sync_assets.py).
    final catalog = ThemeCatalog.fromJson({
      'cells': [
        for (final c in (matrix['cells'] as List).cast<Map<String, dynamic>>())
          {
            'theme': c['theme'],
            'band': c['band'],
            for (final m in ExperienceMode.values) m.name: (c['modes'] as Map<String, dynamic>)[m.name]['content'],
          },
      ],
    });
    for (final t in ChildTheme.values) {
      for (final b in AgeBand.values) {
        final refs = catalog.refs(t, b);
        expect(refs.keys, ExperienceMode.values, reason: '${t.id} ${b.key}');
        expect(refs.values.expand((r) => r), everyElement(matches(RegExp(r'^(story|activity|gesture|offscreen):[a-z0-9-]+$'))));
      }
    }
  });

  test('completamenti, mensola vuota e cambio di settimana non tolgono niente dal tema', () async {
    var now = DateTime(2026, 10, 1);
    const fresh = ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo);
    final state = AppState(
      db: _Db(fresh),
      repo: _repo(),
      clock: () => now,
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
    );
    await state.init();
    addTearDown(state.dispose);
    final before = {for (final t in ChildTheme.values) t: state.themeFor(fresh, t)};

    // Niente ancora finito: storia, gioco e pratica si aprono subito.
    expect(before[ChildTheme.emozioniRelazioni]!.values.every((l) => l.isNotEmpty), isTrue);

    // Il genitore svuota la mensola, il bambino ha finito tutto, passano due settimane.
    final later = fresh.withShelf(const []).copyWith(storiesCompleted: 12);
    now = now.add(const Duration(days: 14));
    for (final t in ChildTheme.values) {
      for (final m in ExperienceMode.values) {
        expect(_keys(state.themeFor(later, t), m), _keys(before[t]!, m), reason: '${t.id} ${m.name}');
      }
    }
  });

  test('entro i permessi dell\'adulto: mondo spento o storia solo insieme quando gioca da solo', () async {
    const p = ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo);
    final repo = _Repo([_story('lia', togetherOnly: true), _story('goccia', world: 'ambiente')], [_activity('omar'), _activity('versare')]);
    final state = AppState(db: _Db(p), repo: repo, nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')));
    await state.init();
    addTearDown(state.dispose);

    final alone = state.themeFor(p, ChildTheme.emozioniRelazioni, mode: SessionMode.alone);
    expect(_keys(alone, ExperienceMode.story), isEmpty);
    expect(_keys(alone, ExperienceMode.game), ['activity:omar']);
    expect(_keys(alone, ExperienceMode.practice), ['offscreen:omar']);

    final noNature = p.copyWith(enabledWorlds: {World.emozioni});
    expect(_keys(state.themeFor(noNature, ChildTheme.naturaViventi), ExperienceMode.story), isEmpty);
    expect(_keys(state.themeFor(noNature, ChildTheme.naturaViventi), ExperienceMode.practice), ['activity:versare']);
  });

  testWidgets('casa -> tema -> cosa da provare -> di nuovo lo stesso tema', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Mensola scelta dal genitore (vuota): la casa non deve ruotarla.
    final p = const ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo).withShelf(const []);
    final state = AppState(db: _Db(p), repo: _repo(), nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')));
    await state.init();
    addTearDown(state.dispose);
    await tester.pumpWidget(AppStateScope(
      state: state,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        theme: miraboTheme(dyslexiaFont: false, lowStimulation: true),
        home: const HomeScreen(),
      ),
    ));
    await tester.pump();

    // I tre temi ci sono anche con la mensola vuota.
    expect(find.text('COME MI SENTO'), findsOneWidget);
    expect(find.text('LA NATURA'), findsOneWidget);
    expect(find.text('FACCIO DA ME'), findsOneWidget);

    await tester.tap(find.text('LA NATURA'));
    await tester.pumpAndSettle();
    expect(find.text('La natura'), findsOneWidget);
    // Le tre modalità, sempre tutte e tre; il gioco non c'è ancora e lo dice.
    expect(find.text('Una storia'), findsOneWidget);
    expect(find.text('Un gioco'), findsOneWidget);
    expect(find.text('Lo provo'), findsOneWidget);
    expect(find.text('Arriva presto'), findsOneWidget);

    // La cosa da provare si apre senza aver letto la storia.
    await tester.tap(find.text('STORIA GOCCIA').last);
    await tester.pumpAndSettle();
    expect(find.text('Fare il respiro del vulcano.'), findsOneWidget);

    await tester.tap(find.text('Indietro'));
    await tester.pumpAndSettle();
    expect(find.text('La natura'), findsOneWidget);
    expect(find.text('Fare il respiro del vulcano.'), findsNothing);
  });
}
