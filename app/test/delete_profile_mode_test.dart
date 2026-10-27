import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

class _FakeDb implements LocalDb {
  final list = <ChildProfile>[
    const ChildProfile(id: 1, name: 'A', ageBand: AgeBand.b6to7, companion: CompanionId.bo, aloneSessionMinutes: 0),
    const ChildProfile(id: 2, name: 'B', ageBand: AgeBand.b6to7, companion: CompanionId.bo, aloneSessionMinutes: 0),
  ];
  @override
  Future<List<ChildProfile>> profiles() async => List.of(list);
  @override
  Future<void> deleteProfile(int id) async => list.removeWhere((p) => p.id == id);
  @override
  Future<String?> setting(String key) async => null;
  @override
  Future<void> setSetting(String key, String value) async {}
  @override
  Future<void> removeSetting(String key) async {}
  @override
  Future<void> updateProfile(ChildProfile p) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRepo implements StoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('eliminare il bambino corrente riporta "insieme" a "da solo"', (tester) async {
    final state = AppState(
      db: _FakeDb(),
      repo: _NoRepo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
    );
    await state.init();
    addTearDown(state.dispose);
    await state.selectProfile(state.profiles.first);
    await state.setMode(SessionMode.together);
    expect(state.mode, SessionMode.together);
    await state.deleteProfile(1);
    expect(state.currentProfile?.id, 2);
    expect(state.mode, SessionMode.alone);
  });
}
