import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/games/balloon_game.dart';
import 'package:mirabo/games/drawing_game.dart';
import 'package:mirabo/games/game.dart';
import 'package:mirabo/games/memory_game.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/theme.dart';

/// M13: i giochi si usano anche con TalkBack/VoiceOver, quindi ogni controllo ha
/// un nome e un'azione di tocco (onTapDown da solo non basta). La prova reale
/// sul dispositivo resta da fare.

GameContext _ctx(AgeBand band) => GameContext(band: band, say: (t) async {}, onFinished: () {}, calm: true);

Future<void> _pump(WidgetTester tester, Widget game) async {
  await tester.binding.setSurfaceSize(const Size(1000, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('it'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: miraboTheme(dyslexiaFont: false, lowStimulation: false),
    home: Scaffold(body: game),
  ));
}

void main() {
  testWidgets('memory: carte coperte con nome, scoperte con il nome dell\'oggetto e non l\'emoji', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, MemoryGame(ctx: _ctx(AgeBand.b3to5)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.bySemanticsLabel('Carta coperta'), findsNWidgets(6));
    tester.semantics.tap(find.semantics.byLabel('Carta coperta').first);
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.bySemanticsLabel('Carta coperta'), findsNWidgets(5));
    expect(find.bySemanticsLabel(RegExp(r', scoperta$')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('disegno: ogni colore ha il nome e si sceglie con l\'azione di tocco', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, DrawingGame(ctx: _ctx(AgeBand.b6to7)));

    for (final n in ['rosa', 'arancio', 'giallo', 'verde', 'azzurro', 'viola', 'marrone', 'nero']) {
      expect(find.bySemanticsLabel('Colore $n'), findsOneWidget, reason: n);
    }
    final green = find.bySemanticsLabel('Colore verde');
    expect(tester.getSemantics(green).getSemanticsData().flagsCollection.isSelected, isNot(Tristate.isTrue));
    tester.semantics.tap(find.semantics.byLabel('Colore verde'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSemantics(green).getSemanticsData().flagsCollection.isSelected, Tristate.isTrue);
    semantics.dispose();
  });

  testWidgets('palloncini: l\'azione di tocco scoppia il palloncino', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, BalloonGame(ctx: _ctx(AgeBand.b3to5)));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final before = find.bySemanticsLabel(RegExp(r'^Palloncino')).evaluate().length;
    expect(before, greaterThan(0));
    final b = find.bySemanticsLabel(RegExp(r'^Palloncino')).first;
    expect(tester.getSemantics(b).getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.semantics.tap(find.semantics.byLabel(RegExp(r'^Palloncino')).first);
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.bySemanticsLabel(RegExp(r'^Palloncino')).evaluate().length, lessThan(before));
    semantics.dispose();
  });
}
