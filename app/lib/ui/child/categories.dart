import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/activity.dart';
import '../design/palette.dart';

enum CategoryKind { stories, games, area }

/// Una voce della barra in basso: le storie, i giochi o un'area di attività.
/// Il bambino la riconosce dall'emoji e dal colore, non dal nome.
@immutable
class ChildCategory {
  const ChildCategory._(this.kind, this.emoji, this.color, [this.area]);

  final CategoryKind kind;
  final String emoji;
  final Color color;
  final ActivityArea? area;

  static const stories = ChildCategory._(CategoryKind.stories, '📚', MiraboColors.rose);
  static const games = ChildCategory._(CategoryKind.games, '🎈', MiraboColors.apricot);

  static ChildCategory forArea(ActivityArea a) => ChildCategory._(CategoryKind.area, _areaEmoji[a]!, areaColor(a), a);

  String label(AppLocalizations l) => switch (kind) {
        CategoryKind.stories => l.catStories,
        CategoryKind.games => l.catGames,
        CategoryKind.area => l.areaLabel(area!.name),
      };

  static const _areaEmoji = {
    ActivityArea.cognitivo: '🧠',
    ActivityArea.autonomia: '👟',
    ActivityArea.sociale: '🤝',
    ActivityArea.paure: '🏫',
    ActivityArea.vitaPratica: '🧺',
    ActivityArea.sensoriale: '🖐️',
    ActivityArea.linguaggio: '✏️',
    ActivityArea.matematica: '🔢',
    ActivityArea.cultura: '🌍',
  };

  /// Storie, giochi, poi le aree nell'ordine del modello (scuola, poi Montessori).
  static List<ChildCategory> all() => [stories, games, for (final a in ActivityArea.values) forArea(a)];

  @override
  bool operator ==(Object other) => other is ChildCategory && other.kind == kind && other.area == area;

  @override
  int get hashCode => Object.hash(kind, area);
}
