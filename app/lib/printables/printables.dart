/// Fogli da stampare per usare Mirabò lontano dallo schermo. Si generano sul
/// tablet, nella lingua del bambino, e non lasciano il dispositivo finché il
/// genitore non sceglie dove stamparli o mandarli.
///
/// Niente emoji (i font da stampa non le hanno): i disegni li fa il bambino.
library;

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_localizations.dart';
import '../models/made_story.dart';
import '../models/nature_day.dart';
import '../models/story.dart';

/// I font dell'app (licenza OFL), presi dagli asset.
class PrintFonts {
  const PrintFonts({required this.text, required this.bold, required this.title});
  final pw.Font text;
  final pw.Font bold;
  final pw.Font title;

  static Future<PrintFonts> load() async {
    Future<pw.Font> font(String path) async => pw.Font.ttf(await rootBundle.load(path));
    return PrintFonts(
      text: await font('fonts/Nunito-400.ttf'),
      bold: await font('fonts/Nunito-800.ttf'),
      title: await font('fonts/Fredoka-600.ttf'),
    );
  }
}

const _ink = PdfColor.fromInt(0xFF0E2A47);
const _soft = PdfColor.fromInt(0xFF8DA0B3);
const _trace = PdfColor.fromInt(0xFFC9D3DD);
const _line = PdfColor.fromInt(0xFFDCE8F2);

pw.Document _doc(PrintFonts f) => pw.Document(
      theme: pw.ThemeData.withFont(base: f.text, bold: f.bold),
      author: 'Mirabò',
      creator: 'Mirabò',
    );

pw.Widget _title(PrintFonts f, String text, {double size = 30}) =>
    pw.Text(text, style: pw.TextStyle(font: f.title, fontSize: size, color: _ink));

/// Riquadro vuoto con l'etichetta in basso: lo spazio per disegnare.
pw.Widget _drawBox(String label, {double? height}) => pw.Container(
      height: height,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _soft, width: 1.5),
        borderRadius: pw.BorderRadius.circular(16),
      ),
      padding: const pw.EdgeInsets.all(10),
      alignment: pw.Alignment.bottomRight,
      child: pw.Text(label, style: const pw.TextStyle(color: _soft, fontSize: 12)),
    );

/// "Ricalco il mio nome": il nome scritto pieno una volta, poi in grigio
/// chiaro da ripassare, su righe come quelle del quaderno.
Future<Uint8List> nameTracingPdf(AppLocalizations l, PrintFonts f, String name) {
  final doc = _doc(f);
  final big = pw.TextStyle(font: f.title, fontSize: name.length > 8 ? 54 : 72);
  pw.Widget row(PdfColor color) => pw.Container(
        height: 104,
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line, width: 2))),
        alignment: pw.Alignment.bottomLeft,
        padding: const pw.EdgeInsets.only(left: 8),
        child: pw.Text(name, style: big.copyWith(color: color)),
      );
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title(f, l.pdfTraceName),
        pw.SizedBox(height: 16),
        row(_ink),
        for (var i = 0; i < 5; i++) row(_trace),
        pw.Container(height: 104, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line, width: 2)))),
      ],
    ),
  ));
  return doc.save();
}

/// La scheda del gesto di una storia: frase-chiave, gesto, quattordici
/// cerchi da colorare (uno per volta, non per giorno: nessuna catena da non
/// rompere) e lo spazio per disegnarlo.
Future<Uint8List> gestureSheetPdf(AppLocalizations l, PrintFonts f, Story story) {
  final doc = _doc(f);
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _title(f, story.title),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFFFF3CC),
            borderRadius: pw.BorderRadius.circular(14),
          ),
          child: pw.Text(story.keyPhrase, style: pw.TextStyle(font: f.bold, fontSize: 18, color: _ink)),
        ),
        pw.SizedBox(height: 18),
        pw.Text(story.gesture ?? '', style: pw.TextStyle(font: f.bold, fontSize: 22, color: _ink)),
        pw.SizedBox(height: 10),
        pw.Text(l.pdfGestureTimes, style: const pw.TextStyle(fontSize: 14, color: _ink)),
        pw.SizedBox(height: 12),
        for (var r = 0; r < 2; r++)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                for (var c = 0; c < 7; c++)
                  pw.Container(
                    width: 52,
                    height: 52,
                    decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: _soft, width: 1.5)),
                  ),
              ],
            ),
          ),
        pw.SizedBox(height: 10),
        pw.Expanded(child: _drawBox(l.pdfDrawHere)),
      ],
    ),
  ));
  return doc.save();
}

/// Il nome del mese nella lingua del bambino. Le date di intl le carica
/// l'app all'avvio (flutter_localizations); senza, numero e anno.
String _monthLabel(String lang, DateTime month) {
  try {
    return DateFormat.yMMMM(lang).format(month);
  } catch (_) {
    return '${month.month}/${month.year}';
  }
}

List<String> _weekdays(String lang) {
  try {
    final f = DateFormat.E(lang);
    // 2024-01-01 era lunedì: la settimana si stampa da lunedì a domenica.
    return [for (var i = 0; i < 7; i++) f.format(DateTime(2024, 1, 1 + i))];
  } catch (_) {
    return List.filled(7, '');
  }
}

/// Il calendario della natura del mese, in orizzontale: le caselle vuote da
/// riempire a mano e, dove il bambino ha già segnato qualcosa, le parole.
Future<Uint8List> natureMonthPdf(AppLocalizations l, PrintFonts f, String lang, DateTime month, List<NatureDay> days) {
  final doc = _doc(f);
  final byDay = {for (final d in days) d.day.day: d};
  final count = daysInMonth(month);
  final lead = DateTime(month.year, month.month, 1).weekday - 1;
  final rows = ((lead + count) / 7).ceil();
  final weekdays = _weekdays(lang);

  pw.Widget cell(int d) {
    if (d < 1 || d > count) return pw.Container();
    final e = byDay[d];
    final words = [
      if (e?.weather != null) l.natureWeather(e!.weather!.name),
      for (final t in e?.seen ?? const <NatureThing>{}) l.natureThing(t.name),
    ];
    return pw.Container(
      margin: const pw.EdgeInsets.all(2),
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: _soft), borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$d', style: pw.TextStyle(font: f.bold, fontSize: 11, color: _ink)),
          for (final w in words) pw.Text(w, style: const pw.TextStyle(fontSize: 8, color: _ink), maxLines: 1),
        ],
      ),
    );
  }

  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4.landscape,
    margin: const pw.EdgeInsets.all(28),
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(children: [
          pw.Expanded(child: _title(f, l.natureTitle, size: 24)),
          pw.Text(_monthLabel(lang, month), style: pw.TextStyle(font: f.title, fontSize: 20, color: _ink)),
        ]),
        pw.SizedBox(height: 4),
        pw.Text(l.natureMonthTip('m${month.month}'), style: const pw.TextStyle(fontSize: 11, color: _ink)),
        pw.SizedBox(height: 8),
        pw.Row(children: [
          for (final w in weekdays)
            pw.Expanded(
              child: pw.Center(child: pw.Text(w, style: pw.TextStyle(font: f.bold, fontSize: 10, color: _soft))),
            ),
        ]),
        pw.Expanded(
          child: pw.Column(children: [
            for (var r = 0; r < rows; r++)
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [for (var c = 0; c < 7; c++) pw.Expanded(child: cell(r * 7 + c - lead + 1))],
                ),
              ),
          ]),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '${l.pdfWeather}: ${Weather.values.map((w) => l.natureWeather(w.name)).join(' · ')}',
          style: const pw.TextStyle(fontSize: 9, color: _soft),
        ),
        pw.Text(
          '${l.pdfSeen}: ${NatureThing.values.map((t) => l.natureThing(t.name)).join(' · ')}',
          style: const pw.TextStyle(fontSize: 9, color: _soft),
        ),
      ],
    ),
  ));
  return doc.save();
}

/// Il libretto di una storia inventata: copertina con titolo e autore, una
/// pagina per scena con il riquadro da disegnare sopra il testo, "Fine".
Future<Uint8List> madeStoryBookletPdf(AppLocalizations l, PrintFonts f, MadeStory story, String childName) {
  final doc = _doc(f);
  const format = PdfPageFormat.a4;
  const margin = pw.EdgeInsets.all(40);
  doc.addPage(pw.Page(
    pageFormat: format,
    margin: margin,
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 30),
        pw.Center(child: _title(f, story.titleIn(l), size: 40)),
        pw.SizedBox(height: 10),
        pw.Center(child: pw.Text(l.factoryBy(childName), style: const pw.TextStyle(fontSize: 18, color: _ink))),
        pw.SizedBox(height: 30),
        pw.Expanded(child: _drawBox(l.pdfDrawHere)),
      ],
    ),
  ));
  for (final page in story.pages(l)) {
    doc.addPage(pw.Page(
      pageFormat: format,
      margin: margin,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(child: _drawBox(l.pdfDrawHere)),
          pw.SizedBox(height: 24),
          pw.Text(page.text, style: const pw.TextStyle(fontSize: 24, color: _ink, lineSpacing: 6)),
          pw.SizedBox(height: 40),
        ],
      ),
    ));
  }
  doc.addPage(pw.Page(
    pageFormat: format,
    margin: margin,
    build: (_) => pw.Center(child: _title(f, l.factoryEnd, size: 56)),
  ));
  return doc.save();
}
