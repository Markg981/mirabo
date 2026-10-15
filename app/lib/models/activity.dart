/// Modello delle attività "Verso la scuola". Rispecchia content/schema/activity.schema.json
/// e docs/activity-format.md. I livelli restano JSON grezzo: ogni tipo li interpreta.
library;

import 'story.dart' show AgeBand, CompanionLines;

enum ActivityModule {
  scuola('Verso la scuola'),
  montessori('Montessori');

  const ActivityModule(this.label);
  final String label;
}

enum ActivityArea {
  // Modulo "Verso la scuola"
  cognitivo('Prerequisiti', 'Lettere, numeri, forme, logica', ActivityModule.scuola),
  autonomia('Autonomia', 'Routine, vestirsi, zaino, mensa', ActivityModule.scuola),
  sociale('In classe', 'Turni, aiuto, amici, saluto', ActivityModule.scuola),
  paure('Primo giorno', 'Conoscere la scuola, il conto alla rovescia', ActivityModule.scuola),
  // Modulo Montessori
  vitaPratica('Vita pratica', 'Travasi, versare, abbottonare, apparecchiare, piegare, curare', ActivityModule.montessori),
  sensoriale('Sensoriale', 'Torre rosa, scala marrone, colori, forme, tatto, suoni', ActivityModule.montessori),
  linguaggio('Linguaggio e scrittura', 'Pregrafismo, incastri, lettere smerigliate, alfabeto mobile', ActivityModule.montessori),
  matematica('Matematica', 'Aste numeriche, fuselli, perle delle decine', ActivityModule.montessori),
  cultura('Cultura', 'Continenti, botanica, il fagiolo nel cotone', ActivityModule.montessori);

  const ActivityArea(this.label, this.description, this.module);
  final String label;
  final String description;
  final ActivityModule module;

  /// I file usano slug con il trattino ("vita-pratica").
  static ActivityArea fromKey(String key) => switch (key) {
        'vita-pratica' => ActivityArea.vitaPratica,
        _ => ActivityArea.values.byName(key),
      };
}

enum ActivityType { tapMatch, count, sequence, pattern, trace, checklist, sceneChoice, explore, countdown, presentation, pairs, spell, hunt, project }

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

  ActivityModule get module => area.module;

  /// Attività da fare con le mani, fuori dallo schermo: le presentazioni e le
  /// cacce al tesoro in casa.
  bool get isHome => type == ActivityType.presentation || type == ActivityType.hunt;

  /// Le prime emoji diverse che compaiono nei livelli (al massimo tre): fanno
  /// da copertina alla carta finché le attività non hanno un'illustrazione propria.
  List<String> get coverEmojis {
    final out = <String>[];
    _collectEmojis(levels, out);
    return out;
  }

  String? get coverEmoji => coverEmojis.firstOrNull;

  static void _collectEmojis(Object? node, List<String> out) {
    if (out.length >= 3) return;
    if (node is Map) {
      final e = node['emoji'];
      if (e is String && e.isNotEmpty && !out.contains(e)) out.add(e);
      for (final v in node.values) {
        _collectEmojis(v, out);
      }
    } else if (node is List) {
      for (final v in node) {
        _collectEmojis(v, out);
      }
    }
  }

  /// Livello 1..levels.length, mai fuori range.
  Map<String, dynamic> level(int n) => levels[(n - 1).clamp(0, levels.length - 1)];

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        id: j['id'] as String,
        version: j['version'] as int,
        title: j['title'] as String,
        area: ActivityArea.fromKey(j['area'] as String),
        skill: j['skill'] as String,
        type: ActivityType.values.byName(j['type'] as String),
        ageBands: (j['ageBands'] as List).map((b) => AgeBand.fromContentKey(b as String)).toSet(),
        togetherSuggested: (j['togetherSuggested'] as bool?) ?? false,
        intro: CompanionLines.fromJson(j['intro'] as Map<String, dynamic>),
        outro: CompanionLines.fromJson(j['outro'] as Map<String, dynamic>),
        offscreen: j['offscreen'] as String,
        levels: (j['levels'] as List).cast<Map<String, dynamic>>(),
      );
}

/// Stato di un profilo su un'attività, quello che serve a riprenderla: il
/// livello scelto dal bambino, quante volte l'ha aperta e quando. Nessun
/// punteggio e nessuna serie di risposte giuste (docs/privacy/mvp-data.md).
class ActivityProgress {
  const ActivityProgress({
    required this.profileId,
    required this.activityId,
    this.level = 1,
    this.sessions = 0,
    this.lastPlayed,
  });

  final int profileId;
  final String activityId;
  final int level;
  final int sessions;
  final DateTime? lastPlayed;

  ActivityProgress copyWith({int? level, int? sessions, DateTime? lastPlayed}) => ActivityProgress(
        profileId: profileId,
        activityId: activityId,
        level: level ?? this.level,
        sessions: sessions ?? this.sessions,
        lastPlayed: lastPlayed ?? this.lastPlayed,
      );
}

/// Un round finito, come si conserva. Tentativi, aiuti, tempi ed errori restano
/// nel round mentre si gioca (servono all'aiuto a passi) e non si salvano: non
/// sono indicatori di niente (analisi 7C, docs/privacy/mvp-data.md).
class RoundResult {
  const RoundResult({this.choice});

  /// Solo le scelte che l'app usa: la nota di un passo dei piccoli progetti
  /// (diario dell'adulto) e la scelta a fine presentazione ("lo rifaccio",
  /// "da solo"), da cui nascono le idee per l'adulto. Nessuna risposta sbagliata.
  final String? choice;
}
