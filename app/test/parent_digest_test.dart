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

  test("l'idea del giorno resta la stessa nella giornata e cambia il giorno dopo", () {
    final ideas = ideasFor(
      finished: [story('a', card: '## Nella vita vera\n\nIdea A'), story('b', card: '## Altro\n\nniente')],
      activities: [activity('travaso-secco'), activity('versare-acqua')],
      band: AgeBand.b3to5,
    );
    expect(ideas.first, isA<StoryIdea>());
    expect((ideas.first as StoryIdea).text, 'Idea A');
    expect(ideas.whereType<StoryIdea>().length, 1);
    final morning = ideaForDay(ideas, DateTime(2026, 10, 13, 8));
    expect(ideaForDay(ideas, DateTime(2026, 10, 13, 21)), same(morning));
    expect(ideaForDay(ideas, DateTime(2026, 10, 14, 8)), isNot(same(morning)));
    expect(ideaForDay(ideas, DateTime(2026, 10, 13), skip: 1), same(ideaForDay(ideas, DateTime(2026, 10, 14))));
    expect(ideaForDay(const [], DateTime(2026, 10, 13)), isNull);
  });

  test('una presentazione porta con sé i materiali del primo livello', () {
    final home = ideasFor(finished: const [], activities: [activity('travaso-secco')], band: AgeBand.b3to5);
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
