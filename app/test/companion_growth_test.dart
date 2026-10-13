import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

/// Solo la parte di LocalDb che serve alla crescita del compagno.
class _FakeDb implements LocalDb {
  _FakeDb(this.saved);
  ChildProfile saved;
  final diaryRows = <DiaryEntry>[];

  @override
  Future<List<ChildProfile>> profiles() async => [saved];
  @override
  Future<void> updateProfile(ChildProfile p) async => saved = p;
  @override
  Future<void> addDiaryEntry(DiaryEntry e) async => diaryRows.add(e);
  @override
  Future<Set<String>> completedStoryIds(int profileId) async =>
      {for (final e in diaryRows) if (e.completed && e.profileId == profileId) e.storyId};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Story _story(String id, String world) => Story.fromJson({
      'id': id, 'version': 1, 'title': id, 'world': world, 'topic': 't',
      'ageBands': {'5-7': '5-7.json'}, 'formats': ['illustrated'], 'togetherOnly': false,
      'keyPhrase': 'k', 'parentCard': 'parent.md', 'sources': [],
    });

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('le soglie di crescita sono quelle di companions.json', () {
    final root = Directory.current.path.endsWith('app') ? Directory.current.parent.path : Directory.current.path;
    final json = jsonDecode(File('$root/content/companions/companions.json').readAsStringSync()) as Map<String, dynamic>;
    for (final c in (json['companions'] as List).cast<Map<String, dynamic>>()) {
      final companion = Companion.fromJson(c);
      expect(companion.growthAfter, [0, ...ChildProfile.growthThresholds], reason: companion.name);
      expect(companion.growth, hasLength(ChildProfile.growthThresholds.length + 1));
    }
  });

  test('stadio e storie che mancano al prossimo', () {
    const p = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b5to7, companion: CompanionId.bo);
    expect([for (final n in [0, 2, 3, 5, 6, 11, 12, 40]) p.copyWith(storiesCompleted: n).companionStage],
        [0, 0, 1, 1, 2, 2, 3, 3]);
    expect(p.storiesToNextStage, 3);
    expect(p.copyWith(storiesCompleted: 4).storiesToNextStage, 2);
    expect(p.copyWith(storiesCompleted: 12).storiesToNextStage, isNull);
  });

  test('il momento della crescita arriva una volta sola, al cambio di stadio', () async {
    final db = _FakeDb(const ChildProfile(id: 7, name: 'Emma', ageBand: AgeBand.b5to7, companion: CompanionId.tango, storiesCompleted: 1));
    final state = AppState(db: db, repo: StoryRepository());
    await state.init();
    final story = _story('ruscello', 'ambiente');

    await state.recordStory(story, completed: true);
    expect(state.pendingGrowth, isNull, reason: '2 storie: ancora stadio 0');

    await state.recordStory(story, completed: false);
    expect(state.pendingGrowth, isNull, reason: 'una storia lasciata a metà non conta');

    await state.recordStory(story, completed: true);
    final g = state.takeGrowth(state.currentProfile!);
    expect((g?.from, g?.to), (0, 1));
    expect(state.takeGrowth(state.currentProfile!), isNull);
    expect(db.saved.storiesCompleted, 3);
  });

  test('la tana di Tango si riempie dei mondi delle storie finite', () async {
    final db = _FakeDb(const ChildProfile(id: 7, name: 'Emma', ageBand: AgeBand.b5to7, companion: CompanionId.tango));
    final state = AppState(db: db, repo: StoryRepository());
    await state.init();
    expect(state.worldsFound(state.currentProfile!), isEmpty);

    await state.recordStory(_story('a', 'emozioni'), completed: true);
    await state.recordStory(_story('b', 'sicurezza'), completed: false);
    expect(state.worldsFound(state.currentProfile!), {World.emozioni});
  });
}
