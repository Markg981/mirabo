import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/package_installer.dart';
import 'package:mirabo/content/package_verifier.dart';
import 'package:path/path.dart' as p;

String _hex(List<int> b) => b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

/// Sorgente in memoria che può fallire dopo N byte e ricorda gli offset chiesti.
class _MemorySource implements PackageSource {
  _MemorySource(this.bytes, {this.failAfter, this.name = 'pkg'});
  final Uint8List bytes;
  final int? failAfter;
  final String name;
  final offsets = <int>[];

  @override
  String get id => name;
  @override
  Future<int?> length() async => bytes.length;
  @override
  Stream<List<int>> read({int offset = 0}) async* {
    offsets.add(offset);
    final end = failAfter == null ? bytes.length : failAfter!.clamp(offset, bytes.length);
    yield bytes.sublist(offset, end);
    if (failAfter != null && failAfter! < bytes.length) throw const SocketException('connessione persa');
  }
}

class _HugeSource implements PackageSource {
  bool read_ = false;
  @override
  String get id => 'huge';
  @override
  Future<int?> length() async => PackageInstaller.maxArchiveBytes + 1;
  @override
  Stream<List<int>> read({int offset = 0}) {
    read_ = true;
    return const Stream.empty();
  }
}

void main() {
  late SimpleKeyPair studio;
  late SimpleKeyPair stranger;
  late String studioHex;
  late Directory sandbox;
  late Directory support; // come getApplicationSupportDirectory()
  late Directory contentRoot;
  late PackageVerifier verifier;

  setUpAll(() async {
    studio = await Ed25519().newKeyPair();
    stranger = await Ed25519().newKeyPair();
    studioHex = _hex((await studio.extractPublicKey()).bytes);
    verifier = PackageVerifier(publicKeyHex: studioHex);
  });

  setUp(() {
    sandbox = Directory.systemTemp.createTempSync('mirabo_installer_');
    support = Directory(p.join(sandbox.path, 'support'))..createSync();
    contentRoot = Directory(p.join(support.path, 'content'));
  });
  tearDown(() => sandbox.deleteSync(recursive: true));

  PackageInstaller installer({int? Function()? free, Future<void> Function(String)? checkpoint, String app = '0.1.0'}) =>
      PackageInstaller(
        root: contentRoot,
        verifier: verifier,
        appVersion: app,
        freeBytes: free == null ? null : () async => free(),
        spaceMargin: 0,
        checkpoint: checkpoint,
      );

  Future<Uint8List> build({
    String id = 'lia',
    int version = 1,
    Map<String, String>? files,
    Map<String, dynamic> manifestExtra = const {},
    SimpleKeyPair? signer,
    String? tamperPath,
  }) async {
    final content = files ??
        {
          'story.json': '{"id":"$id","v":$version}',
          'assets/audio/base.txt': 'audio-comune',
          'i18n/en/story.json': '{"title":"en"}',
          'i18n/en/audio/a.txt': 'audio-en',
          'i18n/fr/story.json': '{"title":"fr"}',
          'i18n/fr/audio/a.txt': 'audio-fr',
        };
    final raw = {for (final e in content.entries) e.key: utf8.encode(e.value)};
    final parts = <String, List<String>>{'base': []};
    for (final k in raw.keys) {
      final m = RegExp(r'^i18n/([^/]+)/').firstMatch(k);
      parts.putIfAbsent(m?.group(1) ?? 'base', () => []).add(k);
    }
    final manifest = <String, dynamic>{
      'id': id,
      'kind': 'story',
      'version': version,
      'manifestVersion': 2,
      'formatVersion': 1,
      'minAppVersion': '0.1.0',
      'languages': ['it', 'en', 'fr'],
      'files': {for (final e in raw.entries) e.key: sha256.convert(e.value).toString()},
      'sizes': {for (final e in raw.entries) e.key: e.value.length},
      'size': raw.values.fold<int>(0, (a, b) => a + b.length),
      'parts': parts,
      'editorial': {'author': 'Studio', 'reviewer': 'Revisore, 2026-01-01', 'approvedVersion': version},
      ...manifestExtra,
    };
    final sig = await Ed25519().sign(utf8.encode(PackageVerifier.canonicalJson(manifest)), keyPair: signer ?? studio);
    manifest['signature'] = _hex(sig.bytes);
    if (tamperPath != null) raw[tamperPath] = utf8.encode('ALTERATO');
    final archive = Archive();
    raw.forEach((k, v) => archive.addFile(ArchiveFile(k, v.length, v)));
    final m = utf8.encode(jsonEncode(manifest));
    archive.addFile(ArchiveFile('manifest.json', m.length, m));
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  Future<Map<String, dynamic>> signedRetired(int sequence, List<Map<String, dynamic>> retired, {SimpleKeyPair? signer}) async {
    final doc = <String, dynamic>{'sequence': sequence, 'retired': retired};
    final sig = await Ed25519().sign(utf8.encode(PackageVerifier.canonicalJson(doc)), keyPair: signer ?? studio);
    return {...doc, 'signature': _hex(sig.bytes)};
  }

  String story(String id, int v) => File(p.join(contentRoot.path, 'packages', id, '$v', 'story.json')).readAsStringSync();

  bool leftovers() => !Directory(p.join(contentRoot.path, 'tmp')).existsSync() ||
      Directory(p.join(contentRoot.path, 'tmp')).listSync().every((e) => !p.basename(e.path).startsWith('stage-'));

  group('installazione', () {
    test('installa uno zip valido e lo registra', () async {
      final inst = installer();
      final r = await inst.install(_MemorySource(await build()));
      expect(r.version, 1);
      expect(story('lia', 1), contains('"v":1'));
      expect((await inst.find('lia'))!.languages, ['it', 'en', 'fr']);
      expect(File(p.join(contentRoot.path, 'tmp', 'pkg.part')).existsSync(), isFalse);
    });

    test('aggiornamento: la v1 resta fino al successo, poi diventa la precedente', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build()));
      final r = await inst.install(_MemorySource(await build(version: 2)));
      expect(r.version, 2);
      expect(r.previousVersion, 1);
      expect(story('lia', 1), contains('"v":1'));
      expect(story('lia', 2), contains('"v":2'));
    });

    test('solo le lingue richieste: niente file delle altre, italiano sempre', () async {
      final inst = installer();
      final r = await inst.install(_MemorySource(await build()), languages: {'en'});
      final dir = p.join(contentRoot.path, 'packages', 'lia', '1');
      expect(File(p.join(dir, 'i18n', 'en', 'audio', 'a.txt')).existsSync(), isTrue);
      expect(Directory(p.join(dir, 'i18n', 'fr')).existsSync(), isFalse);
      expect(File(p.join(dir, 'assets', 'audio', 'base.txt')).existsSync(), isTrue);
      expect(r.languages, ['it', 'en']);
    });
  });

  group('errori: lo stato precedente resta intatto', () {
    test('file alterato', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build()));
      await expectLater(
        inst.install(_MemorySource(await build(version: 2, tamperPath: 'story.json'))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.notVerified)),
      );
      expect((await inst.find('lia'))!.version, 1);
      expect(story('lia', 1), contains('"v":1'));
      expect(Directory(p.join(contentRoot.path, 'packages', 'lia', '2')).existsSync(), isFalse);
      expect(leftovers(), isTrue);
    });

    test('firma di un altro studio', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build()));
      await expectLater(
        inst.install(_MemorySource(await build(version: 2, signer: stranger))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.notVerified)),
      );
      expect((await inst.find('lia'))!.version, 1);
    });

    test('pacchetto senza firma', () async {
      final bytes = await build();
      final archive = ZipDecoder().decodeBytes(bytes);
      final m = jsonDecode(utf8.decode(archive.findFile('manifest.json')!.content as List<int>)) as Map<String, dynamic>..remove('signature');
      final out = Archive();
      for (final f in archive.files) {
        out.addFile(f.name == 'manifest.json'
            ? ArchiveFile('manifest.json', utf8.encode(jsonEncode(m)).length, utf8.encode(jsonEncode(m)))
            : ArchiveFile(f.name, f.size, f.content));
      }
      await expectLater(
        installer().install(_MemorySource(Uint8List.fromList(ZipEncoder().encode(out)!))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.notVerified)),
      );
    });

    test('versione incompatibile: app troppo vecchia e formato sconosciuto', () async {
      final inst = installer();
      await expectLater(
        inst.install(_MemorySource(await build(manifestExtra: {'minAppVersion': '9.0.0'}))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.incompatible)),
      );
      await expectLater(
        inst.install(_MemorySource(await build(manifestExtra: {'formatVersion': 2}))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.incompatible)),
      );
      expect(await inst.installed(), isEmpty);
    });

    test('dimensione diversa da quella dichiarata', () async {
      await expectLater(
        installer().install(_MemorySource(await build(manifestExtra: {
          'sizes': {'story.json': 1, 'assets/audio/base.txt': 12, 'i18n/en/story.json': 14, 'i18n/en/audio/a.txt': 8, 'i18n/fr/story.json': 14, 'i18n/fr/audio/a.txt': 8}
        }))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.notVerified)),
      );
    });

    test('percorso con ..', () async {
      await expectLater(
        installer().install(_MemorySource(await build(files: {'story.json': '{}', '../fuori.txt': 'x'}))),
        throwsA(isA<InstallException>()),
      );
      expect(File(p.join(contentRoot.path, 'fuori.txt')).existsSync(), isFalse);
    });

    test('spazio insufficiente (simulato): prima del download e prima dell\'estrazione', () async {
      final bytes = await build();
      final inst = installer(free: () => 10);
      await expectLater(
        inst.install(_MemorySource(bytes)),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.insufficientSpace)),
      );
      expect(await inst.installed(), isEmpty);

      // Basta per lo zip ma non per estrarlo.
      final tight = installer(free: () => bytes.length + 5);
      await expectLater(
        tight.install(_MemorySource(bytes)),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.insufficientSpace)),
      );
      expect(await tight.installed(), isEmpty);
      expect(Directory(p.join(contentRoot.path, 'packages')).existsSync() && Directory(p.join(contentRoot.path, 'packages')).listSync().isNotEmpty, isFalse);
    });

    for (final stage in ['downloaded', 'staged', 'swapped']) {
      test('interruzione a metà ($stage): la v1 resta utilizzabile e il recupero ripulisce', () async {
        await installer().install(_MemorySource(await build()));
        final broken = installer(checkpoint: (s) async {
          if (s == stage) throw StateError('processo ucciso');
        });
        await expectLater(broken.install(_MemorySource(await build(version: 2))), throwsA(isA<StateError>()));

        // Riavvio: un installatore nuovo legge l'indice dal disco.
        final after = installer();
        expect((await after.find('lia'))!.version, 1);
        expect(story('lia', 1), contains('"v":1'));
        await after.recover();
        expect(leftovers(), isTrue);
        expect(Directory(p.join(contentRoot.path, 'packages', 'lia', '2')).existsSync(), isFalse);
        // E l'aggiornamento riparte e riesce.
        expect((await after.install(_MemorySource(await build(version: 2)))).version, 2);
      });
    }

    test('downgrade rifiutato', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build(version: 2)));
      await expectLater(
        inst.install(_MemorySource(await build(version: 1))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.downgrade)),
      );
    });
  });

  group('robustezza dell installatore (R3 C-22)', () {
    test('downgrade rifiutato anche dopo remove', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build(version: 2)));
      await inst.remove('lia');
      await expectLater(
        installer().install(_MemorySource(await build(version: 1))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.downgrade)),
      );
      expect((await installer().install(_MemorySource(await build(version: 3)))).version, 3);
    });

    test('index.json illeggibile: errore e file intatto, mai sovrascritto', () async {
      contentRoot.createSync(recursive: true);
      final index = File(p.join(contentRoot.path, 'index.json'))..writeAsStringSync('{non json');
      await expectLater(
        installer().install(_MemorySource(await build())),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.io)),
      );
      expect(index.readAsStringSync(), '{non json');
    });

    test('errore non di verifica: il .part non resta a bloccare il tentativo successivo', () async {
      final bytes = await build();
      var boom = true;
      final inst = installer(checkpoint: (stage) async {
        if (boom && stage == 'downloaded') throw StateError('imprevisto');
      });
      await expectLater(inst.install(_MemorySource(bytes)), throwsA(isA<StateError>()));
      expect(File(p.join(contentRoot.path, 'tmp', 'pkg.part')).existsSync(), isFalse);
      boom = false;
      expect((await inst.install(_MemorySource(bytes))).version, 1);
    });

    test('archivio oltre il tetto: rifiutato prima di scaricare', () async {
      final huge = _HugeSource();
      await expectLater(
        installer().install(huge),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.notVerified)),
      );
      expect(huge.read_, isFalse);
    });
  });

  group('download con ripresa', () {
    test('riparte dall\'offset già scaricato', () async {
      final bytes = await build();
      final inst = installer();
      final cut = bytes.length ~/ 3;
      final flaky = _MemorySource(bytes, failAfter: cut);
      await expectLater(inst.install(flaky), throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.io)));
      expect(await inst.installed(), isEmpty);
      expect(File(p.join(contentRoot.path, 'tmp', 'pkg.part')).lengthSync(), cut);

      final again = _MemorySource(bytes);
      await inst.install(again);
      expect(again.offsets, [cut]);
      expect((await inst.find('lia'))!.version, 1);
    });
  });

  group('ritiro e rollback', () {
    test('la versione ritirata torna alla precedente', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build()));
      await inst.install(_MemorySource(await build(version: 2)));
      final changed = await inst.applyRetirements(await signedRetired(1, [
        {'id': 'lia', 'versions': [2], 'reason': 'errore'}
      ]));
      expect(changed, ['lia']);
      expect((await inst.find('lia'))!.version, 1);
      expect(story('lia', 1), contains('"v":1'));
      expect(Directory(p.join(contentRoot.path, 'packages', 'lia', '2')).existsSync(), isFalse);
      // Non si reinstalla una versione ritirata.
      await expectLater(
        inst.install(_MemorySource(await build(version: 2))),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.retired)),
      );
      // Lo stato sopravvive al riavvio.
      expect(await installer().isRetired('lia', 2), isTrue);
    });

    test('senza versione precedente il pacchetto viene tolto', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build()));
      await inst.applyRetirements(await signedRetired(1, [
        {'id': 'lia', 'maxVersion': 1, 'reason': 'ritirata'}
      ]));
      expect(await inst.find('lia'), isNull);
    });

    test('elenco con firma sbagliata, e sequenza già vista, non cambiano nulla', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build()));
      await expectLater(
        inst.applyRetirements(await signedRetired(1, [
          {'id': 'lia', 'maxVersion': 1, 'reason': 'x'}
        ], signer: stranger)),
        throwsA(isA<InstallException>().having((e) => e.failure, 'failure', InstallFailure.notVerified)),
      );
      expect((await inst.find('lia'))!.version, 1);

      await inst.applyRetirements(await signedRetired(5, []));
      // Un elenco vecchio (replay) con un ritiro è ignorato.
      final old = await signedRetired(3, [
        {'id': 'lia', 'maxVersion': 1, 'reason': 'x'}
      ]);
      expect(await inst.applyRetirements(old), isEmpty);
      expect((await inst.find('lia'))!.version, 1);
    });
  });

  group('Mantieni offline e cache', () {
    test('la cache elimina solo ciò che non è tenuto offline', () async {
      final inst = installer();
      await inst.install(_MemorySource(await build(id: 'a'), name: 'a'));
      await inst.install(_MemorySource(await build(id: 'b'), name: 'b'), keepOffline: true);
      await inst.install(_MemorySource(await build(id: 'b', version: 2), name: 'b2'));
      expect((await inst.find('b'))!.keepOffline, isTrue); // il flag sopravvive all'aggiornamento
      final freed = await inst.evictCache();
      expect(freed, greaterThan(0));
      expect(await inst.find('a'), isNull);
      final b = (await inst.find('b'))!;
      expect(b.version, 2);
      expect(b.previousVersion, isNull); // la versione di rollback è cache
      expect(Directory(p.join(contentRoot.path, 'packages', 'b', '1')).existsSync(), isFalse);
      await inst.setKeepOffline('b', false);
      expect((await installer().find('b'))!.keepOffline, isFalse);
    });
  });

  test('installare, aggiornare, ritirare e rimuovere non toccano il DB dei progressi', () async {
    final db = File(p.join(support.path, 'mirabo.db'))..writeAsBytesSync(List.generate(512, (i) => i % 251));
    final before = sha256.convert(db.readAsBytesSync());
    final stamp = db.lastModifiedSync();

    final inst = installer();
    await inst.install(_MemorySource(await build()));
    await inst.install(_MemorySource(await build(version: 2)));
    await inst.applyRetirements(await signedRetired(1, [
      {'id': 'lia', 'versions': [2], 'reason': 'x'}
    ]));
    await inst.evictCache();
    await inst.remove('lia');
    await expectLater(inst.install(_MemorySource(await build(version: 3, tamperPath: 'story.json'))), throwsA(isA<InstallException>()));

    expect(db.existsSync(), isTrue);
    expect(sha256.convert(db.readAsBytesSync()), before);
    expect(db.lastModifiedSync(), stamp);
    // Tutto ciò che l'installatore ha scritto sta sotto la sua cartella.
    final others = support.listSync().map((e) => p.basename(e.path)).toSet();
    expect(others, {'mirabo.db', 'content'});
  });
}
