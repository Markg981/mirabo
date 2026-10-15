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
  Future<String?> setting(String key) async => null;
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
  const base = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b6to7, companion: CompanionId.tango);

  final since = DateTime(2026, 10, 1);
  final fresh = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b6to7, companion: CompanionId.tango, growthSince: since);

  test("nell'MVP il compagno non cresce: né con le settimane, né con storie o gesti", () {
    final used = fresh.copyWith(storiesCompleted: 20, gesturesDone: 30);
    expect(used.companionStage, 0);
    expect(ChildProfile.fromRow({...used.toRow(), 'growth_since': DateTime(2020).toIso8601String()}).companionStage, 0);
  });

  test('chi era già cresciuto non torna indietro', () {
    final legacy = ChildProfile.fromRow({...fresh.toRow(), 'stage_floor': 2});
    expect(legacy.companionStage, 2);
  });

  test('una riga senza le colonne nuove (backup v3) parte da zero', () {
    final row = base.toRow()
      ..remove('gestures_done')
      ..remove('stage_floor')
      ..remove('growth_since');
    final p = ChildProfile.fromRow(row);
    expect(p.gesturesDone, 0);
    expect(p.companionStage, 0);
  });

  test('cambiare compagno non perde niente: tutto resta sul profilo', () {
    final before = ChildProfile.fromRow({
      ...fresh.copyWith(storiesCompleted: 4, gesturesDone: 2, language: 'en').toRow(),
      'stage_floor': 1,
      'shelf': 'story:a,game:memory',
    });
    final after = before.copyWith(companion: CompanionId.bo);
    expect(after.companion, CompanionId.bo);
    final a = after.toRow()..remove('companion');
    final b = before.toRow()..remove('companion');
    expect(a, b);
  });

  test('lo stesso gesto si segna una volta al giorno e non fa crescere il compagno', () async {
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

    // Nessun contatore sul profilo: il compagno non cresce e niente si conta.
    expect(db.profile.gesturesDone, 0);
    expect(state.currentProfile!.companionStage, 0);
  });
}
