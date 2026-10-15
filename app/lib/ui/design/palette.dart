import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../models/profile.dart';
import '../../models/story.dart';

/// Colori di Mirabò. Primari pieni e luminosi come i materiali Montessori
/// (cielo ciano, giallo sole, rosso, verde), inchiostro blu notte invece del
/// nero, oggetti "solidi" con il bordo inferiore più scuro.
abstract final class MiraboColors {
  static const ink = Color(0xFF0E2A47);
  static const inkSoft = Color(0xFF4F6580);
  static const navy = Color(0xFF0B4A7A);
  static const cream = Color(0xFFF4FBFF);
  static const paper = Color(0xFFFFFFFF);
  static const line = Color(0xFFDCE8F2);
  static const disabled = Color(0xFFD5DEE6);
  static const skyTop = Color(0xFF2ED3F5);
  static const skyBottom = Color(0xFFA5EEFB);

  static const apricot = Color(0xFFFF7A1A);
  static const teal = Color(0xFF12B5A2);
  static const plum = Color(0xFF8B5CF6);
  static const sky = Color(0xFF1E88E5);
  static const leaf = Color(0xFF2DB34A);
  static const rose = Color(0xFFEF3B4F);
  static const sun = Color(0xFFFFC21A);
  static const indigo = Color(0xFF4F5BD5);
  static const cyan = Color(0xFF06B6D4);

  /// Tono più scuro dello stesso colore: bordo inferiore dei bottoni "a rilievo".
  static Color deep(Color c, [double amount = 0.22]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Tono chiaro per sfondi e superfici colorate.
  static Color pale(Color c, [double amount = 0.82]) => Color.lerp(c, paper, amount)!;

  /// Contrasto tra due colori opachi secondo WCAG 2.x, da 1 a 21.
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Riferimento di progetto (WCAG 1.4.3): 4,5:1 per il testo normale, 3:1 per
  /// il testo grande (almeno 24 px, o 18,67 px in grassetto). docs/accessibility.md.
  static const minContrast = 4.5;
  static const minContrastLarge = 3.0;

  /// Il testo da mettere su [bg]: bianco se basta, altrimenti quello fra bianco
  /// e inchiostro che si legge meglio (giallo, verde, arancio, ciano: inchiostro).
  static Color onColor(Color bg, {bool large = false}) {
    final white = contrast(paper, bg);
    if (white >= (large ? minContrastLarge : minContrast)) return paper;
    return contrast(ink, bg) > white ? ink : paper;
  }

  /// Fondo e testo per una selezione con scritte normali: il colore resta se
  /// bianco o inchiostro ci arrivano a 4,5:1, altrimenti si scurisce.
  static ({Color bg, Color fg}) readable(Color c) {
    final fg = onColor(c);
    if (contrast(fg, c) >= minContrast) return (bg: c, fg: fg);
    return (bg: forWhiteText(c), fg: paper);
  }

  /// [bg] scurito quanto basta perché il testo bianco normale arrivi a 4,5:1:
  /// per le selezioni che portano scritte piccole.
  static Color forWhiteText(Color bg) {
    var c = bg;
    for (var i = 0; i < 30 && contrast(paper, c) < minContrast; i++) {
      c = deep(c, 0.02);
    }
    return c;
  }
}

/// Il mondo di una storia: nome breve, icona, colore.
({String label, IconData icon, Color color}) worldStyle(World w) => switch (w) {
      World.emozioni => (label: 'Emozioni', icon: Icons.favorite_rounded, color: MiraboColors.rose),
      World.inclusione => (label: 'Insieme', icon: Icons.diversity_1_rounded, color: MiraboColors.sky),
      World.ambiente => (label: 'Il bosco', icon: Icons.park_rounded, color: MiraboColors.leaf),
      World.sicurezza => (label: 'Il mio corpo', icon: Icons.shield_rounded, color: MiraboColors.sun),
    };

Color areaColor(ActivityArea a) => switch (a) {
      ActivityArea.cognitivo => MiraboColors.plum,
      ActivityArea.autonomia => MiraboColors.teal,
      ActivityArea.sociale => MiraboColors.sky,
      ActivityArea.paure => MiraboColors.sun,
      ActivityArea.vitaPratica => MiraboColors.leaf,
      ActivityArea.sensoriale => MiraboColors.rose,
      ActivityArea.linguaggio => MiraboColors.indigo,
      ActivityArea.matematica => MiraboColors.apricot,
      ActivityArea.cultura => MiraboColors.cyan,
    };

/// Come compare il testo, dall'asse lettura del profilo di interazione.
enum TextMode {
  /// Niente testo: solo la voce. Bottoni e tessere senza scritta.
  hidden,

  /// Solo la frase-chiave della storia.
  keyword,

  /// Testo con la parola letta che si illumina, sempre.
  karaoke,

  /// Testo pieno; il karaoke lo decide il genitore.
  full;

  bool get showsText => this == karaoke || this == full;
  bool get showsLabels => this != hidden;
}

/// Valori di design che dipendono dal profilo: bassa stimolazione e profilo di
/// interazione (mani, lettura, autonomia). Si legge con `MiraboTokens.of(context)`.
/// I valori di default sono quelli senza adattamenti (tutti gli assi al massimo).
@immutable
class MiraboTokens extends ThemeExtension<MiraboTokens> {
  const MiraboTokens({
    required this.lowStimulation,
    this.minTarget = 56,
    this.snapTolerance = 0.08,
    this.maxOptions = 4,
    this.textMode = TextMode.full,
    this.repeatPrompt = false,
    this.confirmExit = false,
    this.voiceMissing = false,
  });

  /// Con [voiceMissing] il dispositivo non ha la voce di sistema per la lingua
  /// del bambino: il testo si mostra comunque, perché un adulto possa leggerlo
  /// con lui (docs/child-paths.md, "Errori").
  factory MiraboTokens.forProfile({required bool lowStimulation, required InteractionProfile interaction, bool voiceMissing = false}) {
    final hands = interaction.hands - 1;
    final autonomy = interaction.autonomy - 1;
    return MiraboTokens(
      lowStimulation: lowStimulation,
      minTarget: const [88.0, 72.0, 56.0][hands],
      snapTolerance: const [0.16, 0.12, 0.08][hands],
      maxOptions: const [2, 3, 4][autonomy],
      textMode: switch (interaction.reading) {
        _ when voiceMissing => TextMode.full,
        ReadingLevel.none => TextMode.hidden,
        ReadingLevel.letters => TextMode.keyword,
        ReadingLevel.words => TextMode.karaoke,
        ReadingLevel.fluent => TextMode.full,
      },
      repeatPrompt: interaction.autonomy == 1,
      confirmExit: interaction.autonomy < 3,
      voiceMissing: voiceMissing,
    );
  }

  final bool lowStimulation;

  /// Lato minimo di ogni cosa da toccare, in dp (mani 1/2/3: 88/72/56).
  final double minTarget;

  /// Tolleranza dei tracciati, in frazione del riquadro: più larga per chi ha
  /// la mano meno precisa, stretta per il tracciato preciso.
  final double snapTolerance;

  /// Opzioni al massimo per round nelle attività (autonomia 1/2/3: 2/3/4).
  final int maxOptions;
  final TextMode textMode;

  /// Autonomia 1: la consegna del round si ripete da sola se il bambino non
  /// tocca niente; altrimenti la ripete solo il tasto "riascolta".
  final bool repeatPrompt;

  /// Autonomia 1 e 2: uscire da una storia o da un'attività chiede conferma.
  final bool confirmExit;

  /// Manca la voce di sistema per la lingua del bambino.
  final bool voiceMissing;

  static MiraboTokens of(BuildContext context) =>
      Theme.of(context).extension<MiraboTokens>() ?? const MiraboTokens(lowStimulation: false);

  /// In bassa stimolazione i colori d'accento perdono saturazione.
  Color tint(Color c) {
    if (!lowStimulation) return c;
    final hsl = HSLColor.fromColor(c);
    return hsl.withSaturation(hsl.saturation * 0.35).withLightness((hsl.lightness * 0.9 + 0.08).clamp(0, 1)).toColor();
  }

  bool get animate => !lowStimulation;

  /// Quante volte la consegna si ripete da sola (autonomia 1) se il bambino non
  /// tocca niente: in bassa stimolazione una sola, perché anche la voce che
  /// ritorna è uno stimolo.
  int get maxPromptRepeats => lowStimulation ? 1 : 2;

  /// Le stesse scelte d'aspetto, ma senza adattamenti: per le pagine dei grandi.
  MiraboTokens get adult => MiraboTokens(lowStimulation: lowStimulation);

  @override
  MiraboTokens copyWith({
    bool? lowStimulation,
    double? minTarget,
    double? snapTolerance,
    int? maxOptions,
    TextMode? textMode,
    bool? repeatPrompt,
    bool? confirmExit,
    bool? voiceMissing,
  }) =>
      MiraboTokens(
        lowStimulation: lowStimulation ?? this.lowStimulation,
        minTarget: minTarget ?? this.minTarget,
        snapTolerance: snapTolerance ?? this.snapTolerance,
        maxOptions: maxOptions ?? this.maxOptions,
        textMode: textMode ?? this.textMode,
        repeatPrompt: repeatPrompt ?? this.repeatPrompt,
        confirmExit: confirmExit ?? this.confirmExit,
        voiceMissing: voiceMissing ?? this.voiceMissing,
      );

  @override
  MiraboTokens lerp(MiraboTokens? other, double t) => t < 0.5 ? this : (other ?? this);
}
