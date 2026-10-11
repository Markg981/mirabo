/// Modello di una storia e delle sue varianti per fascia d'età.
/// Rispecchia content/schema/*.json: ogni modifica allo schema si riflette qui.
library;

enum World { emozioni, inclusione, ambiente, sicurezza }

enum AgeBand {
  b3to5('3-5', 'Piccoli', 3, 5),
  b5to7('5-7', 'Primi passi', 5, 7),
  b7to10('7-10', 'Grandi', 7, 10);

  const AgeBand(this.key, this.label, this.minAge, this.maxAge);
  final String key;
  final String label;
  final int minAge;
  final int maxAge;

  static AgeBand fromKey(String key) =>
      AgeBand.values.firstWhere((b) => b.key == key, orElse: () => throw ArgumentError('Fascia sconosciuta: $key'));

  static AgeBand forAge(int age) {
    if (age < 5) return AgeBand.b3to5;
    if (age < 7) return AgeBand.b5to7;
    return AgeBand.b7to10;
  }
}

enum ScreenKind { hook, situation, dialogue, turn, closing }

enum CompanionId { bo, pilu, tango }

/// Le tre versioni di una battuta del compagno.
class CompanionLines {
  const CompanionLines({required this.bo, required this.pilu, required this.tango});

  final String bo;
  final String pilu;
  final String tango;

  factory CompanionLines.fromJson(Map<String, dynamic> j) =>
      CompanionLines(bo: j['bo'] as String, pilu: j['pilu'] as String, tango: j['tango'] as String);

  String forCompanion(CompanionId id) => switch (id) {
        CompanionId.bo => bo,
        CompanionId.pilu => pilu,
        CompanionId.tango => tango,
      };
}

class DialogueOption {
  const DialogueOption({required this.id, required this.icon, required this.label, required this.reaction});

  final String id;
  final String icon;
  final String label;
  final CompanionLines reaction;

  factory DialogueOption.fromJson(Map<String, dynamic> j) => DialogueOption(
        id: j['id'] as String,
        icon: j['icon'] as String,
        label: j['label'] as String,
        reaction: CompanionLines.fromJson(j['reaction'] as Map<String, dynamic>),
      );
}

class Dialogue {
  const Dialogue({required this.together, required this.alonePrompt, required this.options});

  /// Testo per il genitore in modalità insieme.
  final String together;
  final CompanionLines alonePrompt;
  final List<DialogueOption> options;

  factory Dialogue.fromJson(Map<String, dynamic> j) {
    final alone = j['alone'] as Map<String, dynamic>;
    return Dialogue(
      together: j['together'] as String,
      alonePrompt: CompanionLines.fromJson(alone['prompt'] as Map<String, dynamic>),
      options: (alone['options'] as List).map((o) => DialogueOption.fromJson(o as Map<String, dynamic>)).toList(),
    );
  }
}

class Illustration {
  const Illustration({this.file, required this.alt});
  final String? file;
  final String alt;

  factory Illustration.fromJson(Map<String, dynamic> j) =>
      Illustration(file: j['file'] as String?, alt: j['alt'] as String);
}

class StoryAudio {
  const StoryAudio({required this.file, this.words = const [], this.nameSlots = const []});
  final String file;

  /// Coppie (millisecondi, parola) per l'evidenziazione durante la lettura.
  final List<(int, String)> words;

  /// Istanti in cui inserire il nome del bambino.
  final List<int> nameSlots;

  factory StoryAudio.fromJson(Map<String, dynamic> j) => StoryAudio(
        file: j['file'] as String,
        words: ((j['words'] as List?) ?? const []).map((w) => ((w as List)[0] as int, w[1] as String)).toList(),
        nameSlots: ((j['nameSlots'] as List?) ?? const []).cast<int>(),
      );
}

class StoryScreen {
  const StoryScreen({
    required this.n,
    required this.kind,
    required this.illustration,
    this.text,
    this.audio,
    this.companionLines,
    this.dialogue,
    this.isKeyPhrase = false,
  });

  final int n;
  final ScreenKind kind;
  final Illustration illustration;
  final String? text;
  final StoryAudio? audio;
  final CompanionLines? companionLines;
  final Dialogue? dialogue;
  final bool isKeyPhrase;

  factory StoryScreen.fromJson(Map<String, dynamic> j) => StoryScreen(
        n: j['n'] as int,
        kind: ScreenKind.values.byName(j['kind'] as String),
        illustration: Illustration.fromJson(j['illustration'] as Map<String, dynamic>),
        text: j['text'] as String?,
        audio: j['audio'] == null ? null : StoryAudio.fromJson(j['audio'] as Map<String, dynamic>),
        companionLines:
            j['companionLines'] == null ? null : CompanionLines.fromJson(j['companionLines'] as Map<String, dynamic>),
        dialogue: j['dialogue'] == null ? null : Dialogue.fromJson(j['dialogue'] as Map<String, dynamic>),
        isKeyPhrase: (j['keyPhrase'] as bool?) ?? false,
      );
}

class StoryVariant {
  const StoryVariant({required this.ageBand, required this.screens});
  final AgeBand ageBand;
  final List<StoryScreen> screens;

  factory StoryVariant.fromJson(Map<String, dynamic> j) => StoryVariant(
        ageBand: AgeBand.fromKey(j['ageBand'] as String),
        screens: (j['screens'] as List).map((s) => StoryScreen.fromJson(s as Map<String, dynamic>)).toList(),
      );
}

/// Metadati di una storia (story.json) più le varianti caricate dal pacchetto.
class Story {
  const Story({
    required this.id,
    required this.version,
    required this.title,
    required this.world,
    required this.topic,
    this.series,
    this.episode,
    required this.variantFiles,
    required this.formats,
    required this.togetherOnly,
    required this.keyPhrase,
    this.gesture,
    required this.parentCardFile,
    required this.sources,
    this.variants = const {},
    this.parentCard,
  });

  final String id;
  final int version;
  final String title;
  final World world;
  final String topic;
  final String? series;
  final int? episode;
  final Map<AgeBand, String> variantFiles;
  final List<String> formats;
  final bool togetherOnly;
  final String keyPhrase;
  final String? gesture;
  final String parentCardFile;
  final List<String> sources;
  final Map<AgeBand, StoryVariant> variants;
  final String? parentCard;

  bool supports(AgeBand band) => variantFiles.containsKey(band);

  factory Story.fromJson(Map<String, dynamic> j) => Story(
        id: j['id'] as String,
        version: j['version'] as int,
        title: j['title'] as String,
        world: World.values.byName(j['world'] as String),
        topic: j['topic'] as String,
        series: j['series'] as String?,
        episode: j['episode'] as int?,
        variantFiles: (j['ageBands'] as Map<String, dynamic>).map((k, v) => MapEntry(AgeBand.fromKey(k), v as String)),
        formats: (j['formats'] as List).cast<String>(),
        togetherOnly: j['togetherOnly'] as bool,
        keyPhrase: j['keyPhrase'] as String,
        gesture: j['gesture'] as String?,
        parentCardFile: j['parentCard'] as String,
        sources: ((j['sources'] as List?) ?? const []).cast<String>(),
      );

  Story withContent({required Map<AgeBand, StoryVariant> variants, String? parentCard}) => Story(
        id: id,
        version: version,
        title: title,
        world: world,
        topic: topic,
        series: series,
        episode: episode,
        variantFiles: variantFiles,
        formats: formats,
        togetherOnly: togetherOnly,
        keyPhrase: keyPhrase,
        gesture: gesture,
        parentCardFile: parentCardFile,
        sources: sources,
        variants: variants,
        parentCard: parentCard,
      );
}
