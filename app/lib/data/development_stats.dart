import '../models/activity.dart';
import 'local_db.dart';

/// Tappe descrittive, mai numeri sul bambino (spec: "Sviluppo del bambino").
enum Stage {
  starting('sta iniziando'),
  working('ci sta lavorando'),
  canDo('ce la fa'),
  alone('lo fa da solo');

  const Stage(this.label);
  final String label;
}

class SkillStat {
  const SkillStat({required this.skill, required this.area, required this.now, required this.monthAgo, required this.rounds});
  final String skill;
  final ActivityArea area;
  final Stage? now;
  final Stage? monthAgo;
  final int rounds;

  bool get improved => monthAgo != null && now != null && now!.index > monthAgo!.index;
}

/// Traduce i round in tappe per abilità. Regola:
/// - nessun round → nessuna tappa (non "sta iniziando": non lo sappiamo)
/// - livello massimo raggiunto e ≥70% di round al primo tentativo → "lo fa da solo"
/// - ≥70% al primo tentativo → "ce la fa"
/// - ≥40% → "ci sta lavorando"
/// - altrimenti "sta iniziando"
/// Per i tipi senza giusto/sbagliato (scene, checklist, esplora) la tappa è data
/// dal fatto di averlo fatto e, per la checklist, da quante voci "da solo".
class DevelopmentStats {
  DevelopmentStats(this.db);
  final LocalDb db;

  /// Il processo dei piccoli progetti (idea, previsione, prova, revisione) con
  /// le note del bambino, dal più recente: il genitore lo rilegge, non lo valuta.
  Future<List<ProjectStep>> projectLog(int profileId, {int days = 90}) async {
    final rows = await db.rounds(profileId, from: DateTime.now().subtract(Duration(days: days)));
    return [
      for (final r in rows)
        if (ProjectStep.parse(r['activity_id'] as String, r['at'] as String, r['choice'] as String?) case final s?) s,
    ].reversed.toList();
  }

  static final _skillLabels = {
    'suoni-iniziali': 'Suoni e lettere',
    'pregrafismo': 'Tracciare lettere',
    'numeri': 'Numeri e quantità',
    'logica': 'Logica e sequenze',
    'routine-sera': 'Preparare le cose per domani',
    'routine-mattino': 'La routine del mattino',
    'vestirsi': 'Vestirsi da solo',
    'mensa': 'A mensa',
    'turno-e-condivisione': 'Aspettare il turno e condividere',
    'chiedere-aiuto': 'Chiedere aiuto',
    'distacco': 'Il saluto del mattino',
    'conoscere-la-scuola': 'Conoscere la scuola',
    'primo-giorno': 'Il primo giorno',
    'travasi': 'Travasi e versare',
    'motricita-fine': 'Motricità fine',
    'cura-ambiente': 'Cura dell\'ambiente',
    'dimensioni': 'Grandezze e seriazione',
    'colori': 'Colori',
    'forme': 'Forme',
    'tatto': 'Tatto',
    'udito': 'Udito',
    'scrittura': 'Scrittura',
    'vocabolario': 'Vocabolario',
    'decine': 'Decine e unità',
    'geografia': 'Geografia',
    'botanica': 'Botanica',
    'progetti-aperti': 'Piccoli progetti',
  };

  static String label(String skill) => _skillLabels[skill] ?? skill;

  Future<List<SkillStat>> forProfile(int profileId, List<Activity> activities) async {
    final now = DateTime.now();
    final recent = await db.rounds(profileId, from: now.subtract(const Duration(days: 30)));
    final older = await db.rounds(profileId, from: now.subtract(const Duration(days: 60)), to: now.subtract(const Duration(days: 30)));
    final maxLevelBySkill = <String, int>{};
    final areaBySkill = <String, ActivityArea>{};
    for (final a in activities) {
      maxLevelBySkill[a.skill] = (maxLevelBySkill[a.skill] ?? 1) > a.levels.length ? maxLevelBySkill[a.skill]! : a.levels.length;
      areaBySkill[a.skill] = a.area;
    }
    final skills = {...recent.map((r) => r['skill'] as String), ...older.map((r) => r['skill'] as String)};
    final out = <SkillStat>[];
    for (final skill in skills) {
      final rr = recent.where((r) => r['skill'] == skill).toList();
      final ro = older.where((r) => r['skill'] == skill).toList();
      out.add(SkillStat(
        skill: skill,
        area: areaBySkill[skill] ?? ActivityArea.cognitivo,
        now: _stage(rr, maxLevelBySkill[skill] ?? 1),
        monthAgo: _stage(ro, maxLevelBySkill[skill] ?? 1),
        rounds: rr.length,
      ));
    }
    out.sort((a, b) => a.area.index != b.area.index ? a.area.index.compareTo(b.area.index) : a.skill.compareTo(b.skill));
    return out;
  }

  Stage? _stage(List<Map<String, Object?>> rounds, int maxLevel) {
    if (rounds.isEmpty) return null;
    final choices = rounds.where((r) => r['choice'] != null).toList();
    // Checklist: "da solo" conta.
    final checklist = choices.where((r) => (r['choice'] as String).startsWith('done=')).toList();
    if (checklist.isNotEmpty && checklist.length == rounds.length) {
      var alone = 0, of = 0;
      for (final r in checklist) {
        final parts = {for (final kv in (r['choice'] as String).split(';')) kv.split('=')[0]: int.parse(kv.split('=')[1])};
        alone += parts['alone'] ?? 0;
        of += parts['of'] ?? 0;
      }
      final ratio = of == 0 ? 0.0 : alone / of;
      return ratio >= 0.8 ? Stage.alone : (ratio >= 0.5 ? Stage.canDo : (ratio > 0 ? Stage.working : Stage.starting));
    }
    // Presentazioni a casa: conta cosa ha segnato il genitore.
    final presentations = choices.where((r) => (r['choice'] as String).startsWith('presentation=')).toList();
    if (presentations.isNotEmpty && presentations.length == rounds.length) {
      final codes = presentations.map((r) => (r['choice'] as String).split('=')[1]).toList();
      if (codes.contains('alone') || codes.contains('repeat')) return Stage.alone;
      if (codes.contains('done')) return Stage.canDo;
      return Stage.working;
    }
    // Cacce al tesoro: conta quante cose ha trovato, non quanto in fretta.
    final hunts = choices.where((r) => (r['choice'] as String).startsWith('hunt=')).toList();
    if (hunts.isNotEmpty && hunts.length == rounds.length) {
      final found = hunts.where((r) => r['choice'] == 'hunt=found').length / hunts.length;
      return found >= 0.8 ? Stage.canDo : (found >= 0.4 ? Stage.working : Stage.starting);
    }
    // Tipi senza giusto/sbagliato: l'ha fatto.
    if (choices.length == rounds.length) return rounds.length >= 3 ? Stage.canDo : Stage.working;
    final scored = rounds.where((r) => r['choice'] == null).toList();
    final firstTry = scored.where((r) => (r['attempts'] as int) == 1 && (r['hints'] as int) == 0).length / scored.length;
    final topLevel = scored.map((r) => r['level'] as int).reduce((a, b) => a > b ? a : b);
    if (firstTry >= 0.7 && topLevel >= maxLevel) return Stage.alone;
    if (firstTry >= 0.7) return Stage.canDo;
    if (firstTry >= 0.4) return Stage.working;
    return Stage.starting;
  }
}

/// Un passaggio di un piccolo progetto, letto dal `choice` di un round
/// (`project=idea;note=...`, `project=test;result=held|notyet`).
class ProjectStep {
  const ProjectStep({required this.activityId, required this.at, required this.phase, this.note, this.result});
  final String activityId;
  final String at;
  final String phase;
  final String? note;
  final String? result;

  static ProjectStep? parse(String activityId, String at, String? choice) {
    if (choice == null || !choice.startsWith('project=')) return null;
    final noteAt = choice.indexOf(';note=');
    final head = noteAt < 0 ? choice : choice.substring(0, noteAt);
    final note = noteAt < 0 ? null : choice.substring(noteAt + 6);
    final parts = {for (final kv in head.split(';')) kv.split('=')[0]: kv.contains('=') ? kv.substring(kv.indexOf('=') + 1) : ''};
    return ProjectStep(activityId: activityId, at: at, phase: parts['project']!, note: note, result: parts['result']);
  }
}
