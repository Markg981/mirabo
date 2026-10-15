import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

/// Solo la parte di LocalDb che usano i profili.
class _FakeDb implements LocalDb {
  _FakeDb(this.profile);
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

class _NoRepo implements StoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const alone = ChildProfile(
    id: 1,
    name: 'T',
    ageBand: AgeBand.b6to7,
    companion: CompanionId.tango,
    lastMode: SessionMode.alone,
    aloneSessionMinutes: 20,
  );

  // I Timer di testWidgets sono finti: tester.pump li fa scattare. L'orologio
  // dell'app avanza insieme a loro.
  Future<(AppState, Future<void> Function(Duration))> start(WidgetTester tester, ChildProfile p) async {
    var now = DateTime(2026, 10, 13, 16);
    final state = AppState(
      db: _FakeDb(p),
      repo: _NoRepo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
      clock: () => now,
    );
    await state.init();
    Future<void> advance(Duration d) async {
      now = now.add(d);
      await tester.pump(d);
    }

    addTearDown(state.dispose);
    return (state, advance);
  }

  testWidgets('allo scadere dei minuti il compagno saluta', (tester) async {
    final (state, advance) = await start(tester, alone);
    await advance(const Duration(minutes: 19));
    expect(state.aloneGoodbye, isFalse);
    await advance(const Duration(minutes: 1));
    expect(state.aloneGoodbye, isTrue);
  });

  testWidgets('mai a metà: il saluto aspetta che la storia finisca', (tester) async {
    final (state, advance) = await start(tester, alone);
    state.holdSession();
    await advance(const Duration(minutes: 25));
    expect(state.aloneGoodbye, isFalse);
    state.releaseSession();
    await tester.pump();
    expect(state.aloneGoodbye, isTrue);
  });

  testWidgets('insieme non c\'è limite', (tester) async {
    final (state, advance) = await start(tester, alone.copyWith(lastMode: SessionMode.together));
    await advance(const Duration(hours: 2));
    expect(state.aloneGoodbye, isFalse);
  });

  testWidgets('il genitore cambia modalità: il saluto sparisce, da solo riparte da zero', (tester) async {
    final (state, advance) = await start(tester, alone);
    await advance(const Duration(minutes: 20));
    expect(state.aloneGoodbye, isTrue);

    await state.setMode(SessionMode.together);
    expect(state.aloneGoodbye, isFalse);

    await state.setMode(SessionMode.alone);
    await advance(const Duration(minutes: 19));
    expect(state.aloneGoodbye, isFalse);
    await advance(const Duration(minutes: 1));
    expect(state.aloneGoodbye, isTrue);
  });

  testWidgets('i minuti cambiati dal genitore valgono per la sessione in corso', (tester) async {
    final (state, advance) = await start(tester, alone);
    await advance(const Duration(minutes: 10));
    await state.updateProfile(state.currentProfile!.copyWith(aloneSessionMinutes: 30));
    await advance(const Duration(minutes: 15));
    expect(state.aloneGoodbye, isFalse);
    await advance(const Duration(minutes: 5));
    expect(state.aloneGoodbye, isTrue);
  });

  testWidgets('preavviso: negli ultimi minuti non si propone nulla di nuovo', (tester) async {
    final (state, advance) = await start(tester, alone);
    await advance(const Duration(minutes: 16));
    expect(state.windingDown, isFalse);
    await advance(const Duration(minutes: 1));
    expect(state.windingDown, isTrue);
    expect(state.aloneGoodbye, isFalse);
    await advance(const Duration(minutes: 3));
    expect(state.aloneGoodbye, isTrue);
  });

  testWidgets('a storia aperta il preavviso resta e il saluto aspetta, senza penalità', (tester) async {
    final (state, advance) = await start(tester, alone);
    state.holdSession();
    await advance(const Duration(minutes: 30));
    expect(state.windingDown, isTrue);
    expect(state.aloneGoodbye, isFalse);
    state.releaseSession();
    await tester.pump();
    expect(state.aloneGoodbye, isTrue);
  });

  testWidgets('nessun limite (0 minuti): niente preavviso e niente saluto', (tester) async {
    final (state, advance) = await start(tester, alone.copyWith(aloneSessionMinutes: 0));
    await advance(const Duration(hours: 3));
    expect(state.windingDown, isFalse);
    expect(state.aloneGoodbye, isFalse);
  });

  testWidgets('limite breve: il preavviso parte subito', (tester) async {
    final (state, advance) = await start(tester, alone.copyWith(aloneSessionMinutes: 2));
    expect(state.windingDown, isTrue);
    await advance(const Duration(minutes: 2));
  });

  testWidgets('insieme non ci sono preavvisi', (tester) async {
    final (state, advance) = await start(tester, alone.copyWith(lastMode: SessionMode.together));
    await advance(const Duration(minutes: 18));
    expect(state.windingDown, isFalse);
  });
}
