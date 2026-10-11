/// Modello delle attività "Verso la scuola". Rispecchia content/schema/activity.schema.json
/// e docs/activity-format.md. I livelli restano JSON grezzo: ogni tipo li interpreta.
library;

import 'story.dart' show AgeBand, CompanionLines;

enum ActivityArea {
  cognitivo('Prerequisiti', 'Lettere, numeri, forme, logica'),
  autonomia('Autonomia', 'Routine, vestirsi, zaino, mensa'),
  sociale('In classe', 'Turni, aiuto, amici, saluto'),
  paure('Primo giorno', 'Conoscere la scuola, il conto alla rovescia');

  const ActivityArea(this.label, this.description);
  final String label;
  final String description;
}

enum ActivityType { tapMatch, count, sequence, pattern, trace, checklist, sceneChoice, explore, countdown }

class Activity {
  const Activity({
    required this.id,
    required this.version,
    required this.title,
    required this.area,
    required this.skill,
    required this.type,
    required this.ageBands,
    required this.togetherSuggested,
    required this.intro,
    required this.outro,
    required this.offscreen,
    required this.levels,
  });

  final String id;
  final int version;
  final String title;
  final ActivityArea area;
  final String skill;
  final ActivityType type;
  final Set<AgeBand> ageBands;
  final bool togetherSuggested;
  final CompanionLines intro;
  final CompanionLines outro;
  final String offscreen;
  final List<Map<String, dynamic>> levels;

  bool supports(AgeBand band) => ageBands.contains(band);

  /// Livello 1..levels.length, mai fuori range.
  Map<String, dynamic> level(int n) => levels[(n - 1).clamp(0, levels.length - 1)];

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        id: j['id'] as String,
        version: j['version'] as int,
        title: j['title'] as String,
        area: ActivityArea.values.byName(j['area'] as String),
        skill: j['skill'] as String,
        type: ActivityType.values.byName(j['type'] as String),
        ageBands: (j['ageBands'] as List).map((b) => AgeBand.fromKey(b as String)).toSet(),
        togetherSuggested: (j['togetherSuggested'] as bool?) ?? false,
        intro: CompanionLines.fromJson(j['intro'] as Map<String, dynamic>),
        outro: CompanionLines.fromJson(j['outro'] as Map<String, dynamic>),
        offscreen: j['offscreen'] as String,
        levels: (j['levels'] as List).cast<Map<String, dynamic>>(),
      );
}

/// Progresso di un profilo su un'attività. Nessun punteggio visibile al bambino:
/// serve all'adattività e alle statistiche del genitore.
class ActivityProgress {
  const ActivityProgress({
    required this.profileId,
    required this.activityId,
    this.level = 1,
    this.streak = 0,
    this.sessions = 0,
    this.lastPlayed,
  });

  final int profileId;
  final String activityId;
  final int level;

  /// Round consecutivi riusciti al primo tentativo (per salire di livello).
  final int streak;
  final int sessions;
  final DateTime? lastPlayed;

  ActivityProgress copyWith({int? level, int? streak, int? sessions, DateTime? lastPlayed}) => ActivityProgress(
        profileId: profileId,
        activityId: activityId,
        level: level ?? this.level,
        streak: streak ?? this.streak,
        sessions: sessions ?? this.sessions,
        lastPlayed: lastPlayed ?? this.lastPlayed,
      );
}

/// Esito di un round: quanti tentativi ci sono voluti e quanti aiuti.
class RoundResult {
  const RoundResult({required this.attempts, required this.hints, this.choice});
  final int attempts;
  final int hints;

  /// Per sceneChoice/checklist: cosa è stato scelto (nessuna risposta sbagliata).
  final String? choice;

  bool get firstTry => attempts == 1 && hints == 0;
}

/// Regola adattiva (docs/activity-format.md): 3 successi al primo tentativo → +1,
/// due round con 2+ errori → −1. Calcolata a fine sessione.
ActivityProgress applyAdaptive(ActivityProgress p, List<RoundResult> results, int maxLevel) {
  var level = p.level;
  var streak = p.streak;
  var hardRounds = 0;
  for (final r in results) {
    if (r.firstTry) {
      streak++;
      if (streak >= 3 && level < maxLevel) {
        level++;
        streak = 0;
      }
    } else {
      streak = 0;
      if (r.attempts >= 3) hardRounds++;
    }
  }
  if (hardRounds >= 2 && level > 1) level--;
  return p.copyWith(level: level, streak: streak, sessions: p.sessions + 1, lastPlayed: DateTime.now());
}
