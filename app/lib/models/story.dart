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

enum ScreenKind { hook, situation, dialogue, lesson, gesture, turn, closing }

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

/// Una figura della scena composta: un'emoji o un elemento dipinto dall'app
/// (`companion`, `volcano`, `tower`, `pebble`). x e y sono il centro in
/// frazioni del riquadro, s l'altezza in frazioni dell'altezza del riquadro.
class SceneItem {
  const SceneItem({
    this.emoji,
    this.paint,
    required this.x,
    required this.y,
    required this.size,
    this.rotation = 0,
    this.flip = false,
    this.opacity = 1,
    this.color,
    this.variant,
    this.smoke = false,
    this.flower = false,
    this.flag = true,
  });

  final String? emoji;
  final String? paint;
  final double x;
  final double y;
  final double size;

  /// Gradi, in senso orario.
  final double rotation;
  final bool flip;
  final double opacity;
  final String? color;
  final String? variant;
  final bool smoke;
  final bool flower;
  final bool flag;

  factory SceneItem.fromJson(Map<String, dynamic> j) => SceneItem(
        emoji: j['e'] as String?,
        paint: j['paint'] as String?,
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        size: (j['s'] as num).toDouble(),
        rotation: (j['rot'] as num?)?.toDouble() ?? 0,
        flip: j['flip'] as bool? ?? false,
        opacity: (j['opacity'] as num?)?.toDouble() ?? 1,
        color: j['color'] as String?,
        variant: j['variant'] as String?,
        smoke: j['smoke'] as bool? ?? false,
        flower: j['flower'] as bool? ?? false,
        flag: j['flag'] as bool? ?? true,
      );
}

/// Illustrazione composta: sfondo dipinto (`room`, `forest`, `stream`, `sky`)
/// e figure. Serve finché la schermata non ha un disegno vero (`file`).
class SceneSpec {
  const SceneSpec({required this.background, required this.items, this.dirty = false});
  final String background;
  final List<SceneItem> items;

  /// Solo per `stream`: acqua torbida.
  final bool dirty;

  factory SceneSpec.fromJson(Map<String, dynamic> j) => SceneSpec(
        background: j['bg'] as String,
        dirty: j['dirty'] as bool? ?? false,
        items: (j['items'] as List).map((i) => SceneItem.fromJson(i as Map<String, dynamic>)).toList(),
      );
}

class Illustration {
  const Illustration({this.file, required this.alt, this.scene});
  final String? file;
  final String alt;
  final SceneSpec? scene;

  factory Illustration.fromJson(Map<String, dynamic> j) =>
      Illustration(
        file: j['file'] as String?,
        alt: j['alt'] as String,
        scene: j['scene'] == null ? null : SceneSpec.fromJson(j['scene'] as Map<String, dynamic>),
      );
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

/// Una figura della lezione in tre tempi: cosa si vede, come si chiama e le
/// due frasi fisse del primo e del secondo tempo.
class LessonItem {
  const LessonItem({required this.id, required this.emoji, required this.name, required this.naming, required this.show});

  final String id;
  final String emoji;

  /// Il nome da solo, come lo dice il bambino nel terzo tempo.
  final String name;

  /// Primo tempo: "Questa è la luna."
  final String naming;

  /// Secondo tempo: "Dov'è la luna?"
  final String show;

  factory LessonItem.fromJson(Map<String, dynamic> j) => LessonItem(
        id: j['id'] as String,
        emoji: j['e'] as String,
        name: j['name'] as String,
        naming: j['this'] as String,
        show: j['show'] as String,
      );
}

/// Lezione in tre tempi (Montessori), solo in fascia 3–5: si nomina, si
/// riconosce, si ricorda. Le frasi sono le stesse per i tre compagni: in
/// questa lezione le parole devono essere poche e sempre uguali.
class Lesson {
  const Lesson({required this.together, required this.items, required this.ask, required this.done});

  /// Guida per il genitore in modalità insieme.
  final String together;
  final List<LessonItem> items;

  /// Terzo tempo: la domanda davanti a una figura ("E questa, cos'è?").
  final String ask;

  /// Detta alla fine, con tutte le figure di nuovo in vista.
  final String done;

  LessonItem item(String id) => items.firstWhere((i) => i.id == id);

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        together: j['together'] as String,
        items: (j['items'] as List).map((i) => LessonItem.fromJson(i as Map<String, dynamic>)).toList(),
        ask: j['ask'] as String,
        done: j['done'] as String,
      );
}

/// Pausa di gesto: la storia si ferma e il bambino fa con il corpo il gesto del
/// protagonista (respirare, chiudere gli occhi, ascoltare). L'invito è nelle
/// `companionLines` della schermata; da soli si va avanti dopo [seconds], quando
/// il compagno dice [back]. Non fa crescere il compagno: quello lo fa solo il
/// gesto nella vita vera, segnato dal genitore.
class GesturePause {
  const GesturePause({required this.emoji, required this.seconds, required this.together, required this.back});

  final String emoji;

  /// Quanto dura la pausa da soli, prima che si possa andare avanti.
  final int seconds;

  /// Guida per il genitore in modalità insieme.
  final String together;

  /// Detta dal compagno quando la pausa finisce.
  final CompanionLines back;

  factory GesturePause.fromJson(Map<String, dynamic> j) => GesturePause(
        emoji: j['e'] as String,
        seconds: j['seconds'] as int,
        together: j['together'] as String,
        back: CompanionLines.fromJson(j['back'] as Map<String, dynamic>),
      );
}

/// Chi guida nel dialogo facoltativo "leggiamo insieme".
/// `help`: "Come potremmo aiutarlo?"; `guide`: "Spiegami tu cosa fare" (il bambino guida l'adulto o il personaggio).
enum SharedPromptRole { help, guide }

/// Invito al dialogo per la lettura condivisa: nessuna risposta giusta, nessun controllo dell'app.
class SharedPrompt {
  const SharedPrompt({required this.role, required this.text});
  final SharedPromptRole role;
  final String text;

  factory SharedPrompt.fromJson(Map<String, dynamic> j) => SharedPrompt(
        role: SharedPromptRole.values.byName(j['role'] as String),
        text: j['text'] as String,
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
    this.sharedPrompt,
    this.lesson,
    this.gesture,
    this.isKeyPhrase = false,
  });

  final int n;
  final ScreenKind kind;
  final Illustration illustration;
  final String? text;
  final StoryAudio? audio;
  final CompanionLines? companionLines;
  final Dialogue? dialogue;
  final SharedPrompt? sharedPrompt;
  final Lesson? lesson;
  final GesturePause? gesture;
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
        sharedPrompt: j['sharedPrompt'] == null ? null : SharedPrompt.fromJson(j['sharedPrompt'] as Map<String, dynamic>),
        lesson: j['lesson'] == null ? null : Lesson.fromJson(j['lesson'] as Map<String, dynamic>),
        gesture: j['gesture'] == null ? null : GesturePause.fromJson(j['gesture'] as Map<String, dynamic>),
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

/// Quanto serve l'adulto durante l'attività: con il bambino, vicino, o basta saperlo.
enum Supervision {
  together,
  nearby,
  free;

  static Supervision fromKey(String key) =>
      Supervision.values.firstWhere((s) => s.name == key, orElse: () => throw ArgumentError('Supervisione sconosciuta: $key'));
}

/// L'attività della storia per una fascia: cosa serve, come si prepara, quanta
/// supervisione chiede e che alternative ci sono. Il bambino la fa senza il tablet.
class HomeActivityBand {
  const HomeActivityBand({
    required this.goal,
    required this.steps,
    required this.materials,
    required this.preparation,
    required this.supervision,
    required this.supervisionNote,
    required this.alternatives,
  });

  final String goal;
  final List<String> steps;
  final List<String> materials;
  final List<String> preparation;
  final Supervision supervision;
  final String supervisionNote;
  final List<String> alternatives;

  static List<String> _strings(Object? v) => ((v as List?) ?? const []).cast<String>();

  factory HomeActivityBand.fromJson(Map<String, dynamic> j) {
    final sup = j['supervision'] as Map<String, dynamic>;
    return HomeActivityBand(
      goal: j['goal'] as String,
      steps: _strings(j['steps']),
      materials: _strings(j['materials']),
      preparation: _strings(j['preparation']),
      supervision: Supervision.fromKey(sup['level'] as String),
      supervisionNote: sup['note'] as String,
      alternatives: _strings(j['alternatives']),
    );
  }
}

/// "Un'attività concreta che nasce dalla storia" (home-activity.json): un oggetto
/// o un problema del racconto diventa qualcosa da fare davvero, con tre varianti per fascia.
class HomeActivity {
  const HomeActivity({required this.title, this.intro, required this.bands});

  final String title;
  final String? intro;
  final Map<AgeBand, HomeActivityBand> bands;

  factory HomeActivity.fromJson(Map<String, dynamic> j) => HomeActivity(
        title: j['title'] as String,
        intro: j['intro'] as String?,
        bands: (j['bands'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(AgeBand.fromKey(k), HomeActivityBand.fromJson(v as Map<String, dynamic>))),
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
    this.homeActivityFile,
    required this.sources,
    this.variants = const {},
    this.parentCard,
    this.homeActivity,
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
  final String? homeActivityFile;
  final List<String> sources;
  final Map<AgeBand, StoryVariant> variants;
  final String? parentCard;
  final HomeActivity? homeActivity;

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
        homeActivityFile: j['homeActivity'] as String?,
        sources: ((j['sources'] as List?) ?? const []).cast<String>(),
      );

  Story withContent({required Map<AgeBand, StoryVariant> variants, String? parentCard, HomeActivity? homeActivity}) => Story(
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
        homeActivityFile: homeActivityFile,
        sources: sources,
        variants: variants,
        parentCard: parentCard,
        homeActivity: homeActivity,
      );
}
