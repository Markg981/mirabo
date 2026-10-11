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
    this.aloneSessionMinutes = 20,
    this.storiesCompleted = 0,
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
  final int aloneSessionMinutes;

  /// Storie completate: guida la crescita del compagno (progressione narrativa).
  final int storiesCompleted;

  int get companionStage {
    if (storiesCompleted >= 12) return 3;
    if (storiesCompleted >= 6) return 2;
    if (storiesCompleted >= 3) return 1;
    return 0;
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
    int? aloneSessionMinutes,
    int? storiesCompleted,
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
        aloneSessionMinutes: aloneSessionMinutes ?? this.aloneSessionMinutes,
        storiesCompleted: storiesCompleted ?? this.storiesCompleted,
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
        'alone_minutes': aloneSessionMinutes,
        'stories_completed': storiesCompleted,
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
        aloneSessionMinutes: r['alone_minutes'] as int,
        storiesCompleted: r['stories_completed'] as int,
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
