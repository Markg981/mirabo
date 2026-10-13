import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/parent_digest.dart';
import 'package:mirabo/models/activity.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

void main() {
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;

  Story story(String id, {String? gesture, String? card}) => Story.fromJson({
        'id': id, 'version': 1, 'title': 'Titolo $id', 'world': 'ambiente', 'topic': 'cura',
        'ageBands': {'5-7': '5-7.json'}, 'formats': ['illustrated'], 'togetherOnly': false,
        'keyPhrase': 'Frase $id', 'parentCard': 'parent.md', 'sources': [], if (gesture != null) 'gesture': gesture,
      }).withContent(variants: const {}, parentCard: card);

  Activity activity(String id) =>
      Activity.fromJson(jsonDecode(File('${root.path}/content/activities/$id/activity.json').readAsStringSync()));

  test('ogni scheda genitore, in ogni lingua, ha la sezione "Nella vita vera"', () {
    final cards = Directory('${root.path}/content/stories')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('parent.md'))
        .toList();
    expect(cards, isNotEmpty);
    for (final f in cards) {
      final text = realLifeSection(f.readAsStringSync());
      expect(text, isNotNull, reason: f.path);
      expect(text, isNot(contains('## ')), reason: f.path);
    }
  });

  test('la sezione si ferma al titolo successivo', () {
    const md = '# T\n\n## Tre domande\n\n1. a\n\n## Nella vita vera\n\nPiantate un seme.\n\n## Errori comuni\n\n- x\n';
    expect(realLifeSection(md), 'Piantate un seme.');
    expect(realLifeSection('# T\n\n## Altro\n\ny\n'), isNull);
  });

  group("un'idea per oggi", () {
    final now = DateTime(2026, 10, 13, 18);
    final travaso = activity('travaso-secco');
    final versare = activity('versare-acqua');
    final foglia = story('foglia', card: '## Nella vita vera\n\nRaccogliete una foglia.');
    final stories = {foglia.id: foglia};
    String at(int daysAgo) => now.subtract(Duration(days: daysAgo)).toIso8601String();
    DiaryEntry read(String id, int daysAgo) => DiaryEntry(
        profileId: 1, storyId: id, mode: SessionMode.together, completed: true, when: now.subtract(Duration(days: daysAgo)));
    List<DailyIdea> ideas({
      List<DiaryEntry> diary = const [],
      List<Map<String, Object?>> rounds = const [],
      List<ProposedIdea> history = const [],
      DateTime? when,
    }) =>
        ideasFor(
          now: when ?? now,
          band: AgeBand.b3to5,
          diary: diary,
          rounds: rounds,
          history: history,
          story: (id) => stories[id],
          activities: [travaso, versare],
        );

    test('una presentazione segnata "rifarla" ieri viene prima di tutto', () {
      final list = ideas(
        diary: [read('foglia', 0)],
        rounds: [{'activity_id': 'versare-acqua', 'choice': 'presentation=repeat', 'at': at(1)}],
      );
      expect(list.first.key, 'activity:versare-acqua');
      expect(list.first.reason, IdeaReason.repeat);
      expect(list[1].key, 'story:foglia');
    });

    test('senza altri segnali, una storia finita ieri porta la sua "Nella vita vera"', () {
      final list = ideas(diary: [read('foglia', 1)]);
      expect(list.first, isA<StoryIdea>());
      expect((list.first as StoryIdea).text, 'Raccogliete una foglia.');
      expect(list.first.reason, IdeaReason.recentStory);
      expect(ideas(diary: [read('foglia', 4)]).whereType<StoryIdea>(), isEmpty);
    });

    test('fatta con te ma mai da solo, poi nuova nella capacità preferita', () {
      final list = ideas(rounds: [
        {'activity_id': 'travaso-secco', 'choice': 'presentation=done', 'at': at(20)},
      ]);
      expect(list.first.key, 'activity:travaso-secco');
      expect(list.first.reason, IdeaReason.tryAlone);
      expect(list[1].key, 'activity:versare-acqua');
      expect(list[1].reason, IdeaReason.capacity);
      final alone = ideas(rounds: [
        {'activity_id': 'travaso-secco', 'choice': 'presentation=done', 'at': at(20)},
        {'activity_id': 'travaso-secco', 'choice': 'presentation=alone', 'at': at(10)},
      ]);
      expect(alone.first.key, 'activity:versare-acqua');
    });

    test('la stessa idea non torna entro 14 giorni', () {
      final yesterday = (day: ideaDay(now.subtract(const Duration(days: 1))), key: 'story:foglia');
      expect(ideas(diary: [read('foglia', 1)], history: [yesterday]).map((i) => i.key), isNot(contains('story:foglia')));
      final old = (day: ideaDay(now.subtract(const Duration(days: 14))), key: 'activity:travaso-secco');
      expect(ideas(history: [old]).first.key, 'activity:travaso-secco');
      final recent = (day: ideaDay(now.subtract(const Duration(days: 13))), key: 'activity:travaso-secco');
      expect(ideas(history: [recent]).first.key, 'activity:versare-acqua');
    });

    test('se il bambino chiede di rifarla dopo la proposta, torna', () {
      final proposed = (day: ideaDay(now.subtract(const Duration(days: 3))), key: 'activity:versare-acqua');
      final list = ideas(
        rounds: [{'activity_id': 'versare-acqua', 'choice': 'presentation=repeat', 'at': at(2)}],
        history: [proposed],
      );
      expect(list.first.key, 'activity:versare-acqua');
    });

    test("riaprendo lo stesso giorno, l'idea non cambia anche se cambiano i dati", () {
      final today = (day: ideaDay(now), key: 'activity:travaso-secco');
      final list = ideas(
        diary: [read('foglia', 0)],
        rounds: [{'activity_id': 'versare-acqua', 'choice': 'presentation=repeat', 'at': at(0)}],
        history: [today],
      );
      expect(list.first.key, 'activity:travaso-secco');
      expect(list.skip(1).map((i) => i.key), ['activity:versare-acqua', 'story:foglia']);
    });

    test('proposte tutte di recente: si ricomincia invece di restare senza idee', () {
      final history = [
        for (final k in ['activity:travaso-secco', 'activity:versare-acqua'])
          (day: ideaDay(now.subtract(const Duration(days: 2))), key: k),
      ];
      expect(ideas(history: history), hasLength(2));
    });
  });

  test('una presentazione porta con sé i materiali del primo livello', () {
    final home = ideasFor(
      now: DateTime(2026, 10, 13),
      band: AgeBand.b3to5,
      diary: const [],
      rounds: const [],
      history: const [],
      story: (_) => null,
      activities: [activity('travaso-secco')],
    );
    expect((home.single as HomeIdea).materials, isNotEmpty);
  });

  test('il racconto della settimana guarda solo gli ultimi 7 giorni', () {
    final now = DateTime(2026, 10, 13, 18);
    final stories = {for (final s in [story('a', gesture: 'Gesto A'), story('b'), story('vecchia')]) s.id: s};
    final travaso = activity('travaso-secco');
    DiaryEntry read(String id, int daysAgo, SessionMode mode) => DiaryEntry(
        profileId: 1, storyId: id, mode: mode, completed: true, when: now.subtract(Duration(days: daysAgo)));
    final week = WeekDigest.build(
      now: now,
      diary: [
        read('a', 1, SessionMode.together),
        read('a', 3, SessionMode.alone),
        read('b', 2, SessionMode.together),
        read('vecchia', 10, SessionMode.together),
      ],
      gestureEntries: [
        GestureEntry(profileId: 1, storyId: 'a', when: now.subtract(const Duration(days: 1))),
        GestureEntry(profileId: 1, storyId: 'a', when: now.subtract(const Duration(days: 2))),
      ],
      rounds: [
        {'activity_id': 'travaso-secco', 'choice': 'presentation=alone'},
        {'activity_id': 'versare-acqua', 'choice': 'presentation=watched'},
      ],
      story: (id) => stories[id],
      activity: (id) => id == travaso.id ? travaso : null,
    );
    expect(week.stories.map((s) => s.id), ['a', 'b']);
    expect(week.sessions, 3);
    expect(week.together, 2);
    expect(week.gestures.map((s) => s.id), ['a']);
    expect(week.home.map((a) => a.id), ['travaso-secco']);
    expect(week.isEmpty, isFalse);
  });

  test('una settimana senza niente è vuota, non un errore', () {
    final week = WeekDigest.build(
      now: DateTime(2026, 10, 13),
      diary: const [],
      gestureEntries: const [],
      rounds: const [],
      story: (_) => null,
      activity: (_) => null,
    );
    expect(week.isEmpty, isTrue);
  });
}
