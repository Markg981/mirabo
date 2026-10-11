import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/activity.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../activity/activity_player.dart';
import '../parent/adult_gate.dart';
import '../parent/parent_area.dart';
import 'companion_widget.dart';
import 'story_reader.dart';

/// Home del bambino: il compagno, i mondi, le storie disponibili.
/// Nessun testo di configurazione; il genitore entra dal gate in alto a destra.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _section = 0; // 0 storie, 1 verso la scuola

  static const _worldLabels = {
    World.emozioni: ('Emozioni', Icons.favorite_rounded, Color(0xFFE57373)),
    World.inclusione: ('Insieme', Icons.groups_rounded, Color(0xFF64B5F6)),
    World.ambiente: ('Il bosco', Icons.park_rounded, Color(0xFF81C784)),
    World.sicurezza: ('Il mio corpo', Icons.shield_rounded, Color(0xFFFFB74D)),
  };

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final companion = state.companionOf(profile);
    final stories = state.storiesFor(profile);
    final activities = state.activitiesFor(profile);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  CompanionWidget(companion: companion, stage: profile.companionStage, size: 220),
                  const SizedBox(height: 8),
                  Text(companion.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Ciao ${profile.name}!', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  _SectionButton(
                    icon: Icons.auto_stories_rounded,
                    label: 'Le storie',
                    selected: _section == 0,
                    onTap: () => setState(() => _section = 0),
                  ),
                  const SizedBox(height: 8),
                  _SectionButton(
                    icon: Icons.school_rounded,
                    label: 'Verso la scuola',
                    selected: _section == 1,
                    onTap: () => setState(() => _section = 1),
                  ),
                  const Spacer(),
                  _ModeChip(mode: state.mode),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 12, 0),
                    child: Row(
                      children: [
                        Text(_section == 0 ? 'Le storie' : 'Verso la scuola',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Area genitori',
                          icon: const Icon(Icons.lock_outline_rounded, size: 28),
                          onPressed: () => AdultGate.open(context, then: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ParentArea()),
                              )),
                        ),
                      ],
                    ),
                  ),
                  if (_section == 1)
                    Expanded(child: _ActivitiesGrid(activities: activities))
                  else
                  Expanded(
                    child: stories.isEmpty
                        ? Center(child: Text('Nessuna storia per oggi.', style: Theme.of(context).textTheme.bodyLarge))
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: stories.length,
                            itemBuilder: (context, i) => _StoryCard(
                              story: stories[i],
                              worldInfo: _worldLabels[stories[i].world]!,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => StoryReader(story: stories[i])),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, required this.worldInfo, required this.onTap});
  final Story story;
  final (String, IconData, Color) worldInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = worldInfo;
    return Semantics(
      button: true,
      label: 'Storia: ${story.title}, mondo $label',
      child: Material(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 48, color: color.withValues(alpha: 1)),
                const Spacer(),
                Text(story.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 2),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Icon(icon, size: 32),
              const SizedBox(width: 12),
              Text(label, style: Theme.of(context).textTheme.titleLarge),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Le attività raggruppate per area, con il colore dell'area.
class _ActivitiesGrid extends StatelessWidget {
  const _ActivitiesGrid({required this.activities});
  final List<Activity> activities;

  static const _colors = {
    ActivityArea.cognitivo: Color(0xFF9575CD),
    ActivityArea.autonomia: Color(0xFF4DB6AC),
    ActivityArea.sociale: Color(0xFF64B5F6),
    ActivityArea.paure: Color(0xFFFFB74D),
  };

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(child: Text('Nessuna attività per oggi.', style: Theme.of(context).textTheme.bodyLarge));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final area in ActivityArea.values)
          if (activities.any((a) => a.area == area)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(area.label, style: Theme.of(context).textTheme.titleLarge),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final a in activities.where((a) => a.area == area))
                  _ActivityCard(
                    activity: a,
                    color: _colors[area]!,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ActivityPlayer(activity: a)),
                    ),
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
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Attività: ${activity.title}',
      child: Material(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            width: 220,
            height: 150,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(_icons[activity.type], size: 40, color: color),
                  const Spacer(),
                  if (activity.togetherSuggested) const Icon(Icons.people_rounded, size: 22),
                ]),
                const Spacer(),
                Text(activity.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 2),
              ],
            ),
          ),
        ),
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
    return Chip(
      avatar: Icon(together ? Icons.people_rounded : Icons.person_rounded),
      label: Text(together ? 'Insieme' : 'Da solo'),
    );
  }
}
