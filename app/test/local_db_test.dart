import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Il database vero (SQLite via FFI, senza cifratura): cancellazione di un
/// profilo, migrazione v13 e ripristino di un backup di prima
/// (analisi 7C, docs/privacy/mvp-data.md).
void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('mirabo_db'));
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<Database> openCurrent(String path) => factory.openDatabase(path,
      options: OpenDatabaseOptions(
        version: LocalDb.schemaVersion,
        onConfigure: LocalDb.configure,
        onCreate: LocalDb.createSchema,
        onUpgrade: LocalDb.upgradeSchema,
      ));

  Map<String, Object?> profile(int id, String name) => {
        'id': id,
        'name': name,
        'age_band': '6-7',
        'companion': 'bo',
        'enabled_worlds': 'emozioni',
      };

  /// Una riga per ogni tabella del bambino, con le colonne di oggi.
  Future<void> fill(Database db, int id) async {
    const at = '2026-10-10T10:00:00.000';
    await db.insert('diary', {'profile_id': id, 'story_id': 'lia-rabbia', 'mode': 'alone', 'completed': 1, 'at': at});
    await db.insert('activity_progress', {'profile_id': id, 'activity_id': 'a', 'level': 2});
    await db.insert('activity_rounds', {'profile_id': id, 'activity_id': 'a', 'skill': 's', 'choice': 'project=idea', 'at': at});
    await db.insert('gestures', {'profile_id': id, 'story_id': 'lia-rabbia', 'at': at});
    await db.insert('made_stories', {
      'profile_id': id,
      'who': 'w',
      'place': 'p',
      'problem': 'x',
      'feeling': 'f',
      'helper': 'h',
      'ending': 'e',
      'at': at,
    });
    await db.insert('nature_days', {'profile_id': id, 'day': '2026-10-10', 'seen': 'leaf'});
    await db.insert('shelf_history', {'profile_id': id, 'item_key': 'k', 'from_at': at});
    await db.insert('daily_ideas', {'profile_id': id, 'day': '2026-10-10', 'idea_key': 'i'});
    for (final key in [
      'resume.story.$id.lia-rabbia.6-7',
      'resume.drawing.$id',
      'usage.$id.2026-10-10',
      'parent_notes_$id',
      'dismissed_ideas.$id',
    ]) {
      await db.insert('settings', {'key': key, 'value': 'x'});
    }
  }

  int firstInt(List<Map<String, Object?>> rows) => rows.first.values.first as int;

  Future<int> count(Database db, String table, [String? where, List<Object?>? args]) async =>
      firstInt(await db.rawQuery('SELECT COUNT(*) FROM $table${where == null ? '' : ' WHERE $where'}', args));

  test('eliminare un profilo toglie tutte le sue righe e impostazioni, e niente degli altri', () async {
    final db = await openCurrent('${tmp.path}/a.db');
    // 1 e 12: "usage.1." non deve prendere "usage.12.".
    await db.insert('profiles', profile(1, 'Ada'));
    await db.insert('profiles', profile(12, 'Teo'));
    await fill(db, 1);
    await fill(db, 12);
    await db.insert('settings', {'key': 'hemisphere', 'value': 'north'});
    await db.insert('settings', {'key': 'onboarding_seen', 'value': '1'});

    await LocalDb.forTest(db).deleteProfile(1);

    for (final t in LocalDb.childTables) {
      expect(await count(db, t, 'profile_id = 1'), 0, reason: t);
      expect(await count(db, t, 'profile_id = 12'), 1, reason: t);
    }
    expect(await count(db, 'profiles'), 1);
    final keys = [for (final r in await db.query('settings', orderBy: 'key')) r['key']];
    expect(keys, [
      'dismissed_ideas.12',
      'hemisphere',
      'onboarding_seen',
      'parent_notes_12',
      'resume.drawing.12',
      'resume.story.12.lia-rabbia.6-7',
      'usage.12.2026-10-10',
    ]);
    await db.close();
  });

  test('le chiavi esterne sono accese: la cascata funziona anche da sola', () async {
    final db = await openCurrent('${tmp.path}/b.db');
    expect(firstInt(await db.rawQuery('PRAGMA foreign_keys')), 1);
    await db.insert('profiles', profile(1, 'Ada'));
    await fill(db, 1);
    await db.delete('profiles', where: 'id = 1');
    for (final t in LocalDb.childTables) {
      expect(await count(db, t), 0, reason: t);
    }
    await db.close();
  });

  test('un database nuovo non ha tentativi, aiuti, serie né risposte ai dialoghi', () async {
    final db = await openCurrent('${tmp.path}/c.db');
    Future<Set<String>> columns(String t) async => {for (final c in await db.rawQuery('PRAGMA table_info($t)')) c['name'] as String};
    expect(await columns('activity_rounds'), {'id', 'profile_id', 'activity_id', 'skill', 'choice', 'at'});
    expect(await columns('activity_progress'), {'profile_id', 'activity_id', 'level', 'sessions', 'last_played'});
    expect(await columns('diary'), isNot(contains('dialogue_answer')));
    await db.close();
  });

  test('la migrazione v13 toglie i dati prestazionali e le righe orfane', () async {
    final path = '${tmp.path}/d.db';
    // Un database v12: lo schema di oggi con le tre tabelle com'erano.
    final old = await factory.openDatabase(path, options: OpenDatabaseOptions(version: 12, onCreate: LocalDb.createSchema));
    await old.execute('DROP TABLE diary');
    await old.execute('DROP TABLE activity_progress');
    await old.execute('DROP TABLE activity_rounds');
    await old.execute('CREATE TABLE diary (id INTEGER PRIMARY KEY AUTOINCREMENT, profile_id INTEGER NOT NULL, '
        'story_id TEXT NOT NULL, mode TEXT NOT NULL, completed INTEGER NOT NULL, dialogue_answer TEXT, at TEXT NOT NULL)');
    await old.execute('CREATE TABLE activity_progress (profile_id INTEGER NOT NULL, activity_id TEXT NOT NULL, '
        'level INTEGER NOT NULL DEFAULT 1, streak INTEGER NOT NULL DEFAULT 0, sessions INTEGER NOT NULL DEFAULT 0, '
        'last_played TEXT, PRIMARY KEY (profile_id, activity_id))');
    await old.execute('CREATE TABLE activity_rounds (id INTEGER PRIMARY KEY AUTOINCREMENT, profile_id INTEGER NOT NULL, '
        'activity_id TEXT NOT NULL, skill TEXT NOT NULL, level INTEGER NOT NULL, attempts INTEGER NOT NULL, '
        'hints INTEGER NOT NULL, choice TEXT, at TEXT NOT NULL)');
    await old.insert('profiles', profile(1, 'Ada'));
    const at = '2026-10-10T10:00:00.000';
    await old.insert('diary', {'profile_id': 1, 'story_id': 'lia-rabbia', 'mode': 'alone', 'completed': 1, 'dialogue_answer': 'spingo', 'at': at});
    await old.insert('activity_progress', {'profile_id': 1, 'activity_id': 'a', 'level': 2, 'streak': 5, 'sessions': 3});
    for (final choice in ['project=idea;note=due fogli', 'presentation=repeat', 'hunt=found', 'done=3;alone=2;of=4', null]) {
      await old.insert('activity_rounds',
          {'profile_id': 1, 'activity_id': 'a', 'skill': 's', 'level': 2, 'attempts': 3, 'hints': 1, 'choice': choice, 'at': at});
    }
    // Un profilo eliminato prima della v13 (chiavi esterne spente) ha lasciato righe.
    await old.insert('gestures', {'profile_id': 99, 'story_id': 'x', 'at': at});
    await old.insert('made_stories',
        {'profile_id': 99, 'who': 'w', 'place': 'p', 'problem': 'x', 'feeling': 'f', 'helper': 'h', 'ending': 'e', 'at': at});
    await old.insert('settings', {'key': 'advice_off.1', 'value': '1'});
    await old.close();

    final db = await openCurrent(path);
    Future<Set<String>> columns(String t) async => {for (final c in await db.rawQuery('PRAGMA table_info($t)')) c['name'] as String};
    expect(await columns('activity_rounds'), {'id', 'profile_id', 'activity_id', 'skill', 'choice', 'at'});
    expect(await columns('activity_progress'), isNot(contains('streak')));
    expect([for (final r in await db.query('activity_rounds', orderBy: 'id')) r['choice']],
        ['project=idea;note=due fogli', 'presentation=repeat', null, null, null]);
    final progress = (await db.query('activity_progress')).single;
    expect((progress['level'], progress['sessions']), (2, 3));
    expect((await db.query('diary')).single['dialogue_answer'], isNull);
    expect(await count(db, 'gestures'), 0);
    expect(await count(db, 'made_stories'), 0);
    expect(await count(db, 'settings', "key LIKE 'advice_off.%'"), 0);
    await db.close();
  });

  test('un backup di prima della v13 si ripristina senza tentativi, risposte né righe orfane', () async {
    final db = await openCurrent('${tmp.path}/e.db');
    const at = '2026-10-10T10:00:00.000';
    await LocalDb.forTest(db).importAll({
      'schema': 12,
      'profiles': [profile(1, 'Ada')],
      'diary': [
        {'id': 1, 'profile_id': 1, 'story_id': 'lia-rabbia', 'mode': 'alone', 'completed': 1, 'dialogue_answer': 'spingo', 'at': at},
        {'id': 2, 'profile_id': 99, 'story_id': 'lia-rabbia', 'mode': 'alone', 'completed': 1, 'dialogue_answer': null, 'at': at},
      ],
      'activity_progress': [
        {'profile_id': 1, 'activity_id': 'a', 'level': 2, 'streak': 4, 'sessions': 1, 'last_played': null},
      ],
      'activity_rounds': [
        {'id': 1, 'profile_id': 1, 'activity_id': 'a', 'skill': 's', 'level': 2, 'attempts': 3, 'hints': 1, 'choice': 'hunt=skip', 'at': at},
        {'id': 2, 'profile_id': 1, 'activity_id': 'a', 'skill': 's', 'level': 2, 'attempts': 1, 'hints': 0, 'choice': 'presentation=done', 'at': at},
      ],
    });
    expect((await db.query('diary')).map((r) => r['profile_id']), [1]);
    expect([for (final r in await db.query('activity_rounds', orderBy: 'id')) r['choice']], [null, 'presentation=done']);
    expect((await db.query('activity_progress')).single.keys, isNot(contains('streak')));
    await db.close();
  });
}
