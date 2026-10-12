import 'package:flutter/material.dart';

import '../../models/activity.dart';
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

/// Valori di design che dipendono dal profilo (bassa stimolazione).
/// Si legge con `MiraboTokens.of(context)`.
@immutable
class MiraboTokens extends ThemeExtension<MiraboTokens> {
  const MiraboTokens({required this.lowStimulation});

  final bool lowStimulation;

  static MiraboTokens of(BuildContext context) =>
      Theme.of(context).extension<MiraboTokens>() ?? const MiraboTokens(lowStimulation: false);

  /// In bassa stimolazione i colori d'accento perdono saturazione.
  Color tint(Color c) {
    if (!lowStimulation) return c;
    final hsl = HSLColor.fromColor(c);
    return hsl.withSaturation(hsl.saturation * 0.35).withLightness((hsl.lightness * 0.9 + 0.08).clamp(0, 1)).toColor();
  }

  bool get animate => !lowStimulation;

  @override
  MiraboTokens copyWith({bool? lowStimulation}) => MiraboTokens(lowStimulation: lowStimulation ?? this.lowStimulation);

  @override
  MiraboTokens lerp(MiraboTokens? other, double t) => t < 0.5 ? this : (other ?? this);
}
