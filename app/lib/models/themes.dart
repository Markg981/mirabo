/// I temi: il catalogo completo, sempre raggiungibile. Ogni tema raccoglie,
/// per fascia, le stesse tre modalità (una storia, un gioco, una cosa da
/// provare nella vita vera) attorno a una sola esperienza della matrice
/// educativa (content/education/matrix.json, vedi docs/theme-navigation.md).
///
/// Il tema di un contenuto è scritto nella matrice con il suo identificatore
/// stabile ("story:…", "activity:…", "gesture:…", "offscreen:…"), mai dedotto
/// dal titolo. Cosa si vede dipende solo da fascia, lingua e permessi
/// dell'adulto: né i completamenti, né l'uso, né la settimana della mensola.
library;

import 'activity.dart';
import 'story.dart';

/// I tre temi. [id] è l'identificatore stabile della matrice
/// (THEME_IDS in studio/check_goals.py): si cambia il nome mostrato, non lui.
enum ChildTheme {
  emozioniRelazioni('emozioni-relazioni'),
  naturaViventi('natura-viventi'),
  autonomiaScuola('autonomia-scuola');

  const ChildTheme(this.id);
  final String id;

  static ChildTheme? byId(String id) {
    for (final t in values) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// Le tre modalità, sempre in quest'ordine e nello stesso posto dello schermo.
enum ExperienceMode { story, game, practice }

/// Un'esperienza raggiungibile da un tema. [key] è il riferimento stabile
/// della matrice.
sealed class ThemeExperience {
  const ThemeExperience();
  String get key;
}

class ThemeStory extends ThemeExperience {
  const ThemeStory(this.story);
  final Story story;

  @override
  String get key => 'story:${story.id}';
}

/// Un'attività dell'app: il gioco di un tema o, se è una presentazione da
/// fare con i materiali di casa, la sua parte pratica.
class ThemeActivity extends ThemeExperience {
  const ThemeActivity(this.activity);
  final Activity activity;

  @override
  String get key => 'activity:${activity.id}';
}

/// Una cosa da provare fuori dallo schermo: il gesto di una storia o
/// l'indicazione "fuori dallo schermo" di un'attività.
class ThemePractice extends ThemeExperience {
  const ThemePractice.gesture(Story this.story) : activity = null;
  const ThemePractice.offscreen(Activity this.activity) : story = null;

  final Story? story;
  final Activity? activity;

  /// Il titolo del contenuto da cui viene, per riconoscerla.
  String get title => story?.title ?? activity!.title;

  /// Cosa fare, nella lingua del bambino.
  String get instruction => story?.gesture ?? activity!.offscreen;

  @override
  String get key => story != null ? 'gesture:${story!.id}' : 'offscreen:${activity!.id}';
}

/// La parte della matrice che serve alla navigazione
/// (app/assets/education/themes.json, scritto da studio/sync_assets.py).
class ThemeCatalog {
  const ThemeCatalog(this._refs);

  /// Senza file dei temi non c'è niente da mostrare: resta la mensola.
  static const empty = ThemeCatalog({});

  /// Tema e fascia -> per modalità i riferimenti, nell'ordine della matrice.
  final Map<(ChildTheme, AgeBand), Map<ExperienceMode, List<String>>> _refs;

  bool get isEmpty => _refs.isEmpty;

  factory ThemeCatalog.fromJson(Map<String, dynamic> j) {
    final out = <(ChildTheme, AgeBand), Map<ExperienceMode, List<String>>>{};
    for (final c in (j['cells'] as List).cast<Map<String, dynamic>>()) {
      // Un tema che l'app non conosce ancora si ignora: non si indovina.
      final theme = ChildTheme.byId(c['theme'] as String);
      if (theme == null) continue;
      out[(theme, AgeBand.fromKey(c['band'] as String))] = {
        for (final m in ExperienceMode.values) m: ((c[m.name] as List?) ?? const []).cast<String>(),
      };
    }
    return ThemeCatalog(out);
  }

  /// I riferimenti di un tema per una fascia.
  Map<ExperienceMode, List<String>> refs(ChildTheme theme, AgeBand band) =>
      _refs[(theme, band)] ?? {for (final m in ExperienceMode.values) m: const <String>[]};

  /// Le esperienze di un tema per modalità, fra i contenuti che il bambino
  /// può aprire adesso ([stories] e [activities] sono già filtrati per
  /// fascia, lingua e permessi). Un riferimento che non si trova resta fuori.
  /// Il gesto segue la sua storia: se l'adulto non la permette, non c'è
  /// nemmeno il gesto.
  Map<ExperienceMode, List<ThemeExperience>> resolve(ChildTheme theme, AgeBand band, {required List<Story> stories, required List<Activity> activities}) {
    final storyById = {for (final s in stories) s.id: s};
    final activityById = {for (final a in activities) a.id: a};
    ThemeExperience? find(String ref) {
      final i = ref.indexOf(':');
      if (i < 0) return null;
      final id = ref.substring(i + 1);
      return switch (ref.substring(0, i)) {
        'story' => storyById[id] == null ? null : ThemeStory(storyById[id]!),
        'activity' => activityById[id] == null ? null : ThemeActivity(activityById[id]!),
        'gesture' => (storyById[id]?.gesture ?? '').isEmpty ? null : ThemePractice.gesture(storyById[id]!),
        'offscreen' => (activityById[id]?.offscreen ?? '').isEmpty ? null : ThemePractice.offscreen(activityById[id]!),
        _ => null,
      };
    }

    return {
      for (final e in refs(theme, band).entries)
        e.key: [for (final r in e.value) if (find(r) case final x?) x],
    };
  }
}
