import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// Potatura all'apertura del database (docs/compliance/retention.md): i dati
/// che perdono utilità non restano per sempre.
///
/// - Tempi d'uso giornalieri (`settings.usage.<profilo>.<data>`): oltre 90 giorni.
/// - Round delle attività (`activity_rounds`): oltre 12 mesi. I progressi
///   (livello, sessioni, ultima volta) restano.
///
/// Non blocca mai l'avvio: un errore si registra e non si solleva.
Future<void> pruneExpired(Database db, {DateTime? now}) async {
  try {
    final t = now ?? DateTime.now();
    final usageCutoff = _day(t.subtract(const Duration(days: 90)));
    final roundsCutoff = t.subtract(const Duration(days: 365)).toIso8601String();
    // La chiave finisce con la data AAAA-MM-GG: il confronto fra testi segue l'ordine dei giorni.
    await db.delete('settings', where: "key LIKE 'usage.%' AND substr(key, -10) < ?", whereArgs: [usageCutoff]);
    await db.delete('activity_rounds', where: 'at < ?', whereArgs: [roundsCutoff]);
  } catch (e) {
    debugPrint('Potatura dei dati scaduti non riuscita: $e');
  }
}

String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
