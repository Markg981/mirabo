import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/data/retention.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// La potatura all'apertura: oltre la finestra si toglie, dentro si tiene
/// (docs/compliance/retention.md).
void main() {
  sqfliteFfiInit();
  late Directory tmp;
  late Database db;
  final now = DateTime(2026, 10, 27, 12);

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('mirabo_ret');
    db = await databaseFactoryFfi.openDatabase('${tmp.path}/t.db',
        options: OpenDatabaseOptions(
          version: LocalDb.schemaVersion,
          onConfigure: LocalDb.configure,
          onCreate: LocalDb.createSchema,
        ));
    await db.insert('profiles', {
      'id': 1,
      'name': 'Lia',
      'age_band': '6-7',
      'companion': 'bo',
      'enabled_worlds': 'emozioni',
    });
  });
  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  Future<List<String>> keys() async =>
      [for (final r in await db.query('settings', orderBy: 'key')) r['key'] as String];

  test('i contatori d\'uso oltre 90 giorni si tolgono, gli altri restano', () async {
    for (final k in ['usage.1.2026-07-01', 'usage.1.2026-07-29', 'usage.1.2026-10-26', 'parent_notes_1']) {
      await db.insert('settings', {'key': k, 'value': '5'});
    }
    await pruneExpired(db, now: now);
    // 90 giorni prima del 27/10 è il 29/07: quel giorno resta.
    expect(await keys(), ['parent_notes_1', 'usage.1.2026-07-29', 'usage.1.2026-10-26']);
  });

  test('i round oltre 12 mesi si tolgono, i progressi e i round recenti restano', () async {
    await db.insert('activity_progress', {'profile_id': 1, 'activity_id': 'a', 'sessions': 9});
    for (final at in ['2025-09-01T10:00:00.000', '2026-09-01T10:00:00.000']) {
      await db.insert('activity_rounds', {'profile_id': 1, 'activity_id': 'a', 'skill': 's', 'at': at});
    }
    await pruneExpired(db, now: now);
    final rounds = await db.query('activity_rounds');
    expect(rounds.map((r) => r['at']), ['2026-09-01T10:00:00.000']);
    expect(await db.query('activity_progress'), hasLength(1));
  });

  test('un errore non si solleva', () async {
    await db.close();
    await pruneExpired(db, now: now);
    db = await databaseFactoryFfi.openDatabase('${tmp.path}/t.db');
  });
}
