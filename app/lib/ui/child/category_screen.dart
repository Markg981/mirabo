import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../games/game_shell.dart';
import '../../models/shelf.dart';
import '../activity/activity_player.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import '../parent/adult_gate.dart';
import '../parent/parent_area.dart';
import '../parent/screen_secure.dart';
import 'categories.dart';
import 'category_widgets.dart';
import 'child_top_bar.dart';
import 'nature_calendar.dart';
import 'story_factory.dart';
import 'story_reader.dart';

void openParentArea(BuildContext context) => AdultGate.open(
      context,
      then: () => Navigator.of(context).push(adultRoute((_) => const SessionHold(child: AdultGuard(child: ScreenSecure(child: ParentArea()))))),
    );

/// Una capacità della mensola: i suoi pochi materiali come carte grandi, la
/// barra delle capacità in basso per cambiare senza tornare alla casa. La
/// mensola è una scorciatoia: il catalogo completo sta nei temi.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.initial});
  final Capacity initial;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Capacity _category = widget.initial;
  final _scroll = ScrollController();
  final _voice = ShortVoice();

  @override
  void dispose() {
    _scroll.dispose();
    _voice.dispose();
    super.dispose();
  }

  void _select(Capacity c) {
    if (c == _category) return;
    setState(() => _category = c);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _open(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  Widget _card(ShelfItem item, double width) {
    final l = context.l10n;
    return switch (item) {
      StoryItem(:final story) => BigCard(
          title: story.title,
          color: worldStyle(story.world).color,
          icon: worldStyle(story.world).icon,
          width: width,
          onTap: () => _open(SessionHold(child: StoryReader(story: story))),
        ),
      GameItem(:final game) => BigCard(
          title: game.title(l),
          color: game.color,
          emojis: game.emojis,
          width: width,
          onTap: () => _open(SessionHold(child: GameShell(game: game))),
        ),
      ActivityItem(activity: final a) => BigCard(
          title: a.title,
          color: _category.color,
          emojis: a.coverEmojis,
          icon: a.coverEmojis.isEmpty ? Icons.extension_rounded : null,
          width: width,
          badges: [
            if (a.isHome) (Icons.home_rounded, l.badgeAtHome),
            if (!a.isHome && a.togetherSuggested) (Icons.people_rounded, l.badgeTogether),
          ],
          onTap: () => _open(SessionHold(child: ActivityPlayer(activity: a))),
        ),
      MakeItem(tool: MakeTool.factory) => BigCard(
          title: l.factoryTitle,
          color: MiraboColors.plum,
          emojis: const ['🐉', '✨', '📖'],
          width: width,
          onTap: () => _open(const StoryFactoryScreen()),
        ),
      MakeItem(tool: MakeTool.nature) => BigCard(
          title: l.natureTitle,
          color: MiraboColors.leaf,
          emojis: const ['☀️', '🍂', '🐞'],
          width: width,
          onTap: () => _open(const SessionHold(child: NatureCalendar())),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final shelf = state.shelfFor(state.currentProfile!);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // Barra in alto come in tema e storie: a sinistra la casa, a destra il
              // riascolta. L'area genitori si apre dalla casa.
              ChildTopBar(
                exitIcon: Icons.home_rounded,
                exitTooltip: context.l10n.home,
                onExit: () => Navigator.of(context).pop(),
                onListen: () => _voice.say(state.currentProfile!.language, _category.label(context.l10n)),
                title: Row(
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
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  final cardH = c.maxHeight - 48;
                  final cardW = (cardH * 0.82).clamp(260.0, 380.0);
                  // Limite vicino: niente di nuovo da iniziare (storie, attività, giochi).
                  if (state.windingDown) return const Center(child: WinddownNote());
                  final cards = [for (final i in shelf[_category] ?? const <ShelfItem>[]) _card(i, cardW)];
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
              CategoryDock(categories: shelf.keys.toList(), selected: _category, onSelect: _select),
            ],
          ),
        ),
      ),
    );
  }
}
