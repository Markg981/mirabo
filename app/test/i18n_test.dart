import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/story.dart';

/// Le traduzioni sono overlay sui file italiani: cambiano i testi, mai la struttura.
void main() {
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;
  final stories = Directory('${root.path}/content/stories');
  dynamic readJson(String path) => jsonDecode(File(path).readAsStringSync());

  test('mergeTranslation sostituisce i testi e conserva il resto', () {
    final base = {
      'title': 'Ciao',
      'n': 1,
      'list': [
        {'text': 'uno', 'x': 0.1},
        {'text': 'due', 'x': 0.2},
      ],
    };
    final merged = mergeTranslation(base, {
      'title': 'Hello',
      'list': [
        {'text': 'one'},
      ],
    }) as Map;
    expect(merged['title'], 'Hello');
    expect(merged['n'], 1);
    expect(merged['list'][0], {'text': 'one', 'x': 0.1});
    expect(merged['list'][1], {'text': 'due', 'x': 0.2});
    expect(mergeTranslation(base, null), same(base));
  });

  test('le storie tradotte si caricano e conservano scene e struttura', () {
    for (final dir in stories.listSync().whereType<Directory>()) {
      final i18n = Directory('${dir.path}/i18n');
      if (!i18n.existsSync()) continue;
      final metaJson = readJson('${dir.path}/story.json') as Map<String, dynamic>;
      final it = Story.fromJson(metaJson);
      for (final langDir in i18n.listSync().whereType<Directory>()) {
        final lang = langDir.uri.pathSegments.where((s) => s.isNotEmpty).last;
        expect(AppLanguage.fromCode(lang).code, lang, reason: 'lingua $lang non supportata');
        final meta = Story.fromJson(
            mergeTranslation(metaJson, readJson('${langDir.path}/story.json')) as Map<String, dynamic>);
        expect(meta.id, it.id);
        expect(meta.title, isNot(it.title));
        for (final file in it.variantFiles.values) {
          final baseJson = readJson('${dir.path}/$file') as Map<String, dynamic>;
          final base = StoryVariant.fromJson(baseJson);
          final v = StoryVariant.fromJson(
              mergeTranslation(baseJson, readJson('${langDir.path}/$file')) as Map<String, dynamic>);
          expect(v.screens.length, base.screens.length);
          for (var i = 0; i < v.screens.length; i++) {
            expect(v.screens[i].kind, base.screens[i].kind);
            expect(v.screens[i].illustration.scene?.items.length, base.screens[i].illustration.scene?.items.length);
            if (base.screens[i].text != null) expect(v.screens[i].text, isNot(base.screens[i].text));
          }
        }
      }
    }
  });

  test('i compagni hanno le traduzioni per tutte le lingue', () {
    final data = readJson('${root.path}/content/companions/companions.json') as Map<String, dynamic>;
    for (final c in (data['companions'] as List).cast<Map<String, dynamic>>()) {
      for (final lang in AppLanguage.values.where((l) => l != AppLanguage.it)) {
        final over = (c['i18n'] as Map?)?[lang.code] as Map?;
        expect(over, isNotNull, reason: '${c['id']} senza ${lang.code}');
        expect((over!['growth'] as List).length, (c['growth'] as List).length);
      }
    }
  });
}
