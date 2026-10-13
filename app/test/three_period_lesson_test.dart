import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/l10n/app_localizations.dart';
import 'package:mirabo/l10n/app_localizations_it.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/models/three_period_lesson.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/child/lesson_board.dart';

final l10nIt = AppLocalizationsIt();

Lesson _lesson() => Lesson.fromJson({
      'together': 'Indica e nomina.',
      'ask': 'E questa, cos\'è?',
      'done': 'La luna, la stella, il sole.',
      'items': [
        for (final (id, e) in [('luna', '🌙'), ('stella', '⭐'), ('sole', '☀️')])
          {'id': id, 'e': e, 'name': id, 'this': 'Questa è $id.', 'show': 'Dov\'è $id?'},
      ],
    });

/// Porta la lezione al secondo tempo nominando le figure in ordine.
LessonRun _toRecognition(Lesson l, {int seed = 1}) {
  final run = LessonRun(l, random: Random(seed));
  for (final i in l.items) {
    run.tap(i.id);
  }
  return run;
}

void main() {
  test('primo tempo: nomina una figura alla volta, in ordine', () {
    final l = _lesson();
    final run = LessonRun(l, random: Random(1));
    expect(run.period, LessonPeriod.naming);
    expect(run.focus!.id, 'luna');
    expect(run.prompt, 'Questa è luna.');
    expect(run.showsName(l.item('stella')), isFalse);
    // Una figura non ancora nominata non si anticipa.
    expect(run.tap('sole'), 'Questa è luna.');
    expect(run.focus!.id, 'luna');
    expect(run.tap('luna'), 'Questa è stella.');
    // Una già nominata si ripete senza tornare indietro.
    expect(run.tap('luna'), 'Questa è luna.');
    expect(run.focus!.id, 'stella');
    run.tap('stella');
    run.tap('sole');
    expect(run.period, LessonPeriod.recognition);
  });

  test('secondo tempo: un tocco altrove dice il nome toccato, mai "sbagliato"', () {
    final l = _lesson();
    final run = _toRecognition(l);
    final target = l.items.firstWhere((i) => run.prompt == i.show);
    final other = l.items.firstWhere((i) => i != target);
    expect(run.focus, isNull);
    expect(run.tap(other.id), '${other.naming} ${target.show}');
    expect(run.focus, isNull);
    run.tap(other.id);
    // Dopo due tocchi altrove la figura chiesta si illumina.
    expect(run.focus, target);
    run.tap(target.id);
    expect(run.focus, isNull);
    for (var i = 0; i < 2; i++) {
      run.tap(l.items.firstWhere((x) => run.prompt == x.show).id);
    }
    expect(run.period, LessonPeriod.recall);
  });

  test('il secondo tempo non comincia dalla figura appena nominata', () {
    for (var seed = 0; seed < 30; seed++) {
      final run = _toRecognition(_lesson(), seed: seed);
      expect(run.prompt, isNot('Dov\'è sole?'), reason: 'seed $seed');
    }
  });

  test('terzo tempo: domanda, poi il nome toccando la figura, poi la successiva', () {
    final l = _lesson();
    final run = _toRecognition(l);
    for (var i = 0; i < 3; i++) {
      run.tap(l.items.firstWhere((x) => run.prompt == x.show).id);
    }
    final seen = <String>{};
    for (var i = 0; i < 3; i++) {
      final focus = run.focus!;
      expect(run.prompt, l.ask);
      expect(run.showsName(focus), isFalse);
      // Le altre figure non rispondono.
      expect(run.tap(l.items.firstWhere((x) => x != focus).id), isNull);
      expect(run.tap(focus.id), focus.naming);
      expect(run.revealed, isTrue);
      expect(run.showsName(focus), isTrue);
      seen.add(focus.id);
      run.advance();
    }
    expect(seen, {'luna', 'stella', 'sole'});
    expect(run.isDone, isTrue);
    expect(run.prompt, l.done);
    expect(l.items.every(run.showsName), isTrue);
  });

  testWidgets('la tavola: il tocco arriva alla lezione, i nomi spariscono nel secondo tempo', (tester) async {
    final semantics = tester.ensureSemantics();
    final l = _lesson();
    final run = LessonRun(l, random: Random(1));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
      theme: miraboTheme(dyslexiaFont: false, lowStimulation: true),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => Column(children: [
            Expanded(
              child: LessonBoard(
                lesson: l,
                run: run,
                alt: 'Tre figure in fila',
                color: Colors.blue,
                onTap: (i) => setState(() => run.tap(i.id)),
              ),
            ),
            LessonPeriods(period: run.period),
          ]),
        ),
      ),
    ));
    double nameOpacity(String name) =>
        tester.widget<Opacity>(find.ancestor(of: find.text(name), matching: find.byType(Opacity)).first).opacity;

    expect(nameOpacity('luna'), 1);
    expect(nameOpacity('stella'), 0);
    for (final e in ['🌙', '⭐', '☀️']) {
      await tester.tap(find.text(e));
      await tester.pump();
    }
    expect(run.period, LessonPeriod.recognition);
    expect(nameOpacity('luna'), 0);
    expect(find.bySemanticsLabel(l10nIt.lessonShow), findsOneWidget);
    semantics.dispose();
  });

  test('ogni variante 3-5 in content/ ha una sola lezione e solo lì', () {
    final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;
    var lessons = 0;
    for (final dir in Directory('${root.path}/content/stories').listSync().whereType<Directory>()) {
      final meta = Story.fromJson(jsonDecode(File('${dir.path}/story.json').readAsStringSync()));
      for (final entry in meta.variantFiles.entries) {
        final v = StoryVariant.fromJson(jsonDecode(File('${dir.path}/${entry.value}').readAsStringSync()));
        final screens = v.screens.where((s) => s.kind == ScreenKind.lesson).toList();
        expect(screens.length, entry.key == AgeBand.b3to5 ? 1 : 0, reason: '${meta.id} ${entry.key.key}');
        for (final s in screens) {
          expect(s.lesson!.items.length, inInclusiveRange(2, 3));
          // Tutta la lezione si deve poter fare fino in fondo.
          final run = LessonRun(s.lesson!, random: Random(7));
          for (var guard = 0; !run.isDone && guard < 50; guard++) {
            final target = run.period == LessonPeriod.recognition
                ? s.lesson!.items.firstWhere((x) => x.show == run.prompt)
                : run.focus!;
            run.tap(target.id);
            if (run.revealed) run.advance();
          }
          expect(run.isDone, isTrue);
          lessons++;
        }
      }
    }
    expect(lessons, greaterThanOrEqualTo(3));
  });
}
