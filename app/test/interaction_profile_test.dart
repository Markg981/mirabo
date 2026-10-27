import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/l10n/app_localizations_it.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/activity/activity_player.dart';
import 'package:mirabo/ui/activity/types/tap_match_round.dart';
import 'package:mirabo/ui/child/read_along_text.dart';
import 'package:mirabo/ui/child/story_reader.dart';
import 'package:mirabo/ui/design/palette.dart';
import 'package:mirabo/ui/design/widgets.dart';

final l10nIt = AppLocalizationsIt();

const _small =
    InteractionProfile(hands: 1, reading: ReadingLevel.none, autonomy: 1);

Widget _app(Widget child,
        {InteractionProfile interaction = const InteractionProfile()}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
      theme: miraboTheme(
          dyslexiaFont: false, lowStimulation: true, interaction: interaction),
      home: Scaffold(body: child),
    );

ActivityContext _ctx(List<String> said) => ActivityContext(
      profile: const ChildProfile(
          id: 1,
          name: 'Ada',
          ageBand: AgeBand.b3to5,
          companion: CompanionId.pilu),
      companionName: 'Pilù',
      say: (t) async => said.add(t),
    );

const _fourOptions = {
  'rounds': [
    {
      'prompt': 'Tocca la mela',
      'options': [
        {'emoji': '🍐', 'label': 'Pera'},
        {'emoji': '🍎', 'label': 'Mela', 'correct': true},
        {'emoji': '🍌', 'label': 'Banana'},
        {'emoji': '🍇', 'label': 'Uva'},
      ],
    },
  ],
};

/// Il profilo di interazione (mani, lettura, autonomia) cambia l'interfaccia,
/// non i contenuti: la fascia d'età dà solo i valori iniziali.
void main() {
  group('modello', () {
    test("i valori iniziali vengono dalla fascia d'età", () {
      expect(InteractionProfile.forAge(AgeBand.b3to5), _small);
      expect(
          InteractionProfile.forAge(AgeBand.b6to7),
          const InteractionProfile(
              hands: 2, reading: ReadingLevel.letters, autonomy: 2));
      expect(InteractionProfile.forAge(AgeBand.b8to10).hands, 3);
      const p = ChildProfile(
          id: 1,
          name: 'Ada',
          ageBand: AgeBand.b3to5,
          companion: CompanionId.bo);
      expect(p.interaction, _small);
    });

    test(
        'tre colonne nel profilo: tornano uguali, e senza colonne (backup di prima) vale la fascia',
        () {
      const moved = InteractionProfile(
          hands: 2, reading: ReadingLevel.words, autonomy: 3);
      const p = ChildProfile(
          id: 1,
          name: 'Ada',
          ageBand: AgeBand.b3to5,
          companion: CompanionId.bo,
          interaction: moved);
      final row = p.toRow();
      expect(row['hands'], 2);
      expect(row['reading'], 'words');
      expect(row['autonomy'], 3);
      expect(ChildProfile.fromRow(row).interaction, moved);

      final old = Map.of(row)
        ..removeWhere(
            (k, _) => k == 'hands' || k == 'reading' || k == 'autonomy');
      expect(ChildProfile.fromRow(old).interaction, _small);
      expect(
          ChildProfile.fromRow(
                  {...old, 'hands': 2, 'reading': 'boh', 'autonomy': 1})
              .interaction,
          _small);
    });

    test('copyWith e la mensola non perdono il profilo di interazione', () {
      const moved = InteractionProfile(
          hands: 3, reading: ReadingLevel.fluent, autonomy: 2);
      const p = ChildProfile(
          id: 1,
          name: 'Ada',
          ageBand: AgeBand.b3to5,
          companion: CompanionId.bo,
          interaction: moved,
          readAlong: false);
      expect(p.copyWith(name: 'Bea').interaction, moved);
      expect(p.withShelf(['story:x']).interaction, moved);
      expect(p.withShelf(['story:x']).readAlong, isFalse);
      expect(p.copyWith(interaction: _small).interaction, _small);
    });
  });

  test('i token: target, tolleranza, opzioni e testo per ogni livello', () {
    MiraboTokens t(InteractionProfile p) =>
        MiraboTokens.forProfile(lowStimulation: false, interaction: p);
    expect([
      for (final h in [1, 2, 3]) t(InteractionProfile(hands: h)).minTarget
    ], [
      88,
      72,
      56
    ]);
    expect(t(_small).snapTolerance,
        greaterThan(t(const InteractionProfile()).snapTolerance));
    expect([
      for (final a in [1, 2, 3]) t(InteractionProfile(autonomy: a)).maxOptions
    ], [
      2,
      3,
      4
    ]);
    expect([
      for (final r in ReadingLevel.values)
        t(InteractionProfile(reading: r)).textMode
    ], [
      TextMode.hidden,
      TextMode.keyword,
      TextMode.karaoke,
      TextMode.full
    ]);
    expect(t(_small).repeatPrompt, isTrue);
    expect(t(_small).confirmExit, isTrue);
    expect(t(const InteractionProfile()).confirmExit, isFalse);
  });

  group('pickOptions', () {
    bool correct(String s) => s.startsWith('ok');

    test(
        'la risposta giusta resta sempre, le altre a caso, nell\'ordine del file',
        () {
      const all = ['a', 'b', 'ok', 'c'];
      for (var seed = 0; seed < 30; seed++) {
        final two = pickOptions(all, correct, 2, random: Random(seed));
        expect(two, hasLength(2));
        expect(two, contains('ok'));
        expect(two, orderedEquals(all.where(two.contains)));
      }
      expect(pickOptions(all, correct, 4), all);
    });

    test('con più risposte giuste ne resta almeno una e almeno una sbagliata',
        () {
      final two = pickOptions(['ok1', 'ok2', 'ok3', 'x'], correct, 2);
      expect(two.where(correct), hasLength(1));
      expect(two, contains('x'));
      expect(pickOptions(['ok1', 'ok2', 'x', 'y'], correct, 3).where(correct),
          hasLength(2));
    });

    test('senza risposte giuste (scene) se ne tengono quante ne stanno', () {
      expect(pickOptions(['a', 'b', 'c'], (_) => false, 2), hasLength(2));
    });
  });

  group('mani', () {
    testWidgets('con mani = 1 nessun bottone è più piccolo di 88 dp',
        (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(
        Column(
          children: [
            Row(children: [
              RoundIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'chiudi',
                  onPressed: () {}),
              ChunkyButton(
                  label: 'Avanti',
                  icon: Icons.arrow_forward_rounded,
                  height: 60,
                  onPressed: () {}),
              FilledButton(onPressed: () {}, child: const Text('Sì')),
              TextButton(onPressed: () {}, child: const Text('No')),
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              PicTile(emoji: '🐞', size: 60, onTap: () {}),
            ]),
            Expanded(
              child: TapMatchRound(
                  level: _fourOptions,
                  ctx: _ctx([]),
                  onRound: (_) {},
                  onFinished: () {}),
            ),
          ],
        ),
        interaction: _small,
      ));
      await tester.pump();

      final buttons = find.byWidgetPredicate((w) =>
          w is RoundIconButton ||
          w is ChunkyButton ||
          w is ButtonStyleButton ||
          w is IconButton ||
          w is BlockTile);
      expect(buttons, findsAtLeastNWidgets(8));
      for (final e in buttons.evaluate()) {
        final size = tester.getSize(find.byWidget(e.widget));
        expect(size.shortestSide, greaterThanOrEqualTo(88),
            reason: '${e.widget.runtimeType} $size');
      }
      // Anche il tasto "riascolta" della consegna.
      final listen = find.descendant(
          of: find.byType(PromptBar), matching: find.byType(InkWell));
      expect(tester.getSize(listen).shortestSide, greaterThanOrEqualTo(88));
    });

    testWidgets('le pagine dei grandi non ereditano i target del bambino',
        (tester) async {
      late MiraboTokens child, adult;
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          child = MiraboTokens.of(context);
          return AdultLocale(child: Builder(builder: (context) {
            adult = MiraboTokens.of(context);
            return FilledButton(onPressed: () {}, child: const Text('Salva'));
          }));
        }),
        interaction: _small,
      ));
      expect(child.minTarget, 88);
      expect(adult.minTarget, 56);
      expect(adult.textMode, TextMode.full);
      expect(tester.getSize(find.byType(FilledButton)).height, lessThan(88));
    });
  });

  group('autonomia', () {
    testWidgets(
        'con autonomia = 1 un round di tapMatch mostra al massimo 2 opzioni, tra cui quella giusta',
        (tester) async {
      for (var i = 0; i < 5; i++) {
        await tester.pumpWidget(_app(
          TapMatchRound(
              key: UniqueKey(),
              level: _fourOptions,
              ctx: _ctx([]),
              onRound: (_) {},
              onFinished: () {}),
          interaction: _small,
        ));
        expect(find.byType(PicTile), findsNWidgets(2));
        expect(find.text('🍎'), findsOneWidget);
      }

      // Un'app nuova, non un cambio di tema animato.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_app(
        TapMatchRound(
            key: UniqueKey(),
            level: _fourOptions,
            ctx: _ctx([]),
            onRound: (_) {},
            onFinished: () {}),
      ));
      expect(find.byType(PicTile), findsNWidgets(4));
    });

    testWidgets(
        'con autonomia = 1 la consegna si ripete se il bambino non tocca niente',
        (tester) async {
      final said = <String>[];
      await tester.pumpWidget(_app(
        TapMatchRound(
            level: _fourOptions,
            ctx: _ctx(said),
            onRound: (_) {},
            onFinished: () {}),
        interaction: _small,
      ));
      await tester.pump();
      expect(said, hasLength(1));
      await tester.pump(RoundState.repeatEvery);
      expect(said, hasLength(2));
      expect(said.last, said.first);
      await tester.pump(RoundState.repeatEvery * 5);
      expect(said, hasLength(1 + const MiraboTokens(lowStimulation: true).maxPromptRepeats)); // _app è in bassa stimolazione
    });

    testWidgets('il comando Aiuto procede a passi e non completa il round',
        (tester) async {
      final said = <String>[];
      var rounds = 0;
      await tester.pumpWidget(_app(TapMatchRound(
          level: _fourOptions,
          ctx: _ctx(said),
          onRound: (_) => rounds++,
          onFinished: () {})));
      await tester.pump();
      final first = said.first;
      final help = find.byIcon(Icons.lightbulb_outline_rounded);
      await tester.tap(help);
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pump();
      expect(said.last, first);
      await tester.tap(help);
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pump();
      expect(said.last, isNot(first));
      await tester.tap(help);
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pump();
      expect(said, hasLength(4));
      expect(rounds, 0);
    });

    testWidgets(
        'con autonomia = 3 la consegna si dice una volta, poi solo su richiesta',
        (tester) async {
      final said = <String>[];
      await tester.pumpWidget(_app(TapMatchRound(
          level: _fourOptions,
          ctx: _ctx(said),
          onRound: (_) {},
          onFinished: () {})));
      await tester.pump();
      await tester.pump(RoundState.repeatEvery * 3);
      expect(said, hasLength(1));
    });

    testWidgets(
        'con poca autonomia uscire chiede conferma; da soli si esce subito',
        (tester) async {
      Future<void> open(InteractionProfile p) async {
        await tester.pumpWidget(_app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  body: ExitGuard(
                    child: Center(
                        child: RoundIconButton(
                            icon: Icons.close_rounded,
                            tooltip: 'chiudi',
                            onPressed: () => leaveChildPage(context))),
                  ),
                ),
              )),
              child: const Text('apri'),
            ),
          ),
          interaction: p,
        ));
        await tester.tap(find.text('apri'));
        await tester.pump(const Duration(milliseconds: 650));
        await tester.pumpAndSettle();
      }

      await open(_small);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      // Chi non legge vede solo le icone; resto.
      expect(find.text(l10nIt.exitAsk), findsNothing);
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      // Esco.
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      await open(const InteractionProfile());
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });

  group('lettura', () {
    List<Widget> bits() => [
          ScreenText(
              text: 'C\'era una volta un riccio.',
              current: -1,
              readAlong: true,
              onWord: (_) {}),
          PromptBar(text: 'Tocca la mela', onSay: () {}),
        ];
    Widget page() => Column(children: bits());

    testWidgets('con lettura = nessuna il lettore non mostra testo',
        (tester) async {
      await tester.pumpWidget(_app(page(), interaction: _small));
      expect(find.byType(ReadAlongText), findsNothing);
      expect(find.textContaining('riccio', findRichText: true), findsNothing);
      expect(find.text('Tocca la mela'), findsNothing);
      // La consegna resta per lo screen reader.
      expect(find.bySemanticsLabel('Tocca la mela'), findsOneWidget);
    });

    testWidgets(
        'con lettura = lettere resta solo la frase-chiave, non il testo',
        (tester) async {
      await tester.pumpWidget(_app(page(),
          interaction:
              const InteractionProfile(reading: ReadingLevel.letters)));
      expect(find.byType(ReadAlongText), findsNothing);
    });

    testWidgets('chi legge vede il testo e le scritte dei bottoni',
        (tester) async {
      await tester.pumpWidget(_app(
        Column(children: [
          ...bits(),
          ChunkyButton(
              label: 'Avanti',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {}),
        ]),
        interaction: const InteractionProfile(reading: ReadingLevel.words),
      ));
      expect(find.byType(ReadAlongText), findsOneWidget);
      expect(find.textContaining('riccio', findRichText: true), findsOneWidget);
      expect(find.text('Tocca la mela'), findsOneWidget);
      expect(find.text('Avanti'), findsOneWidget);

      await tester.pumpWidget(_app(
        ChunkyButton(
            label: 'Avanti',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {}),
        interaction: _small,
      ));
      await tester.pumpAndSettle(); // il cambio di tema è animato
      expect(find.text('Avanti'), findsNothing);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });
  });
}
