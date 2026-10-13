/// Racconto della settimana e idea per oggi (3.4.1, 3.4.3) per l'area genitore.
/// Usa solo dati già sul dispositivo: diario, gesti e round delle attività.
/// Nessun punteggio e nessun confronto con altri bambini.
library;

import '../models/activity.dart';
import '../models/profile.dart';
import '../models/story.dart';

/// Gli ultimi sette giorni di un bambino, pronti da raccontare.
class WeekDigest {
  const WeekDigest({
    required this.stories,
    required this.sessions,
    required this.together,
    required this.choices,
    required this.gestures,
    required this.home,
  });

  /// Storie finite, senza doppioni, dalla più recente.
  final List<Story> stories;

  /// Storie finite, contando anche le riletture.
  final int sessions;

  /// Quante di quelle sessioni erano "insieme".
  final int together;

  /// Per storia, l'ultima scelta fatta alla pausa (etichetta già tradotta).
  final List<(Story, String)> choices;

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
    final choices = <(Story, String)>[];
    for (final e in done) {
      final s = story(e.storyId);
      if (s == null || stories.any((x) => x.id == s.id)) continue;
      stories.add(s);
      final answer = done.firstWhere((x) => x.storyId == s.id && x.dialogueAnswer != null, orElse: () => e).dialogueAnswer;
      final label = answer == null ? null : _answerLabel(s, answer);
      if (label != null) choices.add((s, label));
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
      choices: choices,
      gestures: gestures,
      home: home,
    );
  }

  static String? _answerLabel(Story story, String answerId) {
    for (final v in story.variants.values) {
      for (final s in v.screens) {
        for (final o in s.dialogue?.options ?? const <DialogueOption>[]) {
          if (o.id == answerId) return o.label;
        }
      }
    }
    return null;
  }
}

/// Un'idea concreta da fare oggi, fuori dallo schermo.
sealed class DailyIdea {
  const DailyIdea();
}

/// Dalla sezione "Nella vita vera" della scheda genitore di una storia finita.
class StoryIdea extends DailyIdea {
  const StoryIdea(this.story, this.text);
  final Story story;
  final String text;
}

/// Una presentazione Montessori da fare a casa.
class HomeIdea extends DailyIdea {
  const HomeIdea(this.activity);
  final Activity activity;

  /// "Cosa serve" del primo livello.
  List<String> get materials => [
        for (final m in (activity.level(1)['materials'] as List? ?? const []))
          if (m is Map && m['label'] is String) '${m['emoji'] ?? ''} ${m['label']}'.trim(),
      ];
}

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

/// Le idee possibili per un bambino: prima le storie finite (dalla più recente),
/// poi le presentazioni adatte alla sua fascia d'età.
List<DailyIdea> ideasFor({required List<Story> finished, required List<Activity> activities, required AgeBand band}) => [
      for (final s in finished)
        if (s.parentCard case final card?)
          if (realLifeSection(card) case final text?) StoryIdea(s, text),
      for (final a in activities)
        if (a.isHome && a.supports(band)) HomeIdea(a),
    ];

/// L'idea del giorno: cambia ogni giorno e resta la stessa per tutta la giornata.
/// [skip] scorre alle idee successive ("Un'altra idea").
DailyIdea? ideaForDay(List<DailyIdea> ideas, DateTime day, {int skip = 0}) {
  if (ideas.isEmpty) return null;
  final dayNumber = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return ideas[(dayNumber + skip) % ideas.length];
}
