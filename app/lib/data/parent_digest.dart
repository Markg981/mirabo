/// Racconto della settimana e idea per oggi (3.4.1, 3.4.3) per l'area genitore.
/// Usa solo dati già sul dispositivo: diario, gesti e round delle attività.
/// Nessun punteggio e nessun confronto con altri bambini.
library;

import '../models/activity.dart';
import '../models/profile.dart';
import '../models/shelf.dart';
import '../models/story.dart';

/// Gli ultimi sette giorni di un bambino, pronti da raccontare.
class WeekDigest {
  const WeekDigest({
    required this.stories,
    required this.sessions,
    required this.together,
    required this.gestures,
    required this.home,
  });

  /// Storie finite, senza doppioni, dalla più recente.
  final List<Story> stories;

  /// Storie finite, contando anche le riletture.
  final int sessions;

  /// Quante di quelle sessioni erano "insieme".
  final int together;

  /// Gesti segnati nella vita vera, uno per storia.
  final List<Story> gestures;

  /// Presentazioni fatte a casa (non solo guardate).
  final List<Activity> home;

  bool get isEmpty => stories.isEmpty && gestures.isEmpty && home.isEmpty;

  static WeekDigest build({
    required DateTime now,
    required List<DiaryEntry> diary,
    required List<GestureEntry> gestureEntries,
    required List<Map<String, Object?>> rounds,
    required Story? Function(String id) story,
    required Activity? Function(String id) activity,
  }) {
    final from = now.subtract(const Duration(days: 7));
    final done = [for (final e in diary) if (e.completed && e.when.isAfter(from)) e]..sort((a, b) => b.when.compareTo(a.when));
    final stories = <Story>[];
    for (final e in done) {
      final s = story(e.storyId);
      if (s == null || stories.any((x) => x.id == s.id)) continue;
      stories.add(s);
    }
    final gestures = <Story>[];
    for (final g in gestureEntries) {
      if (!g.when.isAfter(from)) continue;
      final s = story(g.storyId);
      if (s != null && s.gesture != null && !gestures.any((x) => x.id == s.id)) gestures.add(s);
    }
    final home = <Activity>[];
    for (final r in rounds) {
      final choice = r['choice'] as String?;
      if (choice == null || !choice.startsWith('presentation=') || choice == 'presentation=watched') continue;
      final a = activity(r['activity_id'] as String);
      if (a != null && !home.any((x) => x.id == a.id)) home.add(a);
    }
    return WeekDigest(
      stories: stories,
      sessions: done.where((e) => story(e.storyId) != null).length,
      together: done.where((e) => story(e.storyId) != null && e.mode == SessionMode.together).length,
      gestures: gestures,
      home: home,
    );
  }
}

/// Perché quell'idea oggi, dal segnale più forte al più debole (3.4.3).
/// Il testo mostrato al genitore è tradotto nell'interfaccia.
enum IdeaReason {
  /// Presentazione segnata "vuole rifarla" negli ultimi 7 giorni.
  repeat,

  /// Storia finita negli ultimi 3 giorni.
  recentStory,

  /// Presentazione fatta con l'adulto ma mai da solo.
  tryAlone,

  /// Presentazione nuova nella capacità che il bambino sceglie più spesso.
  capacity,

  /// Una presentazione della fascia, senza un motivo particolare.
  none,
}

/// Preparazione stimata di un'idea: serve a capire se c'è tempo adesso.
enum IdeaPrep { none, quick, short }

/// Un'idea concreta da fare oggi, fuori dallo schermo.
sealed class DailyIdea {
  const DailyIdea(this.reason);
  final IdeaReason reason;

  /// Quanto ci vuole a preparare il necessario.
  IdeaPrep get prep;

  /// Una variante già scritta nel contenuto; null se serve quella generica.
  String? get variant;

  /// La chiave salvata nello storico delle idee ("story:…", "activity:…").
  String get key;
}

/// Dalla sezione "Nella vita vera" della scheda genitore di una storia finita.
class StoryIdea extends DailyIdea {
  const StoryIdea(this.story, this.text, {IdeaReason reason = IdeaReason.recentStory}) : super(reason);
  final Story story;
  final String text;

  @override
  String get key => 'story:${story.id}';

  /// Un gesto o una parola: non serve preparare nulla.
  @override
  IdeaPrep get prep => IdeaPrep.none;

  @override
  String? get variant => null;
}

/// Una presentazione Montessori da fare a casa.
class HomeIdea extends DailyIdea {
  const HomeIdea(this.activity, {IdeaReason reason = IdeaReason.none}) : super(reason);
  final Activity activity;

  @override
  String get key => 'activity:${activity.id}';

  Capacity get capacity => capacityOfActivity(activity);

  /// Con uno o due oggetti di casa si è pronti subito; con più, ci vuole un po'.
  @override
  IdeaPrep get prep => materials.length <= 2 ? IdeaPrep.quick : IdeaPrep.short;

  /// "Osserva" del primo livello: come proseguire nei giorni dopo.
  @override
  String? get variant => switch (activity.level(1)['observe']) {
        final String t when t.trim().isNotEmpty => t.trim(),
        _ => null,
      };

  /// "Cosa serve" del primo livello.
  List<String> get materials => [
        for (final m in (activity.level(1)['materials'] as List? ?? const []))
          if (m is Map && m['label'] is String) '${m['emoji'] ?? ''} ${m['label']}'.trim(),
      ];
}

/// Un'idea proposta in un giorno ("2026-10-13"): la tabella daily_ideas.
typedef ProposedIdea = ({String day, String key});

/// Il giorno come chiave dello storico delle idee.
String ideaDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Titolo della sezione "Nella vita vera" nelle lingue della scheda genitore.
const _realLifeHeadings = {'nella vita vera', 'in real life', 'dans la vraie vie', 'en la vida real', 'im echten leben'};

/// Il testo della sezione "Nella vita vera" di una scheda genitore, o null.
String? realLifeSection(String markdown) {
  final out = <String>[];
  var inside = false;
  for (final line in markdown.split('\n')) {
    if (line.startsWith('## ')) {
      if (inside) break;
      inside = _realLifeHeadings.contains(line.substring(3).trim().toLowerCase());
      continue;
    }
    if (inside) out.add(line);
  }
  final text = out.join('\n').trim();
  return text.isEmpty ? null : text;
}

/// Le idee per un bambino, già in ordine di priorità (3.4.3):
/// 1. presentazione segnata "vuole rifarla" negli ultimi 7 giorni;
/// 2. storia finita negli ultimi 3 giorni, con la sezione "Nella vita vera";
/// 3. presentazione fatta con l'adulto ma mai da solo;
/// 4. presentazione nuova nella capacità che sceglie più spesso;
/// 5. qualsiasi presentazione della sua fascia.
///
/// Un'idea proposta negli ultimi 14 giorni ([history]) non torna, a meno che
/// dopo quel giorno il bambino non abbia chiesto di rifarla. L'idea già scelta
/// oggi resta la prima: così non cambia riaprendo l'area genitore, anche se
/// nel frattempo cambiano i dati. Se sono state proposte tutte, si ricomincia.
/// Le idee in [dismissed] (scartate dal genitore) non tornano mai.
List<DailyIdea> ideasFor({
  required DateTime now,
  required AgeBand band,
  required List<DiaryEntry> diary,
  required List<Map<String, Object?>> rounds,
  required List<ProposedIdea> history,
  required Story? Function(String id) story,
  required List<Activity> activities,
  Set<String> dismissed = const {},
}) {
  final home = [for (final a in activities) if (a.isHome && a.supports(band)) a];
  final byId = {for (final a in activities) a.id: a};
  final sorted = [...rounds]..sort((a, b) => (b['at'] as String).compareTo(a['at'] as String));
  DateTime at(Map<String, Object?> r) => DateTime.parse(r['at'] as String);
  bool chose(String activityId, String choice) =>
      rounds.any((r) => r['activity_id'] == activityId && r['choice'] == 'presentation=$choice');

  final all = <DailyIdea>[];
  final lastRepeat = <String, DateTime>{};
  void add(DailyIdea idea) {
    if (!all.any((x) => x.key == idea.key)) all.add(idea);
  }

  // 1. Ha chiesto di rifarla.
  final weekAgo = now.subtract(const Duration(days: 7));
  for (final r in sorted) {
    final a = byId[r['activity_id']];
    if (r['choice'] != 'presentation=repeat' || a == null || !home.contains(a) || !at(r).isAfter(weekAgo)) continue;
    lastRepeat.putIfAbsent('activity:${a.id}', () => at(r));
    add(HomeIdea(a, reason: IdeaReason.repeat));
  }

  // 2. Storie finite negli ultimi 3 giorni, dalla più recente.
  final threeDaysAgo = now.subtract(const Duration(days: 3));
  final recent = [for (final e in diary) if (e.completed && e.when.isAfter(threeDaysAgo)) e]
    ..sort((a, b) => b.when.compareTo(a.when));
  for (final e in recent) {
    final s = story(e.storyId);
    if (s?.parentCard case final card?) {
      if (realLifeSection(card) case final text?) add(StoryIdea(s!, text));
    }
  }

  // 3. Fatta con l'adulto, mai da solo: dalla più recente.
  for (final r in sorted) {
    final a = byId[r['activity_id']];
    if (r['choice'] != 'presentation=done' || a == null || !home.contains(a) || chose(a.id, 'alone')) continue;
    add(HomeIdea(a, reason: IdeaReason.tryAlone));
  }

  // 4. Nuova, nella capacità scelta più spesso (una sessione = stessi attività e istante).
  final sessions = <Capacity, Set<String>>{};
  for (final r in rounds) {
    final a = byId[r['activity_id']];
    if (a != null) sessions.putIfAbsent(capacityOfActivity(a), () => {}).add('${a.id}@${r['at']}');
  }
  if (sessions.isNotEmpty) {
    final favourite = Capacity.values
        .where(sessions.containsKey)
        .reduce((a, b) => sessions[b]!.length > sessions[a]!.length ? b : a);
    for (final a in home) {
      if (capacityOfActivity(a) == favourite && !rounds.any((r) => r['activity_id'] == a.id)) {
        add(HomeIdea(a, reason: IdeaReason.capacity));
      }
    }
  }

  // 5. Tutte le altre della fascia.
  for (final a in home) {
    add(HomeIdea(a));
  }

  final today = ideaDay(now);
  final twoWeeksAgo = ideaDay(now.subtract(const Duration(days: 14)));
  final lastProposed = <String, String>{};
  for (final p in history) {
    if (p.day == today || p.day.compareTo(twoWeeksAgo) <= 0) continue;
    if (p.day.compareTo(lastProposed[p.key] ?? '') > 0) lastProposed[p.key] = p.day;
  }
  bool fresh(DailyIdea i) {
    final day = lastProposed[i.key];
    if (day == null) return true;
    final repeat = lastRepeat[i.key];
    return repeat != null && !repeat.isBefore(DateTime.parse(day));
  }

  final chosen = [for (final p in history) if (p.day == today) p.key];
  // L'idea di oggi resta anche se nel frattempo è uscita dalle regole
  // (per esempio la storia ha superato i 3 giorni).
  for (final key in chosen) {
    if (all.any((i) => i.key == key)) continue;
    final a = key.startsWith('activity:') ? byId[key.substring(9)] : null;
    final s = key.startsWith('story:') ? story(key.substring(6)) : null;
    if (a != null) all.insert(0, HomeIdea(a));
    if (s?.parentCard case final card?) {
      if (realLifeSection(card) case final text?) all.insert(0, StoryIdea(s!, text));
    }
  }

  // Il genitore ha scartato queste idee ("non abbiamo i materiali", "non ci
  // interessa"): non tornano, nemmeno se erano quelle di oggi.
  all.removeWhere((i) => dismissed.contains(i.key));

  final first = [for (final i in all) if (chosen.contains(i.key)) i];
  final rest = [for (final i in all) if (!chosen.contains(i.key) && fresh(i)) i];
  return [...first, ...(rest.isEmpty && first.isEmpty ? all : rest)];
}
