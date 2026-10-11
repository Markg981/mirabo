import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/package_verifier.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

/// I test leggono direttamente i file in content/ e dist/, così il modello Dart
/// e lo studio Python non possono divergere senza che qualcuno se ne accorga.
void main() {
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;
  final stories = Directory('${root.path}/content/stories');

  test('tutte le storie in content/ si caricano nel modello', () {
    for (final dir in stories.listSync().whereType<Directory>()) {
      final meta = Story.fromJson(jsonDecode(File('${dir.path}/story.json').readAsStringSync()));
      expect(meta.id, dir.uri.pathSegments.where((s) => s.isNotEmpty).last);
      for (final entry in meta.variantFiles.entries) {
        final v = StoryVariant.fromJson(jsonDecode(File('${dir.path}/${entry.value}').readAsStringSync()));
        expect(v.ageBand, entry.key);
        expect(v.screens.first.kind, ScreenKind.hook);
        expect(v.screens.last.kind, ScreenKind.closing);
        expect(v.screens.where((s) => s.isKeyPhrase).length, 1);
      }
    }
  });

  test('il profilo nasconde sicurezza in modalità da solo', () {
    const p = ChildProfile(id: 1, name: 'Test', ageBand: AgeBand.b5to7, companion: CompanionId.bo);
    final safety = Story.fromJson({
      'id': 'x', 'version': 1, 'title': 'x', 'world': 'sicurezza', 'topic': 'corpo',
      'ageBands': {'5-7': '5-7.json'}, 'formats': ['illustrated'], 'togetherOnly': false,
      'keyPhrase': 'k', 'parentCard': 'parent.md', 'sources': [],
    });
    expect(p.canOpen(safety, SessionMode.together), isTrue);
    expect(p.canOpen(safety, SessionMode.alone), isFalse);
  });

  test('il compagno cresce con le storie completate', () {
    const p = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b3to5, companion: CompanionId.pilu);
    expect(p.companionStage, 0);
    expect(p.copyWith(storiesCompleted: 3).companionStage, 1);
    expect(p.copyWith(storiesCompleted: 12).companionStage, 3);
  });

  test('un pacchetto firmato dallo studio viene accettato, uno manomesso no', () async {
    final dist = Directory('${root.path}/dist');
    final keyFile = File('${root.path}/app/lib/content/trusted_key.dart');
    if (!dist.existsSync() || !keyFile.existsSync()) {
      markTestSkipped('esegui prima: python studio/sync_assets.py');
      return;
    }
    final pkgFile = dist.listSync().whereType<File>().firstWhere((f) => f.path.endsWith('.mirabo'));
    final verifier = PackageVerifier();
    final pkg = await verifier.open(pkgFile.readAsBytesSync());
    expect(pkg.json('story.json'), isNotNull);

    final other = PackageVerifier(publicKeyHex: '00' * 32);
    expect(() => other.open(pkgFile.readAsBytesSync()), throwsA(isA<PackageVerificationException>()));
  });
}
