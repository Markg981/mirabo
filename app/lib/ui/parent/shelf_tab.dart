import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../models/profile.dart';
import '../../models/shelf.dart';
import '../child/categories.dart';
import '../design/palette.dart';
import '../design/widgets.dart';

/// Il genitore prepara la mensola del bambino: per ogni capacità sceglie i
/// pochi materiali che il bambino troverà nella casa. Finché non tocca nulla
/// la mensola si riempie da sola.
class ShelfTab extends StatelessWidget {
  const ShelfTab({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final l = context.l10n;
        final text = Theme.of(context).textTheme;
        final profile = state.currentProfile!;
        // Tutto ciò che il bambino può aprire insieme all'adulto: da solo
        // alcune storie restano nascoste anche se sono sulla mensola.
        final candidates = state.shelfCandidates(profile, mode: SessionMode.together);
        final shelf = state.shelfFor(profile, mode: SessionMode.together);
        final onShelf = Shelf.keysOf(shelf).toSet();
        final size = Shelf.size(profile.ageBand);

        void tell(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

        Future<void> toggle(ShelfItem item) async {
          final keys = Shelf.keysOf(shelf);
          if (onShelf.contains(item.key)) {
            keys.remove(item.key);
          } else if (keys.length >= size) {
            return tell(l.shelfFull(size));
          } else if ((shelf[item.capacity]?.length ?? 0) >= Shelf.maxPerCapacity) {
            return tell(l.shelfCapacityFull(Shelf.maxPerCapacity));
          } else {
            keys.add(item.key);
          }
          await state.setShelf(profile, keys);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            SoftPanel(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.shelfTitle(profile.name), style: text.titleLarge?.copyWith(color: MiraboColors.navy)),
                  const SizedBox(height: 6),
                  Text(l.shelfHint(profile.name, size, Shelf.maxPerCapacity),
                      style: text.bodyMedium?.copyWith(color: MiraboColors.inkSoft)),
                  const SizedBox(height: 10),
                  Text(l.shelfTotal(onShelf.length, size), style: text.titleSmall?.copyWith(color: MiraboColors.navy)),
                  const SizedBox(height: 14),
                  if (profile.shelf == null) ...[
                    Row(children: [
                      const Icon(Icons.auto_awesome_rounded, color: MiraboColors.teal),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l.shelfAutoHint, style: text.bodyMedium)),
                    ]),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.autorenew_rounded),
                      label: Text(l.shelfRotateNow),
                      onPressed: () async {
                        await state.rotateShelf(profile, force: true);
                        if (context.mounted) tell(l.shelfRotated);
                      },
                    ),
                  ] else
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: Text(l.shelfAuto),
                      onPressed: () async {
                        await state.setShelf(profile, null);
                        if (context.mounted) tell(l.shelfAutoOn);
                      },
                    ),
                ],
              ),
            ),
            for (final c in Capacity.values)
              if (candidates.any((i) => i.capacity == c)) ...[
                const SizedBox(height: 16),
                _CapacityShelf(
                  capacity: c,
                  items: candidates.where((i) => i.capacity == c).toList(),
                  onShelf: onShelf,
                  onToggle: toggle,
                ),
              ],
          ],
        );
      },
    );
  }
}

class _CapacityShelf extends StatelessWidget {
  const _CapacityShelf({required this.capacity, required this.items, required this.onShelf, required this.onToggle});
  final Capacity capacity;
  final List<ShelfItem> items;
  final Set<String> onShelf;
  final ValueChanged<ShelfItem> onToggle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final count = items.where((i) => onShelf.contains(i.key)).length;
    return SoftPanel(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(capacity.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(child: Text(capacity.label(l), style: text.titleMedium?.copyWith(color: MiraboColors.navy))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: MiraboColors.pale(capacity.color), borderRadius: BorderRadius.circular(999)),
              child: Text(l.shelfCount(count, Shelf.maxPerCapacity), style: text.labelMedium?.copyWith(color: MiraboColors.navy)),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in items)
                FilterChip(
                  avatar: Icon(_icon(i), size: 18),
                  label: Text(_title(i, l)),
                  tooltip: _kind(i, l),
                  selected: onShelf.contains(i.key),
                  selectedColor: MiraboColors.pale(capacity.color, 0.7),
                  onSelected: (_) => onToggle(i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _title(ShelfItem i, AppLocalizations l) => switch (i) {
        StoryItem(:final story) => story.title,
        GameItem(:final game) => game.title(l),
        ActivityItem(:final activity) => activity.title,
        MakeItem(tool: MakeTool.factory) => l.factoryTitle,
        MakeItem(tool: MakeTool.nature) => l.natureTitle,
      };

  static String _kind(ShelfItem i, AppLocalizations l) => switch (i) {
        StoryItem() => l.shelfKindStory,
        GameItem() => l.shelfKindGame,
        ActivityItem(:final activity) => activity.isHome ? l.badgeAtHome : l.shelfKindActivity,
        MakeItem() => l.catMake,
      };

  static IconData _icon(ShelfItem i) => switch (i) {
        StoryItem() => Icons.auto_stories_rounded,
        GameItem() => Icons.sports_esports_rounded,
        ActivityItem(:final activity) => activity.isHome ? Icons.home_rounded : Icons.extension_rounded,
        MakeItem(tool: MakeTool.factory) => Icons.auto_fix_high_rounded,
        MakeItem(tool: MakeTool.nature) => Icons.wb_sunny_rounded,
      };
}
