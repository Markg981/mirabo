import 'story.dart';

/// Modalità di una sessione: scelta dal genitore all'avvio.
enum SessionMode { together, alone }

/// Profilo di un bambino. Vive solo sul dispositivo.
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.ageBand,
    required this.companion,
    this.enabledWorlds = const {World.emozioni, World.inclusione, World.ambiente, World.sicurezza},
    this.safetyTogetherOnly = true,
    this.lastMode = SessionMode.together,
    this.dyslexiaFont = false,
    this.lowStimulation = false,
    this.readAlong = true,
    this.aloneSessionMinutes = 20,
    this.storiesCompleted = 0,
    this.gesturesDone = 0,
    this.stageFloor = 0,
    this.language = 'it',
    this.shelf,
    this.shelfAuto,
    this.shelfRotatedAt,
  });

  final int id;
  final String name;
  final AgeBand ageBand;
  final CompanionId companion;
  final Set<World> enabledWorlds;

  /// Default: il mondo Sicurezza e corpo solo in modalità insieme.
  final bool safetyTogetherOnly;
  final SessionMode lastMode;
  final bool dyslexiaFont;
  final bool lowStimulation;

  /// Lettura karaoke: la parola che la voce legge si illumina nel testo.
  final bool readAlong;
  final int aloneSessionMinutes;

  /// Storie completate: solo un dato per il genitore, non fa crescere il compagno.
  final int storiesCompleted;

  /// Gesti delle storie fatti nella vita vera, confermati dal genitore: sono
  /// l'unica cosa che fa crescere il compagno. Il tempo sullo schermo non conta.
  final int gesturesDone;

  /// Stadio già raggiunto prima che la crescita passasse ai gesti: il compagno
  /// non torna indietro.
  final int stageFloor;

  /// Codice della lingua del bambino (it, en, es, fr, de): interfaccia lato
  /// bambino, contenuti e voce del compagno.
  final String language;

  /// Chiavi dei materiali che il genitore ha messo sulla mensola
  /// (vedi models/shelf.dart); null finché la mensola si riempie da sola.
  final List<String>? shelf;

  /// La mensola automatica salvata: resta uguale per tutta la settimana, così
  /// il bambino ritrova ciò che ha lasciato. Null finché non è stata riempita.
  final List<String>? shelfAuto;

  /// Quando la mensola automatica è cambiata l'ultima volta.
  final DateTime? shelfRotatedAt;

  /// Gesti necessari per ogni stadio del compagno (1, 2, 3).
  static const stageThresholds = [3, 6, 12];

  static int stageFor(int count) => stageThresholds.where((t) => count >= t).length;

  int get companionStage {
    final s = stageFor(gesturesDone);
    return s > stageFloor ? s : stageFloor;
  }

  /// Quanti gesti mancano al prossimo stadio; null se il compagno è già grande.
  int? get gesturesToNextStage {
    for (final t in stageThresholds) {
      if (stageFor(t) > companionStage) return t - gesturesDone;
    }
    return null;
  }

  bool canOpen(Story story, SessionMode mode) {
    if (!enabledWorlds.contains(story.world)) return false;
    if (!story.supports(ageBand)) return false;
    if (mode == SessionMode.alone && (story.togetherOnly || (safetyTogetherOnly && story.world == World.sicurezza))) {
      return false;
    }
    return true;
  }

  ChildProfile copyWith({
    String? name,
    AgeBand? ageBand,
    CompanionId? companion,
    Set<World>? enabledWorlds,
    bool? safetyTogetherOnly,
    SessionMode? lastMode,
    bool? dyslexiaFont,
    bool? lowStimulation,
    bool? readAlong,
    int? aloneSessionMinutes,
    int? storiesCompleted,
    int? gesturesDone,
    String? language,
  }) =>
      ChildProfile(
        id: id,
        name: name ?? this.name,
        ageBand: ageBand ?? this.ageBand,
        companion: companion ?? this.companion,
        enabledWorlds: enabledWorlds ?? this.enabledWorlds,
        safetyTogetherOnly: safetyTogetherOnly ?? this.safetyTogetherOnly,
        lastMode: lastMode ?? this.lastMode,
        dyslexiaFont: dyslexiaFont ?? this.dyslexiaFont,
        lowStimulation: lowStimulation ?? this.lowStimulation,
        readAlong: readAlong ?? this.readAlong,
        aloneSessionMinutes: aloneSessionMinutes ?? this.aloneSessionMinutes,
        storiesCompleted: storiesCompleted ?? this.storiesCompleted,
        gesturesDone: gesturesDone ?? this.gesturesDone,
        stageFloor: stageFloor,
        language: language ?? this.language,
        shelf: shelf,
        shelfAuto: shelfAuto,
        shelfRotatedAt: shelfRotatedAt,
      );

  /// La mensola scelta dal genitore; null torna alla scelta automatica.
  ChildProfile withShelf(List<String>? keys) => _withShelves(keys == null ? null : List.unmodifiable(keys), shelfAuto, shelfRotatedAt);

  /// La mensola automatica appena riempita o ruotata.
  ChildProfile withAutoShelf(List<String> keys, DateTime at) => _withShelves(shelf, List.unmodifiable(keys), at);

  ChildProfile _withShelves(List<String>? shelf, List<String>? shelfAuto, DateTime? shelfRotatedAt) => ChildProfile(
        id: id,
        name: name,
        ageBand: ageBand,
        companion: companion,
        enabledWorlds: enabledWorlds,
        safetyTogetherOnly: safetyTogetherOnly,
        lastMode: lastMode,
        dyslexiaFont: dyslexiaFont,
        lowStimulation: lowStimulation,
        readAlong: readAlong,
        aloneSessionMinutes: aloneSessionMinutes,
        storiesCompleted: storiesCompleted,
        gesturesDone: gesturesDone,
        stageFloor: stageFloor,
        language: language,
        shelf: shelf,
        shelfAuto: shelfAuto,
        shelfRotatedAt: shelfRotatedAt,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'name': name,
        'age_band': ageBand.key,
        'companion': companion.name,
        'enabled_worlds': enabledWorlds.map((w) => w.name).join(','),
        'safety_together_only': safetyTogetherOnly ? 1 : 0,
        'last_mode': lastMode.name,
        'dyslexia_font': dyslexiaFont ? 1 : 0,
        'low_stimulation': lowStimulation ? 1 : 0,
        'read_along': readAlong ? 1 : 0,
        'alone_minutes': aloneSessionMinutes,
        'stories_completed': storiesCompleted,
        'gestures_done': gesturesDone,
        'stage_floor': stageFloor,
        'language': language,
        'shelf': shelf?.join(','),
        'shelf_auto': shelfAuto?.join(','),
        'shelf_rotated_at': shelfRotatedAt?.toIso8601String(),
      };

  factory ChildProfile.fromRow(Map<String, Object?> r) => ChildProfile(
        id: r['id'] as int,
        name: r['name'] as String,
        ageBand: AgeBand.fromKey(r['age_band'] as String),
        companion: CompanionId.values.byName(r['companion'] as String),
        enabledWorlds: (r['enabled_worlds'] as String).split(',').where((s) => s.isNotEmpty).map(World.values.byName).toSet(),
        safetyTogetherOnly: (r['safety_together_only'] as int) == 1,
        lastMode: SessionMode.values.byName(r['last_mode'] as String),
        dyslexiaFont: (r['dyslexia_font'] as int) == 1,
        lowStimulation: (r['low_stimulation'] as int) == 1,
        readAlong: (r['read_along'] as int? ?? 1) == 1,
        aloneSessionMinutes: r['alone_minutes'] as int,
        storiesCompleted: r['stories_completed'] as int,
        gesturesDone: r['gestures_done'] as int? ?? 0,
        stageFloor: r['stage_floor'] as int? ?? 0,
        language: r['language'] as String? ?? 'it',
        shelf: (r['shelf'] as String?)?.split(',').where((s) => s.isNotEmpty).toList(),
        shelfAuto: (r['shelf_auto'] as String?)?.split(',').where((s) => s.isNotEmpty).toList(),
        shelfRotatedAt: r['shelf_rotated_at'] == null ? null : DateTime.parse(r['shelf_rotated_at'] as String),
      );
}

/// Una voce del diario: storia letta, con eventuale risposta alla pausa di dialogo.
class DiaryEntry {
  const DiaryEntry({
    required this.profileId,
    required this.storyId,
    required this.mode,
    required this.completed,
    required this.when,
    this.dialogueAnswer,
  });

  final int profileId;
  final String storyId;
  final SessionMode mode;
  final bool completed;
  final DateTime when;
  final String? dialogueAnswer;
}

/// Un gesto di una storia fatto davvero, segnato dal genitore nel diario.
class GestureEntry {
  const GestureEntry({required this.profileId, required this.storyId, required this.when});

  final int profileId;
  final String storyId;
  final DateTime when;
}
