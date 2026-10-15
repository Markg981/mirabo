import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/models/activity.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

class _FakeDb implements LocalDb {
  _FakeDb(this.profile);
  ChildProfile profile;
  final settings = <String, String>{};
  final progresses = <String, ActivityProgress>{};
  final saved = <ActivityProgress>[];
  List<Map<String, Object?>> roundRows = [];

  @override
  Future<List<ChildProfile>> profiles() async => [profile];
  @override
  Future<String?> setting(String key) async => settings[key];
  @override
  Future<void> setSetting(String key, String value) async => settings[key] = value;
  @override
  Future<void> updateProfile(ChildProfile p) async => profile = p;
  @override
  Future<void> addRounds(int profileId, Activity a, List<RoundResult> r) async {}
  @override
  Future<ActivityProgress> progress(int profileId, String activityId) async =>
      progresses[activityId] ?? ActivityProgress(profileId: profileId, activityId: activityId);
  @override
  Future<void> saveProgress(ActivityProgress p) async {
    progresses[p.activityId] = p;
    saved.add(p);
  }

  @override
  Future<List<Map<String, Object?>>> rounds(int profileId, {required DateTime from, DateTime? to}) async => roundRows;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repo implements StoryRepository {
  final acts = <Activity>[];
  @override
  List<Activity> get activities => acts;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Activity _activity(String id, ActivityType type) => Activity(
      id: id,
      version: 1,
      title: id,
      area: ActivityArea.values.first,
      skill: 's',
      type: type,
      ageBands: {AgeBand.b6to7},
      togetherSuggested: false,
      intro: CompanionLines.fromJson({'bo': 'a', 'pilu': 'a', 'tango': 'a'}),
      outro: CompanionLines.fromJson({'bo': 'a', 'pilu': 'a', 'tango': 'a'}),
      offscreen: '',
      levels: const [{}, {}, {}],
    );

void main() {
  const base = ChildProfile(id: 1, name: 'Ada', ageBand: AgeBand.b6to7, companion: CompanionId.bo);
  const round = RoundResult();

  Future<(AppState, _FakeDb, _Repo)> make() async {
    final db = _FakeDb(base);
    final repo = _Repo();
    final state = AppState(
      db: db,
      repo: repo,
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
    );
    await state.init();
    return (state, db, repo);
  }

  test('il livello non cambia da solo: i round non portano né successi né errori', () async {
    final (state, db, _) = await make();
    final a = _activity('x', ActivityType.count);
    const before = ActivityProgress(profileId: 1, activityId: 'x', level: 2);
    await state.recordActivity(a, before, [round, round, round, round, round, round]);
    expect(db.saved.single.level, 2);
    expect(db.saved.single.sessions, 1);
    await state.recordActivity(a, before, [round, round, round]);
    expect(db.saved.last.level, 2);
  });

  test('più semplice / più sfida cambiano solo il livello e si annullano; i bordi reggono', () async {
    final (state, db, _) = await make();
    const p = ActivityProgress(profileId: 1, activityId: 'x', level: 2, sessions: 4);
    final harder = await state.setActivityLevel(p, 3, 3);
    expect(harder.level, 3);
    expect(harder.sessions, 4);
    final undone = await state.setActivityLevel(harder, harder.level - 1, 3);
    expect(undone.level, 2);
    expect((await state.setActivityLevel(harder, 4, 3)).level, 3);
    expect((await state.setActivityLevel(p.copyWith(level: 1), 0, 3)).level, 1);
    // Non toccano né il profilo né la fascia né il profilo di interazione.
    expect(db.profile, base);
  });

  test('nessuna promozione di fascia al compleanno: la fascia e il profilo restano quelli scelti', () {
    final p = ChildProfile.fromRow(base.toRow());
    // Il profilo non ha data di nascita: nessuna rilettura può spostare la fascia.
    expect(p.toRow().keys.where((k) => k.contains('birth') || k.contains('born')), isEmpty);
    expect(p.ageBand, AgeBand.b6to7);
    expect(p.interaction, InteractionProfile.forAge(AgeBand.b6to7));
    expect(ChildProfile.fromRow(p.copyWith(name: 'Ada').toRow()).ageBand, AgeBand.b6to7);
    // La fascia cambia solo se lo decide il genitore.
    expect(p.copyWith(ageBand: AgeBand.b8to10).ageBand, AgeBand.b8to10);
  });
}
