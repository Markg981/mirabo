import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/themes.dart';
import '../design/palette.dart';

/// Come si presenta un tema: un colore che resta lo stesso su tutte le sue
/// esperienze, tre immagini e un nome detto dalla voce. Le immagini sono una
/// proposta da verificare con i bambini (content/reviews/temi-bambini.md):
/// un'emoji non è autoesplicativa.
extension ChildThemeStyle on ChildTheme {
  List<String> get emojis => switch (this) {
        ChildTheme.emozioniRelazioni => const ['🤗', '❤️', '🙂'],
        ChildTheme.naturaViventi => const ['🌱', '🐞', '💧'],
        ChildTheme.autonomiaScuola => const ['🎒', '👟', '🪥'],
      };

  Color get color => switch (this) {
        ChildTheme.emozioniRelazioni => MiraboColors.rose,
        ChildTheme.naturaViventi => MiraboColors.leaf,
        ChildTheme.autonomiaScuola => MiraboColors.sun,
      };

  String label(AppLocalizations l) => l.themeLabel(name);
}

/// Le tre modalità hanno la stessa icona in ogni tema.
extension ExperienceModeStyle on ExperienceMode {
  IconData get icon => switch (this) {
        ExperienceMode.story => Icons.auto_stories_rounded,
        ExperienceMode.game => Icons.extension_rounded,
        ExperienceMode.practice => Icons.back_hand_rounded,
      };

  String label(AppLocalizations l) => l.experienceModeLabel(name);
}
