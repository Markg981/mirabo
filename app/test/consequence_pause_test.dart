import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/models/story.dart';

/// La pausa di conseguenza: il bambino prova una mossa, il racconto mostra cosa
/// succede e si può riprovare. Nessuna mossa è sbagliata né punita.
void main() {
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;
  dynamic readJson(String path) => jsonDecode(File(path).readAsStringSync());

  test('il modello legge la pausa di conseguenza, con minTries a 1 se manca', () {
    final c = ConsequencePause.fromJson({
      'together': 'Chiedi.',
      'prompt': {'bo': 'a', 'pilu': 'b', 'tango': 'c'},
      'options': [
        {
          'id': 'uno',
          'icon': 'x',
          'label': 'Uno',
          'outcome': 'Succede questo.',
          'reaction': {'bo': 'a', 'pilu': 'b', 'tango': 'c'},
        },
      ],
    });
    expect(c.minTries, 1);
    expect(c.options.single.outcome, 'Succede questo.');
    expect(c.prompt.forCompanion(CompanionId.pilu), 'b');
  });

  test('le pause di conseguenza in content/: al massimo una per variante, con conseguenze per ogni mossa, anche tradotte', () {
    var pauses = 0;
    for (final dir in Directory('${root.path}/content/stories').listSync().whereType<Directory>()) {
      final meta = Story.fromJson(readJson('${dir.path}/story.json') as Map<String, dynamic>);
      for (final file in meta.variantFiles.values) {
        final base = readJson('${dir.path}/$file') as Map<String, dynamic>;
        final langs = [
          null,
          ...Directory('${dir.path}/i18n').listSync().whereType<Directory>().map((d) => d.path),
        ];
        for (final lang in langs) {
          final json = lang == null ? base : mergeTranslation(base, readJson('$lang/$file')) as Map<String, dynamic>;
          final v = StoryVariant.fromJson(json);
          final screens = v.screens.where((s) => s.kind == ScreenKind.consequence).toList();
          expect(screens.length, lessThanOrEqualTo(1), reason: '${meta.id} $file $lang');
          for (final s in screens) {
            final c = s.consequence!;
            expect(c.options.length, inInclusiveRange(2, 3));
            expect(c.minTries, lessThanOrEqualTo(c.options.length));
            expect(c.together, isNotEmpty);
            for (final o in c.options) {
              expect(o.outcome, isNotEmpty, reason: '${meta.id} ${o.id} $lang');
              for (final id in CompanionId.values) {
                expect(o.reaction.forCompanion(id), isNotEmpty);
              }
            }
            if (lang == null) pauses++;
          }
          expect(v.screens.where((s) => s.consequence != null && s.kind != ScreenKind.consequence), isEmpty);
        }
      }
    }
    expect(pauses, greaterThanOrEqualTo(1));
  });
}
