import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/package_verifier.dart';
import 'package:mirabo/models/activity.dart';
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

  test('gli inviti "leggiamo insieme" sono pochi, facoltativi e mai sulla pausa di dialogo', () {
    final v = StoryVariant.fromJson(
        jsonDecode(File('${stories.path}/albero-silenzioso/5-7.json').readAsStringSync()));
    final prompts = v.screens.where((s) => s.sharedPrompt != null).toList();
    expect(prompts, isNotEmpty);
    expect(prompts.length, lessThanOrEqualTo(v.screens.length ~/ 3));
    expect(prompts.any((s) => s.kind == ScreenKind.dialogue), isFalse);
    expect(prompts.map((s) => s.sharedPrompt!.role), containsAll([SharedPromptRole.help, SharedPromptRole.guide]));
    // Senza il campo la schermata resta quella di sempre.
    expect(v.screens.first.sharedPrompt, isNull);
  });

  test('tutte le attività in content/ si caricano nel modello', () {
    final dir = Directory('${root.path}/content/activities');
    for (final d in dir.listSync().whereType<Directory>()) {
      final a = Activity.fromJson(jsonDecode(File('${d.path}/activity.json').readAsStringSync()));
      expect(a.id, d.uri.pathSegments.where((s) => s.isNotEmpty).last);
      expect(a.levels, isNotEmpty);
      expect(a.level(99), a.levels.last);
      if (a.type == ActivityType.presentation) expect(a.module, ActivityModule.montessori);
    }
  });

  test('le aree si mappano da slug con il trattino', () {
    expect(ActivityArea.fromKey('vita-pratica'), ActivityArea.vitaPratica);
    expect(ActivityArea.fromKey('paure').module, ActivityModule.scuola);
    expect(ActivityArea.fromKey('cultura').module, ActivityModule.montessori);
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

  test('il compagno cresce con i gesti fatti davvero', () {
    const p = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b3to5, companion: CompanionId.pilu);
    expect(p.companionStage, 0);
    expect(p.copyWith(gesturesDone: 3).companionStage, 1);
    expect(p.copyWith(gesturesDone: 12).companionStage, 3);
  });

  test('un pacchetto firmato dallo studio viene accettato, uno manomesso no', () async {
    final dist = Directory('${root.path}/dist');
    final keyFile = File('${root.path}/app/lib/content/trusted_key.dart');
    if (!dist.existsSync() || !keyFile.existsSync()) {
      markTestSkipped('esegui prima: python studio/sync_assets.py');
      return;
    }
    final verifier = PackageVerifier();
    final files = dist.listSync().whereType<File>().where((f) => f.path.endsWith('.mirabo')).toList();
    expect(files, isNotEmpty);
    var stories = 0, activities = 0;
    for (final f in files) {
      final pkg = await verifier.open(f.readAsBytesSync());
      if (pkg.kind == 'activity') {
        expect(pkg.json('activity.json'), isNotNull);
        activities++;
      } else {
        expect(pkg.json('story.json'), isNotNull);
        stories++;
      }
    }
    // Le storie ci sono solo se pubblicate (o con --include-drafts): zero è un esito valido.
    expect(stories + activities, files.length);
    expect(activities, greaterThan(0));
    final pkgFile = files.first;

    final other = PackageVerifier(publicKeyHex: '00' * 32);
    expect(() => other.open(pkgFile.readAsBytesSync()), throwsA(isA<PackageVerificationException>()));
  });
}
