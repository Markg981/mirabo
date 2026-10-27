import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/backup_codec.dart';
import 'package:mirabo/data/cloud_backup.dart';
import 'package:mirabo/data/backup_store.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/models/profile.dart';

/// Drive in memoria.
class _MemoryStore implements BackupStore {
  List<int>? file;
  bool online = true;
  int uploads = 0;

  @override
  Future<String> connect() async => 'genitore@example.com';
  @override
  Future<bool> reconnect() async => online;
  @override
  Future<void> upload(List<int> bytes) async {
    if (!online) throw StateError('offline');
    uploads++;
    file = bytes;
  }

  @override
  Future<List<int>?> download() async => file;
  @override
  Future<void> deleteRemote() async => file = null;
  @override
  Future<void> disconnect() async {}
}

/// Solo la parte di LocalDb che usa il backup.
class _FakeDb implements LocalDb {
  _FakeDb(this.data);
  Map<String, Object?> data;

  @override
  Future<Map<String, Object?>> exportAll() async => data;
  @override
  Future<void> importAll(Map<String, Object?> d) async => data = d;
  @override
  Future<List<ChildProfile>> profiles() async =>
      [for (final r in data['profiles'] as List) ChildProfile.fromRow(Map<String, Object?>.from(r as Map))];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, Object?> _sample(String name) => {
      'schema': 3,
      'profiles': [
        {
          'id': 1,
          'name': name,
          'age_band': '6-7',
          'companion': 'bo',
          'enabled_worlds': '',
          'safety_together_only': 1,
          'last_mode': 'together',
          'dyslexia_font': 0,
          'low_stimulation': 0,
          'alone_minutes': 20,
          'stories_completed': 4,
          'language': 'it',
        }
      ],
      'diary': [],
      'activity_progress': [],
      'activity_rounds': [],
    };

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('BackupCodec', () {
    test('cifra e decifra con la stessa password', () async {
      final key = await BackupKey.derive('una password lunga', iterations: 1000);
      final file = await BackupCodec.encrypt(_sample('Emma'), key);
      expect(String.fromCharCodes(file), isNot(contains('Emma')));

      final r = await BackupCodec.decrypt(file, 'una password lunga');
      expect((r.data['profiles'] as List).first['name'], 'Emma');
      expect(r.key.bytes, key.bytes);
      expect(r.key.iterations, 1000);
    });

    test('password sbagliata', () async {
      final key = await BackupKey.derive('una password lunga', iterations: 1000);
      final file = await BackupCodec.encrypt(_sample('Emma'), key);
      expect(BackupCodec.decrypt(file, 'un\'altra password'), throwsA(isA<WrongPasswordException>()));
    });

    test('file che non è un backup', () {
      expect(BackupCodec.decrypt('ciao'.codeUnits, 'x'), throwsFormatException);
    });
  });

  group('CloudBackup', () {
    test('attiva, ripristina su un altro tablet, backup automatico una volta al giorno', () async {
      final drive = _MemoryStore();
      var now = DateTime(2026, 10, 13, 9);

      final tabletA = CloudBackup(db: _FakeDb(_sample('Emma')), store: drive, now: () => now);
      await tabletA.load();
      expect(tabletA.enabled, isFalse);
      await tabletA.connect();
      await tabletA.enable('password del genitore');
      expect(tabletA.enabled, isTrue);
      expect(tabletA.account, 'genitore@example.com');
      expect(drive.uploads, 1);

      // Stesso giorno: niente backup automatico.
      now = now.add(const Duration(hours: 3));
      await tabletA.autoBackup();
      expect(drive.uploads, 1);
      // Il giorno dopo sì.
      now = now.add(const Duration(days: 1));
      await tabletA.autoBackup();
      expect(drive.uploads, 2);

      // Tablet nuovo (secure storage vuoto).
      FlutterSecureStorage.setMockInitialValues({});
      final dbB = _FakeDb(_sample('nessuno')..['profiles'] = []);
      final tabletB = CloudBackup(db: dbB, store: drive, now: () => now);
      await tabletB.load();
      await tabletB.connect();
      final remote = await tabletB.remoteBackup();
      await expectLater(tabletB.restore(remote!, 'sbagliata'), throwsA(isA<WrongPasswordException>()));
      expect(tabletB.enabled, isFalse);
      await tabletB.restore(remote, 'password del genitore');
      expect((dbB.data['profiles'] as List).first['name'], 'Emma');
      expect(tabletB.enabled, isTrue);

      // Da qui fa i backup con la stessa password, senza richiederla.
      await tabletB.backupNow();
      final again = await BackupCodec.decrypt(drive.file!, 'password del genitore');
      expect((again.data['profiles'] as List).first['name'], 'Emma');
    });

    test('un tablet azzerato non sovrascrive il backup', () async {
      final drive = _MemoryStore();
      var now = DateTime(2026, 10, 13);
      final db = _FakeDb(_sample('Emma'));
      final backup = CloudBackup(db: db, store: drive, now: () => now);
      await backup.connect();
      await backup.enable('password del genitore');

      db.data = _sample('x')..['profiles'] = [];
      now = now.add(const Duration(days: 2));
      await backup.autoBackup();
      expect(drive.uploads, 1);
    });

    test('backup automatico offline: segnala senza eccezioni', () async {
      final drive = _MemoryStore();
      var now = DateTime(2026, 10, 13);
      final backup = CloudBackup(db: _FakeDb(_sample('Emma')), store: drive, now: () => now);
      await backup.connect();
      await backup.enable('password del genitore');

      drive.online = false;
      now = now.add(const Duration(days: 2));
      await backup.autoBackup();
      expect(backup.lastAutoFailed, isTrue);
    });

    test('disattiva ed elimina la copia', () async {
      final drive = _MemoryStore();
      final backup = CloudBackup(db: _FakeDb(_sample('Emma')), store: drive);
      await backup.connect();
      await backup.enable('password del genitore');
      await backup.disable(deleteRemote: true);
      expect(backup.enabled, isFalse);
      expect(backup.account, isNull);
      expect(drive.file, isNull);
    });
  });
}
