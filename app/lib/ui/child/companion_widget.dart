import 'package:flutter/material.dart';

import '../../content/story_repository.dart';
import '../../models/story.dart';

/// Il compagno del bambino. Finché non ci sono le illustrazioni, è un
/// segnaposto colorato che cambia con lo stadio di crescita.
class CompanionWidget extends StatelessWidget {
  const CompanionWidget({super.key, required this.companion, required this.stage, this.size = 120});

  final Companion companion;
  final int stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = switch (companion.id) {
      CompanionId.bo => const Color(0xFF8D6E63),
      CompanionId.pilu => const Color(0xFF90A4AE),
      CompanionId.tango => const Color(0xFFFF8A65),
    };
    final icon = switch (companion.id) {
      CompanionId.bo => Icons.cruelty_free_rounded,
      CompanionId.pilu => Icons.nightlight_round,
      CompanionId.tango => Icons.pets_rounded,
    };
    return Semantics(
      label: '${companion.name}, ${companion.kind}. ${companion.growth[stage]}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2 + stage * 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3 + stage.toDouble()),
        ),
        child: Icon(icon, size: size * 0.5, color: color),
      ),
    );
  }
}
