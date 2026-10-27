import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/package_verifier.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/models/story.dart';

String _hex(List<int> b) => b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

/// Un pacchetto incoerente non deve fermare l'avvio né lasciare storie illeggibili.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;
  final variant6 = File('${root.path}/content/stories/albero-silenzioso/6-7.json').readAsStringSync();
  late SimpleKeyPair key;
  late String keyHex;

  setUpAll(() async {
    key = await Ed25519().newKeyPair();
    keyHex = _hex((await key.extractPublicKey()).bytes);
  });

  Uint8List u(String s) => Uint8List.fromList(utf8.encode(s));

  Future<Uint8List> pack(Map<String, Uint8List> files, {Object? manifestFiles, Object version = 1, required String id, Map<String, dynamic> extra = const {}}) async {
    final manifest = <String, dynamic>{
      'id': id,
      'kind': 'story',
      'version': version,
      ...extra,
      'files': manifestFiles ?? {for (final e in files.entries) e.key: sha256.convert(e.value).toString()},
    };
    final sig = await Ed25519().sign(utf8.encode(PackageVerifier.canonicalJson(manifest)), keyPair: key);
    final archive = Archive()
      ..addFile(ArchiveFile('manifest.json', 1, u(jsonEncode({...manifest, 'signature': _hex(sig.bytes)}))));
    files.forEach((n, b) => archive.addFile(ArchiveFile(n, b.length, b)));
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  Map<String, Uint8List> story(String id, Map<String, String> bands, {Map<String, String> variants = const {}}) => {
        'story.json': u(jsonEncode({
          'id': id,
          'version': 1,
          'title': id,
          'world': 'ambiente',
          'topic': 't',
          'ageBands': bands,
          'formats': ['illustrated'],
          'togetherOnly': false,
          'keyPhrase': 'k',
          'parentCard': 'parent.md',
          'sources': [],
        })),
        'parent.md': u('x'),
        for (final e in variants.entries) e.key: u(e.value),
      };

  Future<StoryRepository> load(Map<String, Uint8List> pkgs, {String appVersion = '0.1.0', String themes = '{"cells":[]}'}) async {
    final assets = <String, Uint8List>{
      'assets/education/themes.json': u(themes),
      'assets/companions/companions.json': u('{"companions":[]}'),
      'assets/stories/index.json': u(jsonEncode(pkgs.keys.toList())),
      for (final e in pkgs.entries) 'assets/stories/${e.key}': e.value,
    };
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (m) async {
      final b = assets[utf8.decode(m!.buffer.asUint8List())];
      return b == null ? null : ByteData.sublistView(b);
    });
    addTearDown(() => messenger.setMockMessageHandler('flutter/assets', null));
    for (final k in assets.keys) {
      rootBundle.evict(k);
    }
    final repo = StoryRepository(verifier: PackageVerifier(publicKeyHex: keyHex), appVersion: appVersion);
    await repo.load();
    return repo;
  }

  test('un pacchetto con il manifest di tipo errato viene scartato e registrato, gli altri restano', () async {
    final repo = await load({
      'ok.mirabo': await pack(story('ok', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}), id: 'ok'),
      'rotto.mirabo': await pack(story('rotto', {'6-7': '6-7.json'}), manifestFiles: 5, id: 'rotto'),
    });
    expect(repo.stories.map((s) => s.id), ['ok']);
    expect(repo.rejected.single, contains('rotto.mirabo'));
  });

  test('version di tipo errato o hash non stringa nel manifest scartano solo quel pacchetto', () async {
    final repo = await load({
      'ok.mirabo': await pack(story('ok', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}), id: 'ok'),
      'ver.mirabo': await pack(story('ver', {'6-7': '6-7.json'}), version: '1', id: 'ver'),
      'hash.mirabo': await pack(story('hash', {'6-7': '6-7.json'}), manifestFiles: {'story.json': 5}, id: 'hash'),
    });
    expect(repo.stories.map((s) => s.id), ['ok']);
    expect(repo.rejected, hasLength(2));
  });

  test('un JSON italiano illeggibile scarta solo quel pacchetto', () async {
    final repo = await load({
      'ok.mirabo': await pack(story('ok', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}), id: 'ok'),
      'json.mirabo': await pack(story('json', {'6-7': '6-7.json'}, variants: {'6-7.json': '{"ageBand": 7}'}), id: 'json'),
    });
    expect(repo.stories.map((s) => s.id), ['ok']);
    expect(repo.rejected, hasLength(1));
  });

  test('una traduzione rotta esclude la storia da quella lingua, senza ripiegare sull italiano', () async {
    final repo = await load({
      'ok.mirabo': await pack(story('ok', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}), id: 'ok'),
      'tr.mirabo': await pack(
        story('tr', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6, 'i18n/de/6-7.json': '{"screens": 3}'}),
        id: 'tr',
      ),
    });
    expect(repo.storiesIn('it').map((s) => s.id), unorderedEquals(['ok', 'tr']));
    expect(repo.storiesIn('de').map((s) => s.id), ['ok']);
    expect(repo.rejected, isEmpty);
  });

  test('un themes.json illeggibile è segnalato tra i contenuti rifiutati', () async {
    final repo = await load({}, themes: 'non json');
    expect(repo.themes.isEmpty, isTrue);
    expect(repo.rejected.single, contains('themes.json'));
  });

  test('una variante assente non è offerta; senza varianti leggibili la storia è scartata', () async {
    final repo = await load({
      'meta.mirabo': await pack(
          story('meta', {'6-7': '6-7.json', '8-10': '8-10.json'}, variants: {'6-7.json': variant6}),
          id: 'meta'),
      'vuota.mirabo': await pack(
          story('vuota', {'6-7': '6-7.json'}, variants: {'6-7.json': '{"ageBand":"6-7","screens":[]}'}),
          id: 'vuota'),
    });
    final s = repo.byId('meta')!;
    expect(s.supports(AgeBand.b6to7), isTrue);
    expect(s.supports(AgeBand.b8to10), isFalse);
    expect(repo.byId('vuota'), isNull);
    expect(repo.rejected.single, contains('vuota'));
  });

  test('un pacchetto che richiede una versione più recente della app viene scartato, gli altri restano', () async {
    final repo = await load({
      'ok.mirabo': await pack(story('ok', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}), id: 'ok'),
      'nuovo.mirabo': await pack(story('nuovo', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}),
          id: 'nuovo', extra: {'minAppVersion': '9.0.0'}),
    });
    expect(repo.stories.map((s) => s.id), ['ok']);
    expect(repo.rejected.single, allOf(contains('nuovo.mirabo'), contains('9.0.0')));
  });

  test('un formato più recente di quello supportato viene scartato', () async {
    final repo = await load({
      'f2.mirabo': await pack(story('f2', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}),
          id: 'f2', extra: {'formatVersion': 2}),
    });
    expect(repo.stories, isEmpty);
    expect(repo.rejected.single, contains('formato 2'));
  });

  test('un id duplicato non sostituisce il primo pacchetto: il secondo è scartato', () async {
    final repo = await load({
      'a.mirabo': await pack(story('uno', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}), id: 'uno'),
      'b.mirabo': await pack(story('uno', {'6-7': '6-7.json'}, variants: {'6-7.json': variant6}), id: 'uno'),
    });
    expect(repo.stories.map((s) => s.id), ['uno']);
    expect(repo.rejected.single, allOf(contains('b.mirabo'), contains('duplicato')));
  });
}
