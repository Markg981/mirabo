import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../parent/adult_gate.dart';
import '../parent/parent_area.dart';
import 'companion_widget.dart';
import 'story_reader.dart';

/// Home del bambino: il compagno, i mondi, le storie disponibili.
/// Nessun testo di configurazione; il genitore entra dal gate in alto a destra.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                        Text('Le storie', style: Theme.of(context).textTheme.headlineMedium),
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
