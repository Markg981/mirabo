import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../models/activity.dart';
import '../models/made_story.dart';
import '../models/nature_day.dart';
import '../models/profile.dart';
import '../models/shelf.dart';
import '../models/story.dart' show AgeBand, LegacyAgeBand;

/// Database locale: profili (con la loro mensola), diario, gesti fatti nella
/// vita vera, storie inventate e calendario della natura. Tutto resta sul dispositivo.
///
/// Il file è cifrato a riposo con SQLCipher. La chiave (256 bit casuali) viene
/// generata al primo avvio e conservata in flutter_secure_storage (Keychain /
/// Keystore), mai accanto al database.
class LocalDb {
  LocalDb._(this._db);
  Database _db;

  static const _version = 12;
  static const _keyName = 'mirabo_db_key';

  /// Chiave in `settings` dell'emisfero della famiglia (vedi [Hemisphere]).
  static const hemisphereKey = 'hemisphere';

  /// Prefisso in `settings` delle idee scartate dal genitore (poi `.idBambino`).
  static const dismissedIdeasKey = 'dismissed_ideas';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // Solo questo dispositivo: la chiave non finisce nei backup iCloud.
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  static Future<LocalDb> open() async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, 'mirabo.db');
    final key = await _databaseKey(path);
    final db = await openDatabase(
      path,
      password: key,
      version: _version,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age_band TEXT NOT NULL,
            companion TEXT NOT NULL,
            enabled_worlds TEXT NOT NULL,
            safety_together_only INTEGER NOT NULL DEFAULT 1,
            last_mode TEXT NOT NULL DEFAULT 'together',
            dyslexia_font INTEGER NOT NULL DEFAULT 0,
            low_stimulation INTEGER NOT NULL DEFAULT 0,
            alone_minutes INTEGER NOT NULL DEFAULT 20,
            stories_completed INTEGER NOT NULL DEFAULT 0,
            language TEXT NOT NULL DEFAULT 'it',
            gestures_done INTEGER NOT NULL DEFAULT 0,
            stage_floor INTEGER NOT NULL DEFAULT 0,
            shelf TEXT,
            read_along INTEGER NOT NULL DEFAULT 1,
            shelf_auto TEXT,
            shelf_rotated_at TEXT,
            hands INTEGER,
            reading TEXT,
            autonomy INTEGER,
            band_to_confirm TEXT,
            growth_since TEXT
          )''');
        await db.execute('''
          CREATE TABLE diary (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
            story_id TEXT NOT NULL,
            mode TEXT NOT NULL,
            completed INTEGER NOT NULL,
            dialogue_answer TEXT,
            at TEXT NOT NULL
          )''');
        await db.execute('CREATE INDEX diary_profile ON diary(profile_id, at)');
        await _createActivityTables(db);
        await _createGesturesTable(db);
        await _createMakeTables(db);
        await _createShelfHistory(db);
        await _createDailyIdeas(db);
        await _createSettings(db);
      },
      onUpgrade: (db, from, to) async {
        if (from < 2) await _createActivityTables(db);
        // v3: lingua per bambino. I profili esistenti restano in italiano.
        if (from < 3) await db.execute("ALTER TABLE profiles ADD COLUMN language TEXT NOT NULL DEFAULT 'it'");
        // v4: il compagno cresce con i gesti fatti davvero, non con le storie.
        // Chi era già cresciuto con le storie resta allo stadio raggiunto.
        if (from < 4) {
          await db.execute('ALTER TABLE profiles ADD COLUMN gestures_done INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE profiles ADD COLUMN stage_floor INTEGER NOT NULL DEFAULT 0');
          await db.execute('UPDATE profiles SET stage_floor = $_legacyStageSql');
          await _createGesturesTable(db);
        }
        // v5: la mensola scelta dal genitore. NULL: si riempie da sola.
        if (from < 5) await db.execute('ALTER TABLE profiles ADD COLUMN shelf TEXT');
        // v6: lettura karaoke, storie inventate, calendario della natura.
        if (from < 6) {
          await db.execute('ALTER TABLE profiles ADD COLUMN read_along INTEGER NOT NULL DEFAULT 1');
          await _createMakeTables(db);
        }
        // v7: la mensola automatica si salva e ruota una volta a settimana.
        if (from < 7) {
          await db.execute('ALTER TABLE profiles ADD COLUMN shelf_auto TEXT');
          await db.execute('ALTER TABLE profiles ADD COLUMN shelf_rotated_at TEXT');
          await _createShelfHistory(db);
        }
        // v8: profilo di interazione (mani, lettura, autonomia), dalla fascia d'età.
        if (from < 8) {
          await db.execute('ALTER TABLE profiles ADD COLUMN hands INTEGER');
          await db.execute('ALTER TABLE profiles ADD COLUMN reading TEXT');
          await db.execute('ALTER TABLE profiles ADD COLUMN autonomy INTEGER');
          await db.execute(_interactionFromAgeSql);
        }
        // v9: l'idea del giorno si salva, così resta la stessa e non torna per 14 giorni.
        if (from < 9) await _createDailyIdeas(db);
        // v10: impostazioni della famiglia (per ora l'emisfero del calendario della natura).
        if (from < 10) await _createSettings(db);
        // v11: fasce 3-5, 6-7, 8-10. Chi era in 5-7 o 7-10 resta sugli stessi
        // contenuti e l'adulto conferma la fascia (vedi docs/age-bands.md).
        if (from < 11) {
          await db.execute('ALTER TABLE profiles ADD COLUMN band_to_confirm TEXT');
          await db.execute(_legacyBandSql);
        }
        // v12: il compagno cresce con il calendario, non con i gesti segnati.
        // Chi era già cresciuto resta allo stadio raggiunto.
        if (from < 12) {
          await db.execute('ALTER TABLE profiles ADD COLUMN growth_since TEXT');
          await db.execute(_growthFromNowSql());
        }
      },
    );
    return LocalDb._(db);
  }

  /// Legge la chiave dal secure storage o ne crea una nuova. Un database già
  /// presente viene sistemato prima di aprirlo:
  /// - in chiaro (versioni precedenti alla cifratura): convertito con la nuova chiave;
  /// - cifrato ma senza chiave (es. file ripristinato da un backup su un altro
  ///   dispositivo): illeggibile, quindi eliminato e si riparte da zero.
  static Future<String> _databaseKey(String path) async {
    final file = File(path);
    final exists = await file.exists();
    final plaintext = exists && await _isPlaintext(file);

    var key = await _storage.read(key: _keyName);
    if (key == null) {
      if (exists && !plaintext) await _deleteDatabaseFiles(path);
      key = _newKey();
      // Salvata prima della conversione: se l'app si chiude a metà, al riavvio
      // il file è ancora in chiaro e la conversione riparte con la stessa chiave.
      await _storage.write(key: _keyName, value: key);
    }
    if (plaintext) await _encryptInPlace(path, key);
    return key;
  }

  static String _newKey() {
    final rnd = Random.secure();
    return base64Url.encode(List<int>.generate(32, (_) => rnd.nextInt(256)));
  }

  /// Un file SQLite in chiaro inizia con l'intestazione "SQLite format 3\0";
  /// uno SQLCipher ha al suo posto il salt casuale.
  static Future<bool> _isPlaintext(File file) async {
    final raf = await file.open();
    try {
      final header = await raf.read(16);
      return ascii.decode(header, allowInvalid: true) == 'SQLite format 3\u0000';
    } finally {
      await raf.close();
    }
  }

  /// Copia il database in chiaro in un nuovo file cifrato e lo sostituisce.
  static Future<void> _encryptInPlace(String path, String key) async {
    final tmp = '$path.enc';
    await _deleteDatabaseFiles(tmp);
    final plain = await openDatabase(path, singleInstance: false);
    try {
      final userVersion = Sqflite.firstIntValue(await plain.rawQuery('PRAGMA user_version')) ?? 0;
      await plain.execute('ATTACH DATABASE ? AS encrypted KEY ?', [tmp, key]);
      await plain.rawQuery("SELECT sqlcipher_export('encrypted')");
      await plain.execute('PRAGMA encrypted.user_version = $userVersion');
      await plain.execute('DETACH DATABASE encrypted');
    } finally {
      await plain.close();
    }
    // rename sostituisce l'originale in modo atomico: non c'è un momento senza file.
    await File(tmp).rename(path);
    await _deleteDatabaseFiles(path, mainFile: false);
  }

  static Future<void> _deleteDatabaseFiles(String path, {bool mainFile = true}) async {
    for (final suffix in [if (mainFile) '', '-journal', '-wal', '-shm']) {
      final f = File('$path$suffix');
      if (await f.exists()) await f.delete();
    }
  }

  static Future<void> _createActivityTables(Database db) async {
    await db.execute('''
      CREATE TABLE activity_progress (
        profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
        activity_id TEXT NOT NULL,
        level INTEGER NOT NULL DEFAULT 1,
        streak INTEGER NOT NULL DEFAULT 0,
        sessions INTEGER NOT NULL DEFAULT 0,
        last_played TEXT,
        PRIMARY KEY (profile_id, activity_id)
      )''');
    await db.execute('''
      CREATE TABLE activity_rounds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
        activity_id TEXT NOT NULL,
        skill TEXT NOT NULL,
        level INTEGER NOT NULL,
        attempts INTEGER NOT NULL,
        hints INTEGER NOT NULL,
        choice TEXT,
        at TEXT NOT NULL
      )''');
    await db.execute('CREATE INDEX rounds_profile ON activity_rounds(profile_id, skill, at)');
  }

  static Future<void> _createGesturesTable(Database db) async {
    await db.execute('''
      CREATE TABLE gestures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
        story_id TEXT NOT NULL,
        at TEXT NOT NULL
      )''');
    await db.execute('CREATE INDEX gestures_profile ON gestures(profile_id, at)');
  }

  static Future<void> _createMakeTables(Database db) async {
    await db.execute('''
      CREATE TABLE made_stories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
        title TEXT,
        who TEXT NOT NULL,
        place TEXT NOT NULL,
        problem TEXT NOT NULL,
        feeling TEXT NOT NULL,
        helper TEXT NOT NULL,
        ending TEXT NOT NULL,
        at TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE nature_days (
        profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
        day TEXT NOT NULL,
        weather TEXT,
        seen TEXT NOT NULL DEFAULT '',
        PRIMARY KEY (profile_id, day)
      )''');
  }

  /// Quando un materiale è stato sulla mensola automatica: chi manca da più
  /// tempo entra per primo alla rotazione.
  static Future<void> _createShelfHistory(Database db) async {
    await db.execute('''
      CREATE TABLE shelf_history (
        profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
        item_key TEXT NOT NULL,
        from_at TEXT NOT NULL,
        to_at TEXT
      )''');
    await db.execute('CREATE INDEX shelf_history_profile ON shelf_history(profile_id, item_key)');
  }

  /// Le idee per oggi proposte al genitore, una per giorno (3.4.3).
  static Future<void> _createDailyIdeas(Database db) async {
    await db.execute('''
      CREATE TABLE daily_ideas (
        profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
        day TEXT NOT NULL,
        idea_key TEXT NOT NULL,
        PRIMARY KEY (profile_id, day)
      )''');
  }

  /// Impostazioni della famiglia, non di un bambino: una riga per chiave.
  static Future<void> _createSettings(Database db) async {
    await db.execute('CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
  }

  /// Riempie il profilo di interazione mancante con i valori della fascia d'età.
  static final _interactionFromAgeSql = () {
    String byBand(Object? Function(InteractionProfile p) value) => [
          'CASE age_band',
          for (final b in AgeBand.values) "WHEN '${b.key}' THEN '${value(InteractionProfile.forAge(b))}'",
          // Le fasce di prima: gli stessi valori iniziali che avevano allora.
          for (final b in LegacyAgeBand.values) "WHEN '${b.key}' THEN '${value(InteractionProfile.forAge(b.content))}'",
          'END',
        ].join(' ');
    return 'UPDATE profiles SET hands = ${byBand((p) => p.hands)}, reading = ${byBand((p) => p.reading.name)}, '
        'autonomy = ${byBand((p) => p.autonomy)} WHERE hands IS NULL OR reading IS NULL OR autonomy IS NULL';
  }();

  /// Le fasce sovrapposte di prima passano alla fascia con le stesse varianti,
  /// e si ricorda quale era: la conferma spetta all'adulto, non all'app.
  static final _legacyBandSql = [
    'UPDATE profiles SET band_to_confirm = age_band, age_band = CASE age_band',
    for (final b in LegacyAgeBand.values) "WHEN '${b.key}' THEN '${b.content.key}'",
    'END WHERE age_band IN (${LegacyAgeBand.values.map((b) => "'${b.key}'").join(', ')})',
  ].join(' ');

  /// Il compagno smette di crescere con i gesti segnati: lo stadio raggiunto
  /// resta come minimo e da oggi cresce con le settimane.
  static String _growthFromNowSql() =>
      "UPDATE profiles SET stage_floor = MAX(stage_floor, $_gestureStageSql), growth_since = '${DateTime.now().toIso8601String()}' "
      'WHERE growth_since IS NULL';

  /// Stadio che il compagno aveva quando cresceva con i gesti segnati (v4–v11).
  static const _gestureStageSql =
      'CASE WHEN gestures_done >= 12 THEN 3 WHEN gestures_done >= 6 THEN 2 WHEN gestures_done >= 3 THEN 1 ELSE 0 END';

  /// Stadio che il compagno aveva quando cresceva con le storie completate.
  static const _legacyStageSql =
      'CASE WHEN stories_completed >= 12 THEN 3 WHEN stories_completed >= 6 THEN 2 WHEN stories_completed >= 3 THEN 1 ELSE 0 END';

  Future<ActivityProgress> progress(int profileId, String activityId) async {
    final rows = await _db.query('activity_progress',
        where: 'profile_id = ? AND activity_id = ?', whereArgs: [profileId, activityId]);
    if (rows.isEmpty) return ActivityProgress(profileId: profileId, activityId: activityId);
    final r = rows.first;
    return ActivityProgress(
      profileId: profileId,
      activityId: activityId,
      level: r['level'] as int,
      streak: r['streak'] as int,
      sessions: r['sessions'] as int,
      lastPlayed: r['last_played'] == null ? null : DateTime.parse(r['last_played'] as String),
    );
  }

  Future<Map<String, ActivityProgress>> allProgress(int profileId) async {
    final rows = await _db.query('activity_progress', where: 'profile_id = ?', whereArgs: [profileId]);
    return {
      for (final r in rows)
        r['activity_id'] as String: ActivityProgress(
          profileId: profileId,
          activityId: r['activity_id'] as String,
          level: r['level'] as int,
          streak: r['streak'] as int,
          sessions: r['sessions'] as int,
          lastPlayed: r['last_played'] == null ? null : DateTime.parse(r['last_played'] as String),
        )
    };
  }

  Future<void> saveProgress(ActivityProgress p) => _db.insert(
        'activity_progress',
        {
          'profile_id': p.profileId,
          'activity_id': p.activityId,
          'level': p.level,
          'streak': p.streak,
          'sessions': p.sessions,
          'last_played': p.lastPlayed?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> addRounds(int profileId, Activity activity, int level, List<RoundResult> results) async {
    final batch = _db.batch();
    final now = DateTime.now().toIso8601String();
    for (final r in results) {
      batch.insert('activity_rounds', {
        'profile_id': profileId,
        'activity_id': activity.id,
        'skill': activity.skill,
        'level': level,
        'attempts': r.attempts,
        'hints': r.hints,
        'choice': r.choice,
        'at': now,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Round per abilità in una finestra temporale: base delle statistiche genitore.
  Future<List<Map<String, Object?>>> rounds(int profileId, {required DateTime from, DateTime? to}) =>
      _db.query('activity_rounds',
          where: 'profile_id = ? AND at >= ? AND at < ?',
          whereArgs: [profileId, from.toIso8601String(), (to ?? DateTime.now()).toIso8601String()],
          orderBy: 'at');

  Future<List<ChildProfile>> profiles() async =>
      (await _db.query('profiles', orderBy: 'id')).map(ChildProfile.fromRow).toList();

  Future<ChildProfile> insertProfile(ChildProfile profile) async {
    final row = profile.toRow()..remove('id');
    // Da qui il compagno cresce con il calendario.
    row['growth_since'] ??= DateTime.now().toIso8601String();
    final id = await _db.insert('profiles', row);
    return (await _db.query('profiles', where: 'id = ?', whereArgs: [id])).map(ChildProfile.fromRow).first;
  }

  Future<void> updateProfile(ChildProfile profile) =>
      _db.update('profiles', profile.toRow(), where: 'id = ?', whereArgs: [profile.id]);

  Future<void> deleteProfile(int id) => _db.delete('profiles', where: 'id = ?', whereArgs: [id]);

  Future<void> addDiaryEntry(DiaryEntry e) => _db.insert('diary', {
        'profile_id': e.profileId,
        'story_id': e.storyId,
        'mode': e.mode.name,
        'completed': e.completed ? 1 : 0,
        'dialogue_answer': e.dialogueAnswer,
        'at': e.when.toIso8601String(),
      });

  Future<List<DiaryEntry>> diary(int profileId, {int days = 30}) async {
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final rows = await _db.query('diary',
        where: 'profile_id = ? AND at >= ?', whereArgs: [profileId, since], orderBy: 'at DESC');
    return rows
        .map((r) => DiaryEntry(
              profileId: r['profile_id'] as int,
              storyId: r['story_id'] as String,
              mode: SessionMode.values.byName(r['mode'] as String),
              completed: (r['completed'] as int) == 1,
              dialogueAnswer: r['dialogue_answer'] as String?,
              when: DateTime.parse(r['at'] as String),
            ))
        .toList();
  }

  Future<void> addGesture(GestureEntry g) => _db.insert('gestures', {
        'profile_id': g.profileId,
        'story_id': g.storyId,
        'at': g.when.toIso8601String(),
      });

  Future<List<GestureEntry>> gestures(int profileId) async {
    final rows = await _db.query('gestures', where: 'profile_id = ?', whereArgs: [profileId], orderBy: 'at DESC');
    return rows
        .map((r) => GestureEntry(
              profileId: r['profile_id'] as int,
              storyId: r['story_id'] as String,
              when: DateTime.parse(r['at'] as String),
            ))
        .toList();
  }

  Future<MadeStory> addMadeStory(MadeStory s) async {
    final id = await _db.insert('made_stories', s.toRow()..remove('id'));
    return MadeStory.fromRow((await _db.query('made_stories', where: 'id = ?', whereArgs: [id])).first);
  }

  Future<List<MadeStory>> madeStories(int profileId) async =>
      (await _db.query('made_stories', where: 'profile_id = ?', whereArgs: [profileId], orderBy: 'at DESC'))
          .map(MadeStory.fromRow)
          .toList();

  /// Un giorno vuoto si cancella: nel calendario resta solo ciò che è stato visto.
  Future<void> saveNatureDay(NatureDay d) => d.isEmpty
      ? _db.delete('nature_days', where: 'profile_id = ? AND day = ?', whereArgs: [d.profileId, NatureDay.key(d.day)])
      : _db.insert('nature_days', d.toRow(), conflictAlgorithm: ConflictAlgorithm.replace);

  /// I giorni segnati nel mese di [month].
  Future<List<NatureDay>> natureMonth(int profileId, DateTime month) async {
    final from = NatureDay.key(DateTime(month.year, month.month, 1));
    final to = NatureDay.key(DateTime(month.year, month.month + 1, 1));
    final rows = await _db.query('nature_days',
        where: 'profile_id = ? AND day >= ? AND day < ?', whereArgs: [profileId, from, to], orderBy: 'day');
    return rows.map(NatureDay.fromRow).toList();
  }

  /// Gli usi dei materiali da [since]: storie lette, sessioni di attività
  /// (i round di una sessione hanno lo stesso istante), storie inventate e
  /// giorni del calendario della natura. I giochi non lasciano traccia.
  Future<List<ShelfUse>> shelfUsage(int profileId, {required DateTime since}) async {
    final from = since.toIso8601String();
    final stories = await _db.query('diary',
        columns: ['story_id', 'at'], where: 'profile_id = ? AND at >= ?', whereArgs: [profileId, from]);
    final sessions = await _db.rawQuery(
        "SELECT activity_id, at, MAX(choice = 'presentation=repeat') AS rep FROM activity_rounds "
        'WHERE profile_id = ? AND at >= ? GROUP BY activity_id, at',
        [profileId, from]);
    final made = await _db.query('made_stories',
        columns: ['at'], where: 'profile_id = ? AND at >= ?', whereArgs: [profileId, from]);
    final nature = await _db.query('nature_days',
        columns: ['day'], where: 'profile_id = ? AND day >= ?', whereArgs: [profileId, NatureDay.key(since)]);
    return [
      for (final r in stories) ShelfUse('story:${r['story_id']}', DateTime.parse(r['at'] as String)),
      for (final r in sessions)
        ShelfUse('activity:${r['activity_id']}', DateTime.parse(r['at'] as String), repeat: r['rep'] == 1),
      for (final r in made) ShelfUse(const MakeItem(MakeTool.factory).key, DateTime.parse(r['at'] as String)),
      for (final r in nature) ShelfUse(const MakeItem(MakeTool.nature).key, DateTime.parse(r['day'] as String)),
    ];
  }

  Future<List<ShelfStint>> shelfHistory(int profileId) async {
    final rows = await _db.query('shelf_history', where: 'profile_id = ?', whereArgs: [profileId]);
    return [
      for (final r in rows)
        ShelfStint(r['item_key'] as String, DateTime.parse(r['from_at'] as String),
            r['to_at'] == null ? null : DateTime.parse(r['to_at'] as String)),
    ];
  }

  /// Registra il cambio della mensola automatica da [before] ad [after]:
  /// chi esce chiude il suo periodo, chi entra ne apre uno.
  Future<void> moveShelf(int profileId, {required List<String> before, required List<String> after, required DateTime at}) async {
    final when = at.toIso8601String();
    final batch = _db.batch();
    for (final k in before.where((k) => !after.contains(k))) {
      batch.update('shelf_history', {'to_at': when},
          where: 'profile_id = ? AND item_key = ? AND to_at IS NULL', whereArgs: [profileId, k]);
    }
    for (final k in after.where((k) => !before.contains(k))) {
      batch.insert('shelf_history', {'profile_id': profileId, 'item_key': k, 'from_at': when});
    }
    await batch.commit(noResult: true);
  }

  /// Le idee proposte da [since] in poi.
  Future<List<({String day, String key})>> dailyIdeas(int profileId, {required DateTime since}) async {
    final rows = await _db.query('daily_ideas',
        where: 'profile_id = ? AND day >= ?', whereArgs: [profileId, NatureDay.key(since)], orderBy: 'day');
    return [for (final r in rows) (day: r['day'] as String, key: r['idea_key'] as String)];
  }

  /// Salva l'idea di [day] solo se quel giorno non ne ha già una.
  Future<void> saveDailyIdea(int profileId, String day, String key) => _db.insert(
      'daily_ideas', {'profile_id': profileId, 'day': day, 'idea_key': key},
      conflictAlgorithm: ConflictAlgorithm.ignore);

  /// Le chiavi delle idee che il genitore ha scartato per questo bambino.
  Future<Set<String>> dismissedIdeas(int profileId) async {
    final raw = await setting('$dismissedIdeasKey.$profileId');
    if (raw == null || raw.isEmpty) return {};
    return {for (final k in raw.split('\n')) if (k.isNotEmpty) k};
  }

  /// Scarta un'idea: non verrà più riproposta a questo bambino.
  Future<void> dismissIdea(int profileId, String key) async {
    final all = await dismissedIdeas(profileId);
    all.add(key);
    await setSetting('$dismissedIdeasKey.$profileId', all.join('\n'));
  }

  /// Un'impostazione della famiglia; null se non è mai stata scelta.
  Future<String?> setting(String key) async {
    final rows = await _db.query('settings', columns: ['value'], where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) =>
      _db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);

  /// Cancellazione completa: chiude il database, elimina file e chiave e ne
  /// apre uno nuovo e vuoto, come al primo avvio. Vedi [eraseStorage].
  Future<void> eraseAndReopen() async {
    await _db.close();
    await eraseStorage();
    _db = (await open())._db;
  }

  /// Elimina da questo dispositivo il database (con i file -journal/-wal/-shm),
  /// la sua chiave nel secure storage, la cache del nome pronunciato e tutto
  /// ciò che l'app ha nella cartella temporanea (audio delle storie, suoni,
  /// file generati). [supportDir] e [tempDir] servono ai test.
  static Future<void> eraseStorage({Directory? supportDir, Directory? tempDir}) async {
    final support = supportDir ?? await getApplicationSupportDirectory();
    await _deleteDatabaseFiles(p.join(support.path, 'mirabo.db'));
    await _deleteTree(Directory(p.join(support.path, 'names')));
    await _storage.delete(key: _keyName);
    final temp = tempDir ?? await getTemporaryDirectory();
    if (await temp.exists()) {
      await for (final e in temp.list()) {
        await _deleteTree(e);
      }
    }
  }

  static Future<void> _deleteTree(FileSystemEntity e) async {
    try {
      if (await e.exists()) await e.delete(recursive: true);
    } on FileSystemException catch (err) {
      debugPrint('Cancellazione non riuscita: ${err.path}');
    }
  }

  /// Vero se la chiave del database è ancora nel secure storage.
  static Future<bool> hasKey() async => await _storage.read(key: _keyName) != null;

  /// "Elimina tutti i dati": cancella profili, diario e impostazioni.
  Future<void> wipe() async {
    await _db.delete('settings');
    await _db.delete('daily_ideas');
    await _db.delete('shelf_history');
    await _db.delete('nature_days');
    await _db.delete('made_stories');
    await _db.delete('gestures');
    await _db.delete('activity_rounds');
    await _db.delete('activity_progress');
    await _db.delete('diary');
    await _db.delete('profiles');
  }

  /// Tabelle nell'ordine di inserimento (prima i profili, poi chi li riferisce).
  static const _tables = [
    'profiles',
    'diary',
    'activity_progress',
    'activity_rounds',
    'gestures',
    'made_stories',
    'nature_days',
    'shelf_history',
    'daily_ideas',
    'settings',
  ];

  /// Tutti i dati come JSON semplice (solo int, testo e null): è il contenuto
  /// del backup su Drive, che viene cifrato prima di uscire dal dispositivo.
  Future<Map<String, Object?>> exportAll() async => {
        'schema': _version,
        for (final t in _tables) t: await _db.query(t),
      };

  /// Sostituisce tutti i dati con quelli di un backup. Un backup di una versione
  /// precedente va bene (le colonne aggiunte dopo prendono il default); uno di
  /// una versione più recente no, perché avrebbe colonne che qui non esistono.
  Future<void> importAll(Map<String, Object?> data) async {
    final schema = data['schema'];
    if (schema is! int || schema > _version) throw const FormatException('Backup di una versione più recente');
    await _db.transaction((tx) async {
      for (final t in _tables.reversed) {
        await tx.delete(t);
      }
      for (final t in _tables) {
        for (final row in (data[t] as List? ?? const [])) {
          await tx.insert(t, Map<String, Object?>.from(row as Map));
        }
      }
      // Come nella migrazione v4: chi era cresciuto con le storie non torna indietro.
      if (schema < 4) await tx.execute('UPDATE profiles SET stage_floor = $_legacyStageSql');
      // Backup di prima del profilo di interazione: si parte dalla fascia d'età.
      if (schema < 8) await tx.execute(_interactionFromAgeSql);
      // Backup di prima dell'emisfero: i suggerimenti erano quelli del nord.
      if (schema < 10) await tx.insert('settings', {'key': hemisphereKey, 'value': 'north'});
      // Backup con le fasce di prima: come la migrazione v11.
      if (schema < 11) await tx.execute(_legacyBandSql);
      // Backup di quando il compagno cresceva con i gesti: come la migrazione v12.
      if (schema < 12) await tx.execute(_growthFromNowSql());
    });
  }
}
