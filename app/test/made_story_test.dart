import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/made_story.dart';

MadeStory _story(Map<FactoryStep, String> parts, {String? title}) =>
    MadeStory(profileId: 1, parts: parts, title: title, when: DateTime(2026, 10, 13));

/// Ogni combinazione di un passo con il primo pezzo degli altri: copre ogni
/// pezzo almeno una volta senza provare tutte le 21.600 storie.
Iterable<MadeStory> _covering() sync* {
  final first = {for (final s in FactoryStep.values) s: StoryParts.of(s).first.id};
  for (final s in FactoryStep.values) {
    for (final p in StoryParts.of(s)) {
      yield _story({...first, s: p.id});
    }
  }
}

/// Il messaggio ICU ha il caso `id{...}`.
bool hasCase(String message, String id) => RegExp(r'(^|[\s,])' + RegExp.escape(id) + r'\{').hasMatch(message);

void main() {
  test('ogni pezzo ha il suo caso in tutte le lingue', () {
    // Il `select` senza il caso cade su `other` e stampa l'id: si controlla
    // negli ARB che ogni id abbia il suo testo.
    const keys = {
      FactoryStep.who: ['factoryWhoA', 'factoryWhoThe'],
      FactoryStep.place: ['factoryPlaceName', 'factoryPlaceIn'],
      FactoryStep.problem: ['factoryProblemName', 'factoryProblem', 'factorySolution'],
      FactoryStep.feeling: ['factoryFeelingName', 'factoryFeeling'],
      FactoryStep.helper: ['factoryHelperA'],
      FactoryStep.ending: ['factoryEndingName', 'factoryEnding'],
    };
    for (final lang in AppLanguage.values) {
      final arb = jsonDecode(File('lib/l10n/app_${lang.code}.arb').readAsStringSync()) as Map<String, dynamic>;
      for (final step in FactoryStep.values) {
        expect(hasCase(arb['factoryAsk'] as String, step.name), isTrue, reason: '[$lang] factoryAsk/${step.name}');
        for (final key in keys[step]!) {
          for (final p in StoryParts.of(step)) {
            expect(hasCase(arb[key] as String, p.id), isTrue, reason: '[$lang] $key/${p.id}');
          }
        }
      }
    }
  });

  test('le pagine si compongono senza segnaposto rimasti', () {
    for (final lang in AppLanguage.values) {
      final l = lookupAppLocalizations(lang.locale);
      for (final story in _covering()) {
        final pages = story.pages(l);
        expect(pages, hasLength(5));
        for (final page in pages) {
          expect(page.text, isNot(contains('{')), reason: '[$lang] ${page.text}');
          expect(page.text.trim(), endsWith('.'), reason: '[$lang] ${page.text}');
          expect(page.text[0], page.text[0].toUpperCase(), reason: '[$lang] maiuscola: ${page.text}');
          expect(page.scene.background, story.part(FactoryStep.place));
        }
      }
    }
  });

  test('il protagonista ha la maiuscola solo a inizio frase', () {
    final l = lookupAppLocalizations(const Locale('it'));
    final story = _story({
      FactoryStep.who: 'dragon',
      FactoryStep.place: 'forest',
      FactoryStep.problem: 'storm',
      FactoryStep.feeling: 'fear',
      FactoryStep.helper: 'owl',
      FactoryStep.ending: 'party',
    });
    final pages = story.pages(l);
    expect(pages[0].text, "C'era una volta un piccolo drago, che viveva in un bosco pieno di alberi.");
    expect(pages[2].text, startsWith('Il piccolo drago sentì'));
    expect(pages[4].text, 'E quella sera il piccolo drago fece una grande festa con tutti gli amici.');
    expect(story.titleIn(l), 'Il piccolo drago');
    expect(_story(story.parts, title: '  Il drago e il temporale ').titleIn(l), 'Il drago e il temporale');
  });

  test('in tedesco le parole stanno nell\'ordine giusto', () {
    final l = lookupAppLocalizations(const Locale('de'));
    final story = _story({
      FactoryStep.who: 'unicorn',
      FactoryStep.place: 'snow',
      FactoryStep.problem: 'lost',
      FactoryStep.feeling: 'courage',
      FactoryStep.helper: 'bear',
      FactoryStep.ending: 'sleep',
    });
    final pages = story.pages(l);
    expect(pages[0].text, 'Es war einmal ein Einhorn auf einer Wiese voller Schnee.');
    expect(pages[1].text, 'Eines Tages versteckte der Nebel den Weg nach Hause.');
    expect(pages[3].text, startsWith('Zum Glück kam ein freundlicher Bär. Gemeinsam folgten sie'));
    expect(pages[4].text, 'Und am Abend schlief das Einhorn glücklich unter einer warmen Decke ein.');
  });

  test('si salva e si rilegge dal database', () {
    final story = _covering().first;
    final row = story.toRow()..['id'] = 7;
    final back = MadeStory.fromRow(row);
    expect(back.id, 7);
    expect(back.parts, story.parts);
    expect(back.when, story.when);
    expect(story.toRow().containsKey('id'), isFalse, reason: 'una storia nuova prende l\'id dal database');
  });

  test('le figure stanno in piedi nella scena', () {
    final l = lookupAppLocalizations(const Locale('it'));
    for (final page in _covering().first.pages(l)) {
      final hero = page.scene.items.first;
      final feet = hero.y + hero.size / 2;
      expect(feet, inInclusiveRange(0.75, 0.95));
    }
  });
}
