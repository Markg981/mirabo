import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/l10n/app_localizations.dart';
import 'package:mirabo/l10n/app_localizations_it.dart';
import 'package:mirabo/models/activity.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/activity/activity_player.dart';
import 'package:mirabo/ui/activity/types/hunt_round.dart';
import 'package:mirabo/ui/child/gesture_pause_board.dart';

final l10nIt = AppLocalizationsIt();

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
      theme: miraboTheme(dyslexiaFont: false, lowStimulation: true),
      home: Scaffold(body: child),
    );

/// La pausa di gesto ferma la storia; la caccia al tesoro porta il bambino
/// lontano dallo schermo. Nessuna delle due controlla o premia.
void main() {
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;
  dynamic readJson(String path) => jsonDecode(File(path).readAsStringSync());

  test('le pause di gesto in content/: al massimo una per variante, con invito e ritorno, anche tradotte', () {
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
          final screens = v.screens.where((s) => s.kind == ScreenKind.gesture).toList();
          expect(screens.length, lessThanOrEqualTo(1), reason: '${meta.id} $file $lang');
          for (final s in screens) {
            expect(s.gesture, isNotNull);
            expect(s.companionLines, isNotNull, reason: "l'invito del compagno");
            expect(s.gesture!.seconds, inInclusiveRange(5, 60));
            for (final c in CompanionId.values) {
              expect(s.gesture!.back.forCompanion(c), isNotEmpty);
            }
            if (lang == null) pauses++;
          }
          expect(v.screens.where((s) => s.gesture != null && s.kind != ScreenKind.gesture), isEmpty);
        }
      }
    }
    expect(pauses, greaterThanOrEqualTo(4));
  });

  testWidgets('il cerchio della pausa: il "via" c\'è solo prima di cominciare', (tester) async {
    var started = 0;
    Future<void> pump(GesturePhase phase) => tester.pumpWidget(_app(Center(
          child: GesturePauseBoard(emoji: '🌋', seconds: 10, phase: phase, color: Colors.orange, onStart: () => started++),
        )));

    await pump(GesturePhase.ready);
    await tester.tap(find.text(l10nIt.gestureStart));
    expect(started, 1);

    await pump(GesturePhase.running);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text(l10nIt.gestureStart), findsNothing);
    expect(find.text('🌋'), findsOneWidget);

    await pump(GesturePhase.done);
    expect(find.text(l10nIt.gestureStart), findsNothing);
  });

  test('ogni caccia al tesoro ha da 2 a 6 cose per livello, con emoji, nome e consegna', () {
    final hunts = Directory('${root.path}/content/activities')
        .listSync()
        .whereType<Directory>()
        .map((d) => Activity.fromJson(readJson('${d.path}/activity.json') as Map<String, dynamic>))
        .where((a) => a.type == ActivityType.hunt)
        .toList();
    expect(hunts.length, greaterThanOrEqualTo(5));
    for (final a in hunts) {
      expect(a.isHome, isTrue, reason: a.id);
      for (final level in a.levels) {
        final items = (level['items'] as List).cast<Map<String, dynamic>>();
        expect(items.length, inInclusiveRange(2, 6), reason: a.id);
        for (final i in items) {
          expect([i['emoji'], i['label'], i['say']].every((v) => v is String && v.isNotEmpty), isTrue, reason: a.id);
        }
      }
    }
  });

  testWidgets('la caccia: trovato o no, si va avanti e alla fine si chiude', (tester) async {
    final results = <RoundResult>[];
    final said = <String>[];
    var finished = false;
    final ctx = ActivityContext(
      profile: const ChildProfile(id: 1, name: 'Ada', ageBand: AgeBand.b3to5, companion: CompanionId.pilu),
      companionName: 'Pilù',
      say: (t) async => said.add(t),
    );
    await tester.pumpWidget(_app(HuntRound(
      level: const {
        'items': [
          {'emoji': '🔴', 'label': 'Una cosa rossa', 'say': 'Cerca una cosa rossa.'},
          {'emoji': '🔵', 'label': 'Una cosa blu', 'say': 'Adesso una cosa blu.'},
        ],
      },
      ctx: ctx,
      onRound: results.add,
      onFinished: () => finished = true,
    )));

    // Prima la regola per il grande, poi la prima cosa da cercare.
    expect(find.textContaining(l10nIt.huntRules), findsOneWidget);
    await tester.tap(find.text(l10nIt.go));
    await tester.pump();
    expect(find.text('Una cosa rossa'), findsOneWidget);
    expect(said.last, 'Cerca una cosa rossa.');

    // Trovata: il compagno chiede di dirla a voce, poi si passa alla seconda.
    await tester.tap(find.text(l10nIt.huntFound));
    await tester.pump();
    expect(find.text(l10nIt.huntTellMe), findsWidgets);
    await tester.tap(find.text(l10nIt.next));
    await tester.pump();
    expect(find.text('Una cosa blu'), findsOneWidget);
    expect(said.last, 'Adesso una cosa blu.');

    // Non trovata: va bene uguale, e la caccia finisce.
    await tester.tap(find.text(l10nIt.huntNotFound));
    await tester.pump();
    expect(results.map((r) => r.choice), ['hunt=found', 'hunt=skip']);
    expect(results.every((r) => r.firstTry), isTrue);
    expect(finished, isTrue);
  });
}
