import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/l10n/app_localizations.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/ui/parent/parent_area.dart';

/// L'attività che nasce dalla storia: struttura per fascia, traduzioni e visualizzazione.
void main() {
  final root = Directory.current.path.endsWith('app') ? Directory.current.parent : Directory.current;
  final folder = '${root.path}/content/stories/sassolino-magico';
  dynamic readJson(String path) => jsonDecode(File(path).readAsStringSync());

  test('una storia senza attività resta valida (retrocompatibilità)', () {
    final meta = Story.fromJson(readJson('${root.path}/content/stories/lia-rabbia/story.json') as Map<String, dynamic>);
    expect(meta.homeActivityFile, isNull);
    expect(meta.homeActivity, isNull);
  });

  test('l\'attività del sassolino ha le tre fasce con tutti i campi strutturati', () {
    final meta = Story.fromJson(readJson('$folder/story.json') as Map<String, dynamic>);
    expect(meta.homeActivityFile, 'home-activity.json');
    final a = HomeActivity.fromJson(readJson('$folder/${meta.homeActivityFile}') as Map<String, dynamic>);
    expect(a.bands.keys, AgeBand.values);
    for (final b in a.bands.values) {
      expect(b.materials, isNotEmpty);
      expect(b.preparation, isNotEmpty);
      expect(b.alternatives, isNotEmpty);
      expect(b.supervisionNote, isNotEmpty);
    }
    expect(a.bands[AgeBand.b3to5]!.supervision, Supervision.together);
    expect(a.bands[AgeBand.b8to10]!.supervision, Supervision.free);
  });

  test('le traduzioni conservano la supervisione e le liste', () {
    final base = readJson('$folder/home-activity.json') as Map<String, dynamic>;
    final it = HomeActivity.fromJson(base);
    for (final lang in ['en', 'es', 'fr', 'de']) {
      final t = HomeActivity.fromJson(mergeTranslation(base, readJson('$folder/i18n/$lang/home-activity.json')) as Map<String, dynamic>);
      expect(t.title, isNot(it.title), reason: lang);
      for (final band in AgeBand.values) {
        final a = it.bands[band]!, b = t.bands[band]!;
        expect(b.supervision, a.supervision, reason: lang);
        expect(b.materials.length, a.materials.length, reason: lang);
        expect(b.steps.length, a.steps.length, reason: lang);
        expect(b.supervisionNote, isNot(a.supervisionNote), reason: lang);
      }
    }
  });

  testWidgets('il genitore vede materiali, preparazione, supervisione e alternative per fascia', (tester) async {
    final a = HomeActivity.fromJson(readJson('$folder/home-activity.json') as Map<String, dynamic>);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
      home: Scaffold(body: SingleChildScrollView(child: HomeActivityView(activity: a))),
    ));
    expect(find.text(a.title), findsOneWidget);
    expect(find.text('Cosa serve'), findsNWidgets(3));
    expect(find.text('Preparazione'), findsNWidgets(3));
    expect(find.text('Supervisione'), findsNWidgets(3));
    expect(find.text('Se manca qualcosa'), findsNWidgets(3));
    expect(find.text('3–5 anni'), findsOneWidget);
    expect(find.textContaining('Con il bambino, dall\'inizio alla fine'), findsOneWidget);
  });
}
