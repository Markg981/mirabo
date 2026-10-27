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

  final settings = <String, String>{};
  @override
  Future<String?> setting(String key) async => settings[key];
  @override
  Future<void> setSetting(String key, String value) async => settings[key] = value;
  @override
  Future<void> removeSetting(String key) async => settings.remove(key);
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
  Future<(AppState, Future<void> Function(Duration))> start(WidgetTester tester, ChildProfile p, {_FakeDb? db, DateTime? at}) async {
    var now = at ?? DateTime(2026, 10, 13, 16);
    final state = AppState(
      db: db ?? _FakeDb(p),
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
    final (state, advance) = await start(tester, alone);
    await state.setMode(SessionMode.together);
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
    final (state, advance) = await start(tester, alone);
    await state.setMode(SessionMode.together);
    await advance(const Duration(minutes: 18));
    expect(state.windingDown, isFalse);
  });

  testWidgets('"insieme" non sopravvive alla chiusura: all avvio si parte da "da solo"', (tester) async {
    final (state, _) = await start(tester, alone.copyWith(lastMode: SessionMode.together, aloneSessionMinutes: 0));
    expect(state.mode, SessionMode.alone);
  });

  testWidgets('"insieme" scade dopo 30 minuti in background, non prima', (tester) async {
    final (state, advance) = await start(tester, alone.copyWith(aloneSessionMinutes: 0));
    await state.setMode(SessionMode.together);
    state.appHidden();
    await advance(const Duration(minutes: 29));
    state.appResumed();
    await tester.pump(const Duration(milliseconds: 1));
    expect(state.mode, SessionMode.together);

    state.appHidden();
    await advance(AppState.togetherLapse);
    state.appResumed();
    await tester.pump(const Duration(milliseconds: 1));
    expect(state.mode, SessionMode.alone);
  });

  testWidgets('cambiando bambino "insieme" non passa all altro', (tester) async {
    final (state, _) = await start(tester, alone.copyWith(aloneSessionMinutes: 0));
    await state.setMode(SessionMode.together);
    await state.selectProfile(state.currentProfile!);
    expect(state.mode, SessionMode.together);
    await state.selectProfile(const ChildProfile(id: 2, name: 'U', ageBand: AgeBand.b3to5, companion: CompanionId.bo, aloneSessionMinutes: 0));
    expect(state.mode, SessionMode.alone);
  });

  group('riavvio dell app', () {
    // Primo avvio, poi l'app va in background a +12 min e viene chiusa; la
    // seconda istanza riparte [gap] dopo, sullo stesso database.
    // Il processo muore: niente timer in sospeso. Il fine test lo smaltisce di nuovo.
    Future<void> state0(AppState s) async {
      s.setMode(SessionMode.together); // ferma i timer senza dispose
    }

    Future<(AppState, Future<void> Function(Duration))> restart(WidgetTester tester, Duration gap) async {
      final db = _FakeDb(alone);
      final (first, advance) = await start(tester, alone, db: db);
      await advance(const Duration(minutes: 12));
      first.appHidden();
      final saved = Map.of(db.settings);
      await state0(first);
      db.settings..clear()..addAll(saved);
      await tester.pump();
      final second = await start(tester, alone, db: db, at: DateTime(2026, 10, 13, 16, 12).add(gap));
      return second;
    }

    testWidgets('entro 10 minuti il conto continua: il limite scade con quello di prima', (tester) async {
      final (state, advance) = await restart(tester, const Duration(minutes: 5));
      await advance(const Duration(minutes: 2));
      expect(state.aloneGoodbye, isFalse);
      await advance(const Duration(minutes: 1));
      // 12 + 5 + 3 = 20 minuti dall'inizio: il limite di prima, non uno nuovo.
      expect(state.aloneGoodbye, isTrue);
    });

    testWidgets('oltre 10 minuti la sessione riparte da zero', (tester) async {
      final (state, advance) = await restart(tester, const Duration(minutes: 11));
      await advance(const Duration(minutes: 19));
      expect(state.aloneGoodbye, isFalse);
      await advance(const Duration(minutes: 1));
      expect(state.aloneGoodbye, isTrue);
    });

    testWidgets('al ritorno in primo piano il limite scaduto in background scatta subito', (tester) async {
      var now = DateTime(2026, 10, 13, 16);
      final state = AppState(
        db: _FakeDb(alone),
        repo: _NoRepo(),
        nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
        clock: () => now,
      );
      await state.init();
      addTearDown(state.dispose);
      state.appHidden();
      now = now.add(const Duration(minutes: 25)); // il Timer sospeso non è scattato
      expect(state.aloneGoodbye, isFalse);
      state.appResumed();
      await tester.pump(const Duration(milliseconds: 1));
      expect(state.aloneGoodbye, isTrue);
    });

    testWidgets('un gioco aperto al limite non viene interrotto', (tester) async {
      final (state, advance) = await start(tester, alone);
      state.holdSession(); // GameShell è avvolto in SessionHold
      await advance(const Duration(minutes: 25));
      expect(state.aloneGoodbye, isFalse);
      state.releaseSession();
      await tester.pump();
      expect(state.aloneGoodbye, isTrue);
    });
  });
}
