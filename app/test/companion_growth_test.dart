import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

/// Solo la parte di LocalDb che usano profili e gesti.
class _FakeDb implements LocalDb {
  _FakeDb(this.profile);
  ChildProfile profile;
  final List<GestureEntry> done = [];

  @override
  Future<List<ChildProfile>> profiles() async => [profile];
  @override
  Future<void> updateProfile(ChildProfile p) async => profile = p;
  @override
  Future<List<GestureEntry>> gestures(int profileId) async => done.where((g) => g.profileId == profileId).toList();
  @override
  Future<void> addGesture(GestureEntry g) async => done.add(g);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRepo implements StoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const base = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b5to7, companion: CompanionId.tango);

  test('il compagno cresce con i gesti, non con le storie', () {
    expect(base.copyWith(storiesCompleted: 20).companionStage, 0);
    expect(base.copyWith(gesturesDone: 3).companionStage, 1);
    expect(base.copyWith(gesturesDone: 6).companionStage, 2);
    expect(base.copyWith(gesturesDone: 12).companionStage, 3);
  });

  test('chi era già cresciuto con le storie non torna indietro', () {
    final legacy = ChildProfile.fromRow({...base.toRow(), 'stage_floor': 2, 'gestures_done': 0});
    expect(legacy.companionStage, 2);
    expect(legacy.gesturesToNextStage, 12);
    expect(legacy.copyWith(gesturesDone: 12).companionStage, 3);
  });

  test('una riga senza le colonne nuove (backup v3) parte da zero', () {
    final row = base.toRow()
      ..remove('gestures_done')
      ..remove('stage_floor');
    final p = ChildProfile.fromRow(row);
    expect(p.gesturesDone, 0);
    expect(p.companionStage, 0);
  });

  test('gesti che mancano alla prossima tappa', () {
    expect(base.gesturesToNextStage, 3);
    expect(base.copyWith(gesturesDone: 4).gesturesToNextStage, 2);
    expect(base.copyWith(gesturesDone: 12).gesturesToNextStage, isNull);
  });

  test('lo stesso gesto conta una volta al giorno', () async {
    final db = _FakeDb(base);
    final state = AppState(
      db: db,
      repo: _NoRepo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
    );
    await state.init();
    final day = DateTime(2026, 10, 13, 9);

    expect(await state.recordGesture(base, 'albero-silenzioso', now: day), isTrue);
    expect(await state.recordGesture(base, 'albero-silenzioso', now: day.add(const Duration(hours: 3))), isFalse);
    expect(await state.recordGesture(base, 'notte-lucciole', now: day), isTrue);
    expect(await state.recordGesture(base, 'albero-silenzioso', now: day.add(const Duration(days: 1))), isTrue);

    expect(db.profile.gesturesDone, 3);
    expect(state.currentProfile!.companionStage, 1);
  });
}
