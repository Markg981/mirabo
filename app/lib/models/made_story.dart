import '../l10n/app_localizations.dart';
import 'story.dart';

/// Un pezzo della fabbrica di storie: l'id (usato nei testi tradotti) e
/// l'emoji che il bambino vede e tocca.
typedef StoryPart = ({String id, String emoji});

/// Le sei scelte della fabbrica, nell'ordine in cui il bambino le fa.
enum FactoryStep { who, place, problem, feeling, helper, ending }

/// Il catalogo dei pezzi. I testi stanno nelle traduzioni (factoryWho,
/// factoryPlace…) con un `select` sull'id: aggiungere un pezzo vuol dire
/// aggiungere un caso in tutte e cinque le lingue.
abstract final class StoryParts {
  static const who = <StoryPart>[
    (id: 'dragon', emoji: '🐉'),
    (id: 'bunny', emoji: '🐰'),
    (id: 'robot', emoji: '🤖'),
    (id: 'penguin', emoji: '🐧'),
    (id: 'unicorn', emoji: '🦄'),
    (id: 'kitten', emoji: '🐱'),
  ];

  /// Il luogo decide lo sfondo dipinto della scena (vedi SceneSpec).
  static const place = <StoryPart>[
    (id: 'forest', emoji: '🌲'),
    (id: 'room', emoji: '🛏️'),
    (id: 'stream', emoji: '🏞️'),
    (id: 'sky', emoji: '☁️'),
    (id: 'snow', emoji: '⛄'),
    (id: 'night', emoji: '🌙'),
  ];

  static const problem = <StoryPart>[
    (id: 'storm', emoji: '⛈️'),
    (id: 'star', emoji: '🌟'),
    (id: 'sadFriend', emoji: '😢'),
    (id: 'litter', emoji: '🗑️'),
    (id: 'lost', emoji: '🗺️'),
  ];

  static const feeling = <StoryPart>[
    (id: 'fear', emoji: '😨'),
    (id: 'sadness', emoji: '😟'),
    (id: 'anger', emoji: '😠'),
    (id: 'curiosity', emoji: '🤔'),
    (id: 'courage', emoji: '💪'),
  ];

  static const helper = <StoryPart>[
    (id: 'turtle', emoji: '🐢'),
    (id: 'owl', emoji: '🦉'),
    (id: 'bear', emoji: '🐻'),
    (id: 'bee', emoji: '🐝'),
  ];

  static const ending = <StoryPart>[
    (id: 'party', emoji: '🎉'),
    (id: 'sleep', emoji: '😴'),
    (id: 'hug', emoji: '🤗'),
    (id: 'snack', emoji: '🍎'),
  ];

  static List<StoryPart> of(FactoryStep step) => switch (step) {
        FactoryStep.who => who,
        FactoryStep.place => place,
        FactoryStep.problem => problem,
        FactoryStep.feeling => feeling,
        FactoryStep.helper => helper,
        FactoryStep.ending => ending,
      };

  static StoryPart find(FactoryStep step, String id) => of(step).firstWhere((p) => p.id == id);

  /// Il nome del pezzo da solo, come lo dice il compagno quando lo tocchi.
  static String label(AppLocalizations l, FactoryStep step, String id) => switch (step) {
        FactoryStep.who => capitalize(l.factoryWhoA(id)),
        FactoryStep.place => capitalize(l.factoryPlaceName(id)),
        FactoryStep.problem => capitalize(l.factoryProblemName(id)),
        FactoryStep.feeling => capitalize(l.factoryFeelingName(id)),
        FactoryStep.helper => capitalize(l.factoryHelperA(id)),
        FactoryStep.ending => capitalize(l.factoryEndingName(id)),
      };
}

String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Una pagina della storia inventata: il testo da leggere e la scena.
typedef MadePage = ({String text, SceneSpec scene});

/// Una storia inventata dal bambino nella fabbrica. Si salvano solo le
/// scelte: il testo si compone ogni volta nella lingua del bambino.
class MadeStory {
  const MadeStory({
    this.id = 0,
    required this.profileId,
    this.title,
    required this.parts,
    required this.when,
  });

  final int id;
  final int profileId;

  /// Il titolo scritto dal bambino (7–10); se manca si usa il protagonista.
  final String? title;
  final Map<FactoryStep, String> parts;
  final DateTime when;

  /// La stessa storia con un altro finale, per confrontarli (7–10). Non si salva.
  MadeStory withEnding(String endingId) => MadeStory(
        id: id,
        profileId: profileId,
        title: title,
        parts: {...parts, FactoryStep.ending: endingId},
        when: when,
      );

  String part(FactoryStep s) => parts[s]!;
  String emoji(FactoryStep s) => StoryParts.find(s, part(s)).emoji;

  String titleIn(AppLocalizations l) =>
      (title?.trim().isNotEmpty ?? false) ? title!.trim() : capitalize(l.factoryWhoThe(part(FactoryStep.who)));

  /// Le pagine: inizio, problema, emozione, aiuto, fine. La scena usa lo
  /// sfondo del luogo e le emoji scelte, come le storie senza disegni.
  List<MadePage> pages(AppLocalizations l) {
    final who = part(FactoryStep.who);
    final theWho = capitalize(l.factoryWhoThe(who));
    final bg = part(FactoryStep.place);
    final hero = emoji(FactoryStep.who);
    final helper = emoji(FactoryStep.helper);

    SceneSpec scene(List<SceneItem> extra, {double heroX = 0.4}) => SceneSpec(
          background: bg,
          items: [SceneItem(emoji: hero, x: heroX, y: 0.64, size: 0.34), ...extra],
        );

    return [
      (
        text: l.factoryPageStart(l.factoryWhoA(who), l.factoryPlaceIn(bg)),
        scene: scene(const []),
      ),
      (
        text: l.factoryPageProblem(l.factoryProblem(part(FactoryStep.problem))),
        scene: scene([SceneItem(emoji: emoji(FactoryStep.problem), x: 0.72, y: 0.28, size: 0.3)], heroX: 0.32),
      ),
      (
        text: l.factoryPageFeeling(theWho, l.factoryFeeling(part(FactoryStep.feeling))),
        scene: scene([SceneItem(emoji: emoji(FactoryStep.feeling), x: 0.62, y: 0.3, size: 0.2)]),
      ),
      (
        text: l.factoryPageHelp(l.factoryHelperA(part(FactoryStep.helper)), l.factorySolution(part(FactoryStep.problem))),
        scene: scene([SceneItem(emoji: helper, x: 0.68, y: 0.68, size: 0.28, flip: true)], heroX: 0.34),
      ),
      (
        // Qui il protagonista sta a metà frase: niente maiuscola.
        text: l.factoryEnding(part(FactoryStep.ending), l.factoryWhoThe(who)),
        scene: scene([
          SceneItem(emoji: helper, x: 0.66, y: 0.68, size: 0.28, flip: true),
          SceneItem(emoji: emoji(FactoryStep.ending), x: 0.5, y: 0.22, size: 0.22),
        ], heroX: 0.36),
      ),
    ];
  }

  Map<String, Object?> toRow() => {
        if (id != 0) 'id': id,
        'profile_id': profileId,
        'title': title,
        // Una colonna per scelta, con il nome del passo (`place`, non `where`, che in SQL è riservata).
        for (final s in FactoryStep.values) s.name: parts[s],
        'at': when.toIso8601String(),
      };

  factory MadeStory.fromRow(Map<String, Object?> r) => MadeStory(
        id: r['id'] as int,
        profileId: r['profile_id'] as int,
        title: r['title'] as String?,
        parts: {for (final s in FactoryStep.values) s: r[s.name] as String},
        when: DateTime.parse(r['at'] as String),
      );
}
