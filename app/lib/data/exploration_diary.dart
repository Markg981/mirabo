/// Diario descrittivo dell'esplorazione (area genitore): che cosa il bambino
/// ha scelto e ripreso, per temi. Tocchi, tentativi, velocità e completamenti
/// non diventano indicatori di competenza o di sviluppo; nessun confronto
/// con un mese prima né con altri bambini.
library;

import 'dart:convert';

import '../models/activity.dart';
import 'local_db.dart';

/// Un tema esplorato negli ultimi giorni: quante volte è stato scelto,
/// in quanti giorni diversi, e se è stato ripreso.
class ThemeExploration {
  const ThemeExploration({required this.skill, required this.area, required this.rounds, required this.days});
  final String skill;
  final ActivityArea area;

  /// Quante volte è stato scelto (conta le presenze, non l'esito).
  final int rounds;

  /// In quanti giorni diversi.
  final int days;

  /// Ripreso: tornato sul tema in giorni diversi.
  bool get resumed => days >= 2;
}

/// Un'osservazione libera del genitore sul bambino.
class ParentNote {
  const ParentNote({required this.when, required this.text});
  final DateTime when;
  final String text;

  Map<String, Object?> toJson() => {'at': when.toIso8601String(), 'text': text};
  static ParentNote fromJson(Map<String, dynamic> j) =>
      ParentNote(when: DateTime.parse(j['at'] as String), text: j['text'] as String);
}

class ExplorationDiary {
  ExplorationDiary(this.db);
  final LocalDb db;

  /// Giorni raccontati dal diario.
  static const window = 30;

  /// Temi esplorati, dal più ripreso; a parità, in ordine alfabetico.
  /// Una riga di `rounds` conta come una presenza, qualunque ne sia l'esito.
  static List<ThemeExploration> themes(List<Map<String, Object?>> rounds, Map<String, ActivityArea> areaBySkill) {
    final count = <String, int>{};
    final days = <String, Set<String>>{};
    for (final r in rounds) {
      final skill = r['skill'] as String;
      if (!areaBySkill.containsKey(skill)) continue;
      count[skill] = (count[skill] ?? 0) + 1;
      (days[skill] ??= {}).add((r['at'] as String).substring(0, 10));
    }
    return [
      for (final e in count.entries)
        ThemeExploration(skill: e.key, area: areaBySkill[e.key]!, rounds: e.value, days: days[e.key]!.length),
    ]..sort((a, b) {
        final c = b.days.compareTo(a.days);
        return c != 0 ? c : a.skill.compareTo(b.skill);
      });
  }

  Future<List<ThemeExploration>> forProfile(int profileId, List<Activity> activities, {DateTime? now}) async {
    final to = now ?? DateTime.now();
    final recent = await db.rounds(profileId, from: to.subtract(const Duration(days: window)), to: to.add(const Duration(seconds: 1)));
    return themes(recent, {for (final a in activities) a.skill: a.area});
  }

  // Le osservazioni stanno in `settings` (una chiave per bambino, JSON):
  // nessuno schema nuovo, e finiscono nel backup e nella cancellazione dati.
  static String _key(int profileId) => 'parent_notes_$profileId';

  Future<List<ParentNote>> notes(int profileId) async {
    final raw = await db.setting(_key(profileId));
    if (raw == null) return const [];
    try {
      return [for (final j in jsonDecode(raw) as List) ParentNote.fromJson(j as Map<String, dynamic>)]
        ..sort((a, b) => b.when.compareTo(a.when));
    } catch (_) {
      return const [];
    }
  }

  Future<void> _save(int profileId, List<ParentNote> all) =>
      db.setSetting(_key(profileId), jsonEncode([for (final n in all) n.toJson()]));

  Future<void> addNote(int profileId, String text, {DateTime? now}) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await _save(profileId, [...await notes(profileId), ParentNote(when: now ?? DateTime.now(), text: t)]);
  }

  Future<void> removeNote(int profileId, ParentNote note) async {
    final all = await notes(profileId);
    await _save(profileId, [for (final n in all) if (n.when != note.when || n.text != note.text) n]);
  }
}
