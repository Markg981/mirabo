import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/shelf.dart';
import '../design/palette.dart';

/// Come si presenta una capacità nella barra in basso e sulla mensola.
/// Il bambino la riconosce dall'emoji e dal colore, non dal nome.
extension CapacityStyle on Capacity {
  String get emoji => switch (this) {
        Capacity.insieme => '🤝',
        Capacity.mani => '🧺',
        Capacity.sensi => '🖐️',
        Capacity.parole => '✏️',
        Capacity.pensare => '🔢',
        Capacity.mondo => '🌍',
      };

  Color get color => switch (this) {
        Capacity.insieme => MiraboColors.rose,
        Capacity.mani => MiraboColors.leaf,
        Capacity.sensi => MiraboColors.plum,
        Capacity.parole => MiraboColors.indigo,
        Capacity.pensare => MiraboColors.apricot,
        Capacity.mondo => MiraboColors.cyan,
      };

  String label(AppLocalizations l) => l.capacityLabel(name);
}
