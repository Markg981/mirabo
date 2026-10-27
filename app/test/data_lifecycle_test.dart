import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/models/nature_day.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/ui/startup_failure.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Ciclo dei dati (analisi 8, docs/release-engineering.md): chiave sparita,
/// database di una versione più recente, salvataggi che non riescono, chiusura
/// forzata e ripresa. Database vero (SQLite via FFI, senza cifratura).
class _NoRepo implements StoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  late Directory tmp;
  // Su Windows un file aperto non si cancella: si chiude tutto prima.
  final opened = <Database>[];

  setUp(() => tmp = Directory.systemTemp.createTempSync('mirabo_life'));
  tearDown(() async {
    LocalDb.onSaveError = null;
    for (final db in opened) {
      if (db.isOpen) await db.close();
    }
    opened.clear();
    tmp.deleteSync(recursive: true);
  });

  Future<Database> openCurrent(String path, {bool single = true}) async {
    final db = await factory.openDatabase(path,
        options: OpenDatabaseOptions(
          version: LocalDb.schemaVersion,
          onConfigure: LocalDb.configure,
          onCreate: LocalDb.createSchema,
          onUpgrade: LocalDb.upgradeSchema,
          onDowngrade: LocalDb.refuseDowngrade,
          singleInstance: single,
        ));
    opened.add(db);
    return db;
  }

  Future<AppState> appOn(Database raw) async {
    final state = AppState(
      db: LocalDb.forTest(raw),
      repo: _NoRepo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
      region: () => 'IT',
    );
    await state.init();
    return state;
  }

  const emma = ChildProfile(id: 0, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo, language: 'it');

  group('chiave del database', () {
    Future<({String value, bool reset})> resolve(String path, {String? stored, List<String>? written}) =>
        LocalDb.resolveKey(path, read: () async => stored, write: (k) async => written?.add(k));

    test('primo avvio: chiave nuova, salvata, nessun reset', () async {
      final written = <String>[];
      final key = await resolve('${tmp.path}/mirabo.db', written: written);
      expect(key.reset, isFalse);
      expect(written, [key.value]);
    });

    test('chiave presente: il file resta com\'è e la chiave non si riscrive', () async {
      final f = File('${tmp.path}/mirabo.db')..writeAsBytesSync(List.generate(64, (i) => i));
      final written = <String>[];
      final key = await resolve(f.path, stored: 'k', written: written);
      expect((key.value, key.reset), ('k', false));
      expect(written, isEmpty);
      expect(f.existsSync(), isTrue);
    });

    List<File> quarantined() =>
        tmp.listSync().whereType<File>().where((e) => e.path.contains('mirabo.db${LocalDb.quarantinePrefix}')).toList();

    test('file cifrato senza chiave: in quarantena (una sola), si riparte da zero con reset vero', () async {
      final rnd = Random(1);
      final bytes = List.generate(4096, (_) => rnd.nextInt(256));
      final f = File('${tmp.path}/mirabo.db')..writeAsBytesSync(bytes);
      File('${f.path}-wal').writeAsStringSync('x');
      File('${f.path}${LocalDb.quarantinePrefix}1').writeAsStringSync('vecchia');
      final key = await resolve(f.path);
      expect(key.reset, isTrue);
      expect(f.existsSync(), isFalse);
      expect(File('${f.path}-wal').existsSync(), isFalse);
      final q = quarantined();
      expect(q, hasLength(1));
      expect(q.single.readAsBytesSync(), bytes);
    });

    test('secure storage che non risponde: errore all\'avvio, il database non si tocca', () async {
      final f = File('${tmp.path}/mirabo.db')..writeAsBytesSync(List.generate(64, (i) => 255 - i));
      await expectLater(
        LocalDb.resolveKey(f.path, read: () async => throw Exception('keystore'), write: (_) async {}),
        throwsException,
      );
      expect(f.existsSync(), isTrue);
    });
  });

  test('database di una versione più recente: non si apre e i dati restano', () async {
    final path = '${tmp.path}/mirabo.db';
    final newer = await factory.openDatabase(path,
        options: OpenDatabaseOptions(
          version: LocalDb.schemaVersion + 1,
          onConfigure: LocalDb.configure,
          onCreate: LocalDb.createSchema,
        ));
    await newer.insert('settings', {'key': 'k', 'value': 'v'});
    await newer.close();

    await expectLater(openCurrent(path), throwsA(isA<DatabaseTooNewException>()));
    final again = await factory.openDatabase(path, options: OpenDatabaseOptions(readOnly: true));
    expect(await again.query('settings', where: "key = 'k'"), hasLength(1));
    await again.close();
  });

  group('salvataggio non riuscito', () {
    test('l\'errore torna al chiamante e passa da onSaveError, una volta', () async {
      final raw = await openCurrent('${tmp.path}/mirabo.db');
      final db = LocalDb.forTest(raw);
      final seen = <Object>[];
      LocalDb.onSaveError = seen.add;
      await raw.close();
      await expectLater(db.setSetting('k', 'v'), throwsA(isA<DatabaseException>()));
      await expectLater(db.updateProfile(emma), throwsA(isA<DatabaseException>()));
      expect(seen, hasLength(2));
    });

    test('l\'app lo dice e non dichiara un successo: emisfero e onboarding restano com\'erano', () async {
      final raw = await openCurrent('${tmp.path}/mirabo.db');
      final state = await appOn(raw);
      expect(state.saveFailure, isNull);
      final before = state.hemisphere;
      await raw.close();

      await expectLater(state.setHemisphere(Hemisphere.values.firstWhere((h) => h != before)), throwsA(anything));
      expect(state.hemisphere, before);
      await expectLater(state.finishOnboarding(), throwsA(anything));
      expect(state.onboardingSeen, isFalse);
      expect(state.saveFailure, isNotNull);

      state.dismissSaveFailure();
      expect(state.saveFailure, isNull);
    });
  });

  test('chiusura forzata o memoria finita: al riavvio profilo, punto della storia e mensola ci sono', () async {
    final path = '${tmp.path}/mirabo.db';
    final first = await appOn(await openCurrent(path));
    await first.createProfile(emma);
    final p = first.currentProfile!;
    await first.saveStoryPosition(p, 'lia', 3);
    await first.setShelf(p, ['story:lia']);
    // Il processo muore senza chiudere niente: si riapre con un'altra connessione.
    final second = await appOn(await openCurrent(path, single: false));
    final again = second.profiles.single;
    expect(again.name, 'Emma');
    expect(again.shelf, ['story:lia']);
    expect(await second.storyPosition(again, 'lia'), 3);
    // Si riparte "da solo": "insieme" non sopravvive a un riavvio.
    expect(second.mode, SessionMode.alone);
  });

  test('cambio fascia: il punto della storia resta della fascia di prima e non si eredita', () async {
    final state = await appOn(await openCurrent('${tmp.path}/mirabo.db'));
    await state.createProfile(emma);
    final p = state.currentProfile!;
    await state.saveStoryPosition(p, 'lia', 5);
    await state.updateProfile(p.copyWith(ageBand: AgeBand.b6to7));
    final moved = state.currentProfile!;
    expect(moved.ageBand, AgeBand.b6to7);
    expect(await state.storyPosition(moved, 'lia'), 0);
    expect(await state.storyPosition(moved.copyWith(ageBand: AgeBand.b3to5), 'lia'), 5);
  });

  test('ripartito da zero: l\'avviso c\'è finché l\'onboarding non è fatto', () async {
    final raw = await openCurrent('${tmp.path}/mirabo.db');
    await raw.insert('settings', {'key': LocalDb.storageResetKey, 'value': '2026-10-15T09:00:00.000'});
    final state = await appOn(raw);
    expect(state.storageResetAt, DateTime(2026, 10, 15, 9));
    await state.finishOnboarding();
    expect(state.storageResetAt, isNull);
    expect(await state.db.setting(LocalDb.storageResetKey), isNull);
  });

  group('avvio non riuscito', () {
    testWidgets('si dice che non è stato cancellato niente e si può riprovare', (tester) async {
      var retried = 0;
      await tester.pumpWidget(StartupFailureApp(error: Exception('keystore'), onRetry: () => retried++));
      await tester.pumpAndSettle();
      expect(find.textContaining('Nothing has been deleted'), findsOneWidget);
      await tester.tap(find.byKey(const Key('startup-retry')));
      expect(retried, 1);
    });

    testWidgets('database più recente: si chiede di aggiornare, niente "riprova"', (tester) async {
      await tester.pumpWidget(StartupFailureApp(error: const DatabaseTooNewException(14, 13), onRetry: () {}));
      await tester.pumpAndSettle();
      expect(find.textContaining('update the app'), findsOneWidget);
      expect(find.byKey(const Key('startup-retry')), findsNothing);
    });

    testWidgets('percorso adulto: avviso, conferma esplicita e solo allora azzera e riparte', (tester) async {
      var retried = 0, erased = 0;
      await tester.pumpWidget(StartupFailureApp(
        error: const FormatException('json'),
        onRetry: () => retried++,
        onErase: () async => erased++,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('startup-error-kind')), findsOneWidget);
      expect(find.byKey(const Key('startup-erase')), findsNothing);
      await tester.tap(find.byKey(const Key('startup-adult')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('startup-erase-warning')), findsOneWidget);
      await tester.tap(find.byKey(const Key('startup-erase')), warnIfMissed: false);
      expect(erased, 0);
      await tester.ensureVisible(find.byKey(const Key('startup-erase-confirm')));
      await tester.tap(find.byKey(const Key('startup-erase-confirm')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('startup-erase')));
      await tester.tap(find.byKey(const Key('startup-erase')));
      await tester.pumpAndSettle();
      expect(erased, 1);
      expect(retried, 1);
    });

    testWidgets('azzeramento fallito: lo si dice e non si riparte', (tester) async {
      var retried = 0;
      await tester.pumpWidget(StartupFailureApp(
        error: Exception('x'),
        onRetry: () => retried++,
        onErase: () async => throw Exception('disk'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('startup-adult')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('startup-erase-confirm')));
      await tester.tap(find.byKey(const Key('startup-erase-confirm')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('startup-erase')));
      await tester.tap(find.byKey(const Key('startup-erase')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('startup-erase-failed')), findsOneWidget);
      expect(retried, 0);
    });
  });
}
