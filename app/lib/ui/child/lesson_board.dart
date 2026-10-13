import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/story.dart';
import '../../models/three_period_lesson.dart';
import '../design/palette.dart';
import '../design/widgets.dart';

/// La tavola della lezione in tre tempi: le figure in fila, grandi, come gli
/// oggetti sul tappeto Montessori. La figura in primo piano è più grande, le
/// altre si fanno da parte; il nome scritto compare solo quando lo si dice.
class LessonBoard extends StatelessWidget {
  const LessonBoard({
    super.key,
    required this.lesson,
    required this.alt,
    required this.color,
    required this.onTap,
    this.run,
  });

  final Lesson lesson;
  final String alt;
  final Color color;
  final ValueChanged<LessonItem> onTap;

  /// La lezione in corso da solo; null in modalità insieme, dove guida il genitore
  /// e tutte le figure mostrano il nome.
  final LessonRun? run;

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    final focus = run?.focus;
    // Nel terzo tempo si guarda una figura sola.
    final recall = run?.period == LessonPeriod.recall;
    return Semantics(
      label: alt,
      child: Container(
        decoration: BoxDecoration(
          color: MiraboColors.pale(color, 0.82),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white, width: 8),
          boxShadow: [BoxShadow(color: MiraboColors.deep(color, 0.1), offset: const Offset(0, 8)), ...softShadow()],
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: LayoutBuilder(builder: (context, box) {
            // Le figure stanno in una riga sola e, ingrandite, dentro il riquadro.
            final side = min(box.maxWidth / lesson.items.length - 24, box.maxHeight / 1.35).clamp(64.0, 220.0);
            return Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                for (final item in lesson.items)
                  AnimatedOpacity(
                    duration: tokens.animate ? const Duration(milliseconds: 300) : Duration.zero,
                    opacity: recall && focus != item ? 0.25 : 1,
                    child: AnimatedScale(
                      duration: tokens.animate ? const Duration(milliseconds: 300) : Duration.zero,
                      scale: focus == item ? 1.1 : 1,
                      child: _LessonCard(
                        item: item,
                        side: side,
                        showName: run?.showsName(item) ?? true,
                        highlighted: focus == item,
                        color: tokens.tint(color),
                        onTap: () => onTap(item),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.item,
    required this.side,
    required this.showName,
    required this.highlighted,
    required this.color,
    required this.onTap,
  });

  final LessonItem item;
  final double side;
  final bool showName;
  final bool highlighted;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlockTile(
      onTap: onTap,
      width: side,
      height: side * 1.2,
      radius: 26,
      depth: 7,
      border: highlighted ? Border.all(color: color, width: 5) : null,
      // Lo screen reader non legge il nome prima del tempo giusto.
      semanticLabel: showName ? item.name : item.emoji,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.emoji, style: TextStyle(fontSize: side * 0.5)),
          const SizedBox(height: 8),
          // Lo spazio del nome c'è sempre, così la figura non salta quando compare.
          Opacity(
            opacity: showName ? 1 : 0,
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: MiraboColors.ink),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// I tre tempi in fila, con quello di adesso acceso. Non è un punteggio:
/// mostra solo a che punto della lezione si è.
class LessonPeriods extends StatelessWidget {
  const LessonPeriods({super.key, required this.period});
  final LessonPeriod period;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tokens = MiraboTokens.of(context);
    final steps = [
      (LessonPeriod.naming, Icons.visibility_rounded, l.lessonNaming),
      (LessonPeriod.recognition, Icons.touch_app_rounded, l.lessonShow),
      (LessonPeriod.recall, Icons.record_voice_over_rounded, l.lessonTell),
    ];
    return Row(
      children: [
        for (final (p, icon, label) in steps)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Semantics(
                label: label,
                selected: p == period,
                child: AnimatedContainer(
                  duration: tokens.animate ? const Duration(milliseconds: 250) : Duration.zero,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: p == period ? tokens.tint(MiraboColors.sky) : MiraboColors.paper,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 30, color: p == period ? Colors.white : MiraboColors.navy),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
