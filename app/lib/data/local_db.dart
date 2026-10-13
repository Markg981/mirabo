import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../models/activity.dart';
import '../models/profile.dart';

/// Database locale: profili e diario. Tutto resta sul dispositivo.
///
/// Il file è cifrato a riposo con SQLCipher. La chiave (256 bit casuali) viene
/// generata al primo avvio e conservata in flutter_secure_storage (Keychain /
/// Keystore), mai accanto al database.
class LocalDb {
  LocalDb._(this._db);
  final Database _db;

  static const _version = 3;
  static const _keyName = 'mirabo_db_key';
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
            language TEXT NOT NULL DEFAULT 'it'
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
      },
      onUpgrade: (db, from, to) async {
        if (from < 2) await _createActivityTables(db);
        // v3: lingua per bambino. I profili esistenti restano in italiano.
        if (from < 3) await db.execute("ALTER TABLE profiles ADD COLUMN language TEXT NOT NULL DEFAULT 'it'");
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

  /// "Elimina tutti i dati": cancella profili e diario.
  Future<void> wipe() async {
    await _db.delete('activity_rounds');
    await _db.delete('activity_progress');
    await _db.delete('diary');
    await _db.delete('profiles');
  }
}
