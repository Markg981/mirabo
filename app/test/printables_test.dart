import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/made_story.dart';
import 'package:mirabo/models/nature_day.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/printables/printables.dart';
import 'package:pdf/widgets.dart' as pw;

/// I font letti dal disco: nei test gli asset del bundle non servono.
PrintFonts _fonts() {
  pw.Font font(String name) => pw.Font.ttf(ByteData.sublistView(File('fonts/$name').readAsBytesSync()));
  return PrintFonts(text: font('Nunito-400.ttf'), bold: font('Nunito-800.ttf'), title: font('Fredoka-600.ttf'));
}

void _isPdf(Uint8List bytes, {required int pages}) {
  expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  expect(RegExp(r'/Type\s*/Page\b').allMatches(String.fromCharCodes(bytes)).length, pages);
}

void main() {
  final fonts = _fonts();
  const story = Story(
    id: 'albero-silenzioso',
    version: 1,
    title: "L'albero che non parlava più",
    world: World.ambiente,
    topic: 'alberi',
    variantFiles: {},
    formats: [],
    togetherOnly: false,
    keyPhrase: 'Anche chi non parla ha bisogno di cura.',
    gesture: 'Annaffia una pianta di casa.',
    parentCardFile: 'parent.md',
    sources: [],
  );
  final made = MadeStory(
    profileId: 1,
    parts: {for (final s in FactoryStep.values) s: StoryParts.of(s).last.id},
    when: DateTime(2026, 10, 13),
  );

  for (final lang in AppLanguage.values) {
    final l = lookupAppLocalizations(lang.locale);

    test('[$lang] ricalco del nome', () async {
      _isPdf(await nameTracingPdf(l, fonts, 'Émilie-Sößa'), pages: 1);
    });

    test('[$lang] scheda del gesto', () async {
      _isPdf(await gestureSheetPdf(l, fonts, story), pages: 1);
    });

    test('[$lang] calendario della natura del mese', () async {
      final days = [
        NatureDay(profileId: 1, day: DateTime(2026, 10, 1), weather: Weather.sun, seen: const {NatureThing.leaf}),
        NatureDay(profileId: 1, day: DateTime(2026, 10, 31), weather: Weather.fog),
      ];
      _isPdf(await natureMonthPdf(l, fonts, lang.code, DateTime(2026, 10), days), pages: 1);
    });

    test('[$lang] libretto della storia inventata: copertina, cinque pagine, fine', () async {
      _isPdf(await madeStoryBookletPdf(l, fonts, made, 'Emma'), pages: 7);
    });
  }

  test('i fogli usano la lingua passata, non quella del tablet', () async {
    final de = lookupAppLocalizations(const Locale('de'));
    expect(made.pages(de).first.text, startsWith('Es war einmal'));
  });
}
