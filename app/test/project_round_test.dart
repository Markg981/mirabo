import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/exploration_diary.dart';
import 'package:mirabo/l10n/app_localizations.dart';
import 'package:mirabo/models/activity.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart' show AgeBand, CompanionId;
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/activity/activity_player.dart';
import 'package:mirabo/ui/activity/types/project_round.dart';

/// I piccoli progetti: idea, previsione, prova, revisione. Il tablet non
/// verifica niente e non giudica; le note del bambino restano nel `choice`.
void main() {
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;

  test('il progetto in content/ è per la fascia 8–10 e ha i quattro passaggi in ordine', () {
    final a = Activity.fromJson(jsonDecode(File('${root.path}/content/activities/ponte-di-carta/activity.json').readAsStringSync()));
    expect(a.type, ActivityType.project);
    expect(a.supports(AgeBand.b8to10), isTrue);
    expect(a.supports(AgeBand.b3to5), isFalse);
    for (final level in a.levels) {
      expect([for (final p in level['phases'] as List) p['phase']], ['idea', 'prediction', 'test', 'revision']);
      expect((level['criterion'] as String).endsWith('?'), isTrue);
    }
  });

  test('il choice codifica la nota e il risultato della prova, e si rilegge', () {
    expect(encodeProjectChoice('idea', note: '  due   fogli\npiegati '), 'project=idea;note=due fogli piegati');
    expect(encodeProjectChoice('prediction'), 'project=prediction');
    expect(encodeProjectChoice('test', note: 'ignorata', result: 'held'), 'project=test;result=held');
    final s = ProjectStep.parse('ponte-di-carta', '2026-10-14T10:00:00', 'project=revision;note=a=b; poi c');
    expect(s!.phase, 'revision');
    expect(s.note, 'a=b; poi c');
    expect(ProjectStep.parse('x', 't', 'project=test;result=notyet')!.result, 'notyet');
    expect(ProjectStep.parse('x', 't', 'hunt=found'), isNull);
    expect(ProjectStep.parse('x', 't', null), isNull);
  });

  testWidgets('quattro passaggi: note facoltative, la prova si racconta, nessun giudizio', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final raw = jsonDecode(File('${root.path}/content/activities/ponte-di-carta/activity.json').readAsStringSync()) as Map<String, dynamic>;
    final level = (raw['levels'] as List).first as Map<String, dynamic>;
    final results = <RoundResult>[];
    var finished = false;
    const profile = ChildProfile(id: 1, name: 'Ada', ageBand: AgeBand.b8to10, companion: CompanionId.bo);
    final ctx = ActivityContext(profile: profile, companionName: 'Bo', say: (_) async {});
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
      theme: miraboTheme(dyslexiaFont: false, lowStimulation: true),
      home: Scaffold(body: ProjectRound(level: level, ctx: ctx, onRound: results.add, onFinished: () => finished = true)),
    ));
    await tester.enterText(find.byType(TextField), 'due fogli a fisarmonica');
    await tester.tap(find.text('Avanti'));
    await tester.pump();
    await tester.tap(find.text('Avanti')); // previsione senza nota
    await tester.pump();
    expect(find.byType(TextField), findsNothing); // la prova non ha note
    await tester.tap(find.text('Non ancora'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'più piegature');
    await tester.tap(find.text('Ho finito'));
    await tester.pump();
    expect(finished, isTrue);
    expect([for (final r in results) r.choice], [
      'project=idea;note=due fogli a fisarmonica',
      'project=prediction',
      'project=test;result=notyet',
      'project=revision;note=più piegature',
    ]);
  });
}
