import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/cloud_backup.dart';
import 'package:mirabo/data/backup_store.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/ui/parent/data_deletion.dart';

class _Drive implements BackupStore {
  List<int>? file = [1, 2, 3];
  bool online = true;
  bool disconnected = false;

  @override
  Future<String> connect() async => 'genitore@example.com';
  @override
  Future<bool> reconnect() async => online;
  @override
  Future<void> upload(List<int> bytes) async => file = bytes;
  @override
  Future<List<int>?> download() async => file;
  @override
  Future<void> deleteRemote() async {
    if (!online) throw const SocketException('offline');
    file = null;
  }

  @override
  Future<void> disconnect() async => disconnected = true;
}

class _FakeDb implements LocalDb {
  @override
  Future<Map<String, Object?>> exportAll() async => {'profiles': []};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory support;
  late Directory temp;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({'mirabo_db_key': 'chiave-di-prova'});
    support = await Directory.systemTemp.createTemp('mirabo_support');
    temp = await Directory.systemTemp.createTemp('mirabo_temp');
  });

  tearDown(() async {
    for (final d in [support, temp]) {
      if (await d.exists()) await d.delete(recursive: true);
    }
  });

  group('Cancellazione completa', () {
    test('dopo la cancellazione database, file generati e chiave non esistono più', () async {
      for (final s in ['', '-journal', '-wal', '-shm']) {
        await File('${support.path}/mirabo.db$s').writeAsString('dati');
      }
      await Directory('${support.path}/names').create();
      await File('${support.path}/names/name_1_abc.wav').writeAsString('voce');
      await Directory('${temp.path}/mirabo_audio/storia').create(recursive: true);
      await File('${temp.path}/mirabo_audio/storia/a.mp3').writeAsString('audio');
      await File('${temp.path}/mirabo_xilofono_0.wav').writeAsString('suono');
      await File('${temp.path}/stampabile.pdf').writeAsString('pdf');
      expect(await LocalDb.hasKey(), isTrue);

      await LocalDb.eraseStorage(supportDir: support, tempDir: temp);

      expect(await File('${support.path}/mirabo.db').exists(), isFalse);
      for (final s in ['-journal', '-wal', '-shm']) {
        expect(await File('${support.path}/mirabo.db$s').exists(), isFalse);
      }
      expect(await Directory('${support.path}/names').exists(), isFalse);
      expect(await temp.list().toList(), isEmpty);
      expect(await LocalDb.hasKey(), isFalse);
    });

    test('è sicura anche su un tablet già vuoto', () async {
      FlutterSecureStorage.setMockInitialValues({});
      await LocalDb.eraseStorage(supportDir: support, tempDir: temp);
      expect(await LocalDb.hasKey(), isFalse);
    });

    test('la chiave del backup si dimentica sul tablet ma il file su Drive resta', () async {
      final drive = _Drive();
      final backup = CloudBackup(db: _FakeDb(), store: drive);
      await backup.connect();
      await backup.enable('password del genitore');
      await backup.forget();
      expect(backup.enabled, isFalse);
      expect(drive.file, isNotNull);
    });
  });

  group('Cancellazione del backup su Drive', () {
    test('cancella il file, scollega e revoca', () async {
      final drive = _Drive();
      final backup = CloudBackup(db: _FakeDb(), store: drive);
      await backup.connect();
      await backup.enable('password del genitore');

      expect(await deleteRemoteBackup(backup), isTrue);
      expect(drive.file, isNull);
      expect(drive.disconnected, isTrue);
      expect(backup.enabled, isFalse);
    });

    test('senza rete fallisce in modo chiaro e non cambia niente', () async {
      final drive = _Drive();
      final backup = CloudBackup(db: _FakeDb(), store: drive);
      await backup.connect();
      await backup.enable('password del genitore');
      drive.online = false;

      expect(await deleteRemoteBackup(backup), isFalse);
      expect(drive.file, isNotNull);
      expect(drive.disconnected, isFalse);
      expect(backup.enabled, isTrue);

      drive.online = true;
      expect(await deleteRemoteBackup(backup), isTrue);
      expect(drive.file, isNull);
    });
  });
}
