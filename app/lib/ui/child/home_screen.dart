import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/activity.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../activity/activity_player.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import '../parent/adult_gate.dart';
import '../parent/parent_area.dart';
import 'companion_widget.dart';
import 'story_reader.dart';

/// Home del bambino: il compagno nella sua casa, le tre sezioni, le carte.
/// Nessun testo di configurazione; il genitore entra dal lucchetto sull'insegna.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _section = 0; // 0 storie, 1 verso la scuola, 2 montessori

  static const _sections = [
    (label: 'Le storie', icon: Icons.auto_stories_rounded, color: MiraboColors.rose),
    (label: 'Verso la scuola', icon: Icons.backpack_rounded, color: MiraboColors.sky),
    (label: 'Montessori', icon: Icons.back_hand_rounded, color: MiraboColors.leaf),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final companion = state.companionOf(profile);
    final stories = state.storiesFor(profile);
    final activities = state.activitiesFor(profile, module: ActivityModule.scuola);
    final montessori = state.activitiesFor(profile, module: ActivityModule.montessori);
    final section = _sections[_section];

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 290,
                  child: Column(
                    children: [
                      _CompanionCorner(
                        greeting: 'Ciao ${profile.name}!',
                        name: companion.name,
                        child: CompanionWidget(
                          companion: companion,
                          stage: profile.companionStage,
                          size: 200,
                          withHome: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (var i = 0; i < _sections.length; i++) ...[
                        _SectionTab(
                          icon: _sections[i].icon,
                          label: _sections[i].label,
                          color: _sections[i].color,
                          selected: _section == i,
                          onTap: () => setState(() => _section = i),
                        ),
                        const SizedBox(height: 6),
                      ],
                      const Spacer(),
                      _ModeChip(mode: state.mode),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TitleBanner(
                        title: section.label,
                        leading: Icon(section.icon, color: MiraboColors.sun, size: 40),
                        trailing: RoundIconButton(
                          icon: Icons.lock_rounded,
                          tooltip: 'Area genitori',
                          size: 52,
                          color: MiraboColors.navy,
                          onPressed: () => AdultGate.open(
                            context,
                            then: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParentArea())),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: switch (_section) {
                          0 => _StoriesGrid(stories: stories),
                          1 => _ActivitiesGrid(activities: activities),
                          _ => _ActivitiesGrid(activities: montessori),
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Il compagno nella sua casa, con il fumetto di saluto.
class _CompanionCorner extends StatelessWidget {
  const _CompanionCorner({required this.greeting, required this.name, required this.child});
  final String greeting;
  final String name;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SoftPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      radius: 32,
      child: Column(
        children: [
          SpeechBubble(
            tail: TailSide.bottom,
            tailAt: 0.55,
            color: MiraboTokens.of(context).tint(MiraboColors.sun),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text(greeting, style: text.titleLarge, textAlign: TextAlign.center, maxLines: 2),
          ),
          child,
          Text(name, style: text.headlineSmall?.copyWith(color: MiraboColors.navy)),
        ],
      ),
    );
  }
}

class _SectionTab extends StatelessWidget {
  const _SectionTab({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = MiraboTokens.of(context).tint(color);
    final fg = selected ? Colors.white : MiraboColors.ink;
    return BlockTile(
      onTap: onTap,
      color: selected ? c : MiraboColors.paper,
      radius: 22,
      depth: 6,
      semanticLabel: label,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? Colors.white.withValues(alpha: 0.25) : c,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: fg, fontSize: 22)),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: SoftPanel(child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
      );
}

class _StoriesGrid extends StatelessWidget {
  const _StoriesGrid({required this.stories});
  final List<Story> stories;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const _EmptyHint('Nessuna storia per oggi.');
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 290,
        mainAxisSpacing: 18,
        crossAxisSpacing: 20,
        childAspectRatio: 0.92,
      ),
      itemCount: stories.length,
      itemBuilder: (context, i) => _StoryCard(
        story: stories[i],
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryReader(story: stories[i]))),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, required this.onTap});
  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = worldStyle(story.world);
    final c = MiraboTokens.of(context).tint(world.color);
    final text = Theme.of(context).textTheme;
    return BlockTile(
      onTap: onTap,
      color: c,
      semanticLabel: 'Storia: ${story.title}, mondo ${world.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(right: -26, top: -30, child: _Disc(130, Colors.white.withValues(alpha: 0.16))),
                Positioned(left: -34, bottom: -50, child: _Disc(150, Colors.white.withValues(alpha: 0.12))),
                Positioned(left: 18, top: 16, child: _Disc(14, Colors.white.withValues(alpha: 0.5))),
                Center(child: Icon(world.icon, size: 92, color: Colors.white)),
              ],
            ),
          ),
          Container(
            color: MiraboColors.paper,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story.title, style: text.titleLarge?.copyWith(fontSize: 22), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  _Disc(10, c),
                  const SizedBox(width: 8),
                  Text(world.label, style: text.labelMedium?.copyWith(color: MiraboColors.inkSoft)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc(this.size, this.color);
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

/// Le attività raggruppate per area, con il colore dell'area.
class _ActivitiesGrid extends StatelessWidget {
  const _ActivitiesGrid({required this.activities});
  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const _EmptyHint('Nessuna attività per oggi.');
    final tokens = MiraboTokens.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        for (final area in ActivityArea.values)
          if (activities.any((a) => a.area == area)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: tokens.tint(areaColor(area)),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: MiraboColors.deep(tokens.tint(areaColor(area)), 0.14), offset: const Offset(0, 4))],
                  ),
                  child: Text(area.label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 21)),
                ),
              ),
            ),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                for (final a in activities.where((a) => a.area == area))
                  _ActivityCard(
                    activity: a,
                    color: tokens.tint(areaColor(area)),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ActivityPlayer(activity: a))),
                  ),
              ],
            ),
          ],
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.color, required this.onTap});
  final Activity activity;
  final Color color;
  final VoidCallback onTap;

  static const _icons = {
    ActivityType.tapMatch: Icons.touch_app_rounded,
    ActivityType.count: Icons.pin_rounded,
    ActivityType.sequence: Icons.swap_horiz_rounded,
    ActivityType.pattern: Icons.pattern_rounded,
    ActivityType.trace: Icons.gesture_rounded,
    ActivityType.checklist: Icons.checklist_rounded,
    ActivityType.sceneChoice: Icons.forum_rounded,
    ActivityType.explore: Icons.explore_rounded,
    ActivityType.countdown: Icons.calendar_month_rounded,
    ActivityType.presentation: Icons.back_hand_rounded,
    ActivityType.pairs: Icons.join_inner_rounded,
    ActivityType.spell: Icons.abc_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final emoji = activity.coverEmoji;
    return BlockTile(
      onTap: onTap,
      width: 228,
      height: 168,
      radius: 26,
      padding: const EdgeInsets.all(16),
      semanticLabel: 'Attività: ${activity.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: emoji == null ? color : MiraboColors.pale(color, 0.72),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: MiraboColors.deep(color, emoji == null ? 0.14 : 0.02), offset: const Offset(0, 4))],
                ),
                child: emoji == null
                    ? Icon(_icons[activity.type], size: 36, color: Colors.white)
                    : Text(emoji, style: const TextStyle(fontSize: 36, height: 1.1)),
              ),
              const Spacer(),
              if (activity.isHome)
                const Icon(Icons.home_rounded, size: 26, color: MiraboColors.inkSoft)
              else if (activity.togetherSuggested)
                const Icon(Icons.people_rounded, size: 26, color: MiraboColors.inkSoft),
            ],
          ),
          const Spacer(),
          Text(
            activity.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 21),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final together = mode == SessionMode.together;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(together ? Icons.people_rounded : Icons.person_rounded, color: MiraboColors.navy, size: 22),
        const SizedBox(width: 8),
        Text(together ? 'Insieme' : 'Da solo',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: MiraboColors.navy)),
      ]),
    );
  }
}
