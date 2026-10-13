import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/shelf.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'categories.dart';

/// Barra in basso con le capacità che hanno qualcosa sulla mensola: bottoni
/// rotondi colorati con un'emoji. Quella scelta si alza e prende l'anello blu.
class CategoryDock extends StatelessWidget {
  const CategoryDock({super.key, required this.categories, required this.onSelect, this.selected});
  final List<Capacity> categories;
  final Capacity? selected;
  final ValueChanged<Capacity> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(40),
        boxShadow: softShadow(1.2),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in categories)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: _DockButton(category: c, selected: c == selected, onTap: () => onSelect(c)),
              ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({required this.category, required this.selected, required this.onTap});
  final Capacity category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    final c = tokens.tint(category.color);
    final size = selected ? 82.0 : 72.0;
    return Tooltip(
      message: category.label(context.l10n),
      child: Semantics(
        button: true,
        selected: selected,
        label: category.label(context.l10n),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Duration(milliseconds: tokens.animate ? 180 : 0),
            curve: Curves.easeOutBack,
            width: size,
            height: size,
            transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(color: selected ? tokens.tint(MiraboColors.navy) : Colors.white, width: selected ? 5 : 4),
              boxShadow: [BoxShadow(color: MiraboColors.deep(c, 0.15), offset: const Offset(0, 5))],
            ),
            alignment: Alignment.center,
            child: Text(category.emoji, style: TextStyle(fontSize: size * 0.46, height: 1.1)),
          ),
        ),
      ),
    );
  }
}

/// Carta grande di una categoria: titolo in alto, illustrazione sotto.
/// L'illustrazione è un'icona bianca o fino a tre emoji disposte a mano.
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
    this.emojis = const [],
    this.icon,
    this.badges = const [],
    this.width = 320,
  });

  final String title;
  final Color color;
  final VoidCallback onTap;
  final List<String> emojis;
  final IconData? icon;
  final List<(IconData, String)> badges;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = MiraboTokens.of(context).tint(color);
    final text = Theme.of(context).textTheme;
    return BlockTile(
      onTap: onTap,
      width: width,
      color: c,
      radius: 30,
      depth: 10,
      semanticLabel: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              title.toUpperCase(),
              style: text.titleLarge?.copyWith(color: Colors.white, fontSize: 21, letterSpacing: 0.6),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: Color.lerp(c, Colors.white, 0.28),
                borderRadius: BorderRadius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(builder: (context, box) {
                final s = box.biggest.shortestSide;
                return Stack(
                  children: [
                    Positioned(right: -s * 0.2, top: -s * 0.2, child: _disc(s * 0.7, 0.18)),
                    Positioned(left: -s * 0.25, bottom: -s * 0.3, child: _disc(s * 0.8, 0.14)),
                    Positioned(left: s * 0.1, top: s * 0.1, child: _disc(s * 0.06, 0.6)),
                    if (icon != null)
                      Center(child: Icon(icon, size: s * 0.5, color: Colors.white))
                    else ...[
                      if (emojis.length > 1)
                        Positioned(right: s * 0.08, top: s * 0.08, child: _emoji(emojis[1], s * 0.22, 0.25)),
                      if (emojis.length > 2)
                        Positioned(left: s * 0.08, bottom: s * 0.14, child: _emoji(emojis[2], s * 0.22, -0.25)),
                      if (emojis.isNotEmpty) Center(child: _emoji(emojis[0], s * 0.42, 0)),
                    ],
                    if (badges.isNotEmpty)
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Row(children: [
                          for (final (i, label) in badges)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                                child: Row(children: [
                                  Icon(i, size: 18, color: MiraboColors.navy),
                                  const SizedBox(width: 4),
                                  Text(label, style: text.labelMedium?.copyWith(color: MiraboColors.navy)),
                                ]),
                              ),
                            ),
                        ]),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _disc(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: alpha), shape: BoxShape.circle),
      );

  Widget _emoji(String e, double size, double angle) =>
      Transform.rotate(angle: angle, child: Text(e, style: TextStyle(fontSize: size, height: 1.1)));
}
