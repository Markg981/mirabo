import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../games/game.dart';
import '../../games/game_shell.dart';
import '../../models/profile.dart';
import '../activity/activity_player.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import '../parent/adult_gate.dart';
import '../parent/parent_area.dart';
import 'categories.dart';
import 'category_widgets.dart';
import 'nature_calendar.dart';
import 'story_factory.dart';
import 'story_reader.dart';

/// Le categorie che hanno almeno un contenuto per questo profilo.
List<ChildCategory> visibleCategories(AppState state, ChildProfile profile) {
  final activities = state.activitiesFor(profile);
  return [
    for (final c in ChildCategory.all())
      if (switch (c.kind) {
        CategoryKind.stories => state.storiesFor(profile).isNotEmpty,
        CategoryKind.games => gamesFor(profile.ageBand).isNotEmpty,
        CategoryKind.make => true,
        CategoryKind.area => activities.any((a) => a.area == c.area),
      })
        c,
  ];
}

void openParentArea(BuildContext context) => AdultGate.open(
      context,
      then: () => Navigator.of(context).push(adultRoute((_) => const ParentArea())),
    );

/// Una categoria: carte grandi che scorrono in orizzontale, la barra delle
/// categorie in basso per cambiare senza tornare alla casa.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.initial});
  final ChildCategory initial;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late ChildCategory _category = widget.initial;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _select(ChildCategory c) {
    if (c == _category) return;
    setState(() => _category = c);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _open(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  List<Widget> _cards(AppState state, ChildProfile profile, double width) {
    final l = context.l10n;
    switch (_category.kind) {
      case CategoryKind.stories:
        return [
          for (final s in state.storiesFor(profile))
            BigCard(
              title: s.title,
              color: worldStyle(s.world).color,
              icon: worldStyle(s.world).icon,
              width: width,
              onTap: () => _open(StoryReader(story: s)),
            ),
        ];
      case CategoryKind.games:
        return [
          for (final g in gamesFor(profile.ageBand))
            BigCard(
              title: g.title(l),
              color: g.color,
              emojis: g.emojis,
              width: width,
              onTap: () => _open(GameShell(game: g)),
            ),
        ];
      case CategoryKind.make:
        return [
          BigCard(
            title: l.factoryTitle,
            color: MiraboColors.plum,
            emojis: const ['🐉', '✨', '📖'],
            width: width,
            onTap: () => _open(const StoryFactoryScreen()),
          ),
          BigCard(
            title: l.natureTitle,
            color: MiraboColors.leaf,
            emojis: const ['☀️', '🍂', '🐞'],
            width: width,
            onTap: () => _open(const NatureCalendar()),
          ),
        ];
      case CategoryKind.area:
        return [
          for (final a in state.activitiesFor(profile).where((a) => a.area == _category.area))
            BigCard(
              title: a.title,
              color: _category.color,
              emojis: a.coverEmojis,
              icon: a.coverEmojis.isEmpty ? Icons.extension_rounded : null,
              width: width,
              badges: [
                if (a.isHome) (Icons.home_rounded, l.badgeAtHome),
                if (!a.isHome && a.togetherSuggested) (Icons.people_rounded, l.badgeTogether),
              ],
              onTap: () => _open(ActivityPlayer(activity: a)),
            ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final categories = visibleCategories(state, profile);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // Barra in alto: casa, titolo, area genitori
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: softShadow(),
                ),
                child: Row(
                  children: [
                    _CircleAction(
                      icon: Icons.home_rounded,
                      tooltip: context.l10n.home,
                      color: MiraboColors.sky,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_category.emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _category.label(context.l10n),
                              style: text.headlineMedium?.copyWith(color: MiraboColors.navy),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _CircleAction(
                      icon: Icons.lock_rounded,
                      tooltip: context.l10n.parentArea,
                      color: MiraboColors.sun,
                      onTap: () => openParentArea(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  final cardH = c.maxHeight - 48;
                  final cardW = (cardH * 0.82).clamp(260.0, 380.0);
                  final cards = _cards(state, profile, cardW);
                  if (cards.isEmpty) {
                    return Center(child: SoftPanel(child: Text(context.l10n.catEmpty, style: text.titleLarge)));
                  }
                  return ListView.separated(
                    key: ValueKey(_category),
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                    itemCount: cards.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 22),
                    itemBuilder: (_, i) => cards[i],
                  );
                }),
              ),
              CategoryDock(categories: categories, selected: _category, onSelect: _select),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.tooltip, required this.color, required this.onTap});
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = MiraboTokens.of(context).tint(color);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 60, height: 60, child: Icon(icon, color: Colors.white, size: 32)),
        ),
      ),
    );
  }
}
