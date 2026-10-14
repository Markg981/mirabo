import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../models/profile.dart';
import '../../models/shelf.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'categories.dart';
import 'category_screen.dart';
import 'category_widgets.dart';
import 'closing_screen.dart';
import 'companion_widget.dart';

/// Casa del bambino: il compagno nella sua casa che chiede "cosa facciamo
/// oggi?" e, in basso, la mensola divisa per capacità. Ci sono solo i
/// materiali che l'adulto ha preparato, non tutto il catalogo.
/// Nessun testo di configurazione; il genitore entra dal lucchetto.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final companion = state.companionOf(profile);
    final shelf = state.shelfFor(profile);
    final hasStory = shelf[Capacity.insieme]?.any((i) => i is StoryItem) ?? false;
    final text = Theme.of(context).textTheme;

    void open(Capacity c) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryScreen(initial: c)));

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    if (state.profiles.length > 1) ...[
                      _SwitchChild(
                        name: profile.name,
                        avatar: CompanionWidget(companion: companion, stage: profile.companionStage, size: 44),
                        onTap: state.switchChild,
                      ),
                      const SizedBox(width: 12),
                    ],
                    _ModeChip(mode: state.mode),
                    const Spacer(),
                    // "Ho finito" c'è sempre: chiudere è una scelta del bambino.
                    RoundIconButton(
                      icon: Icons.waving_hand_rounded,
                      tooltip: context.l10n.closingA11y,
                      size: 56,
                      color: MiraboColors.navy,
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClosingScreen())),
                    ),
                    const SizedBox(width: 12),
                    RoundIconButton(
                      icon: Icons.lock_rounded,
                      tooltip: context.l10n.parentArea,
                      size: 56,
                      color: MiraboColors.navy,
                      onPressed: () => openParentArea(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  final size = (c.maxHeight * 0.98).clamp(200.0, 400.0);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CompanionWidget(companion: companion, stage: profile.companionStage, size: size, withHome: true),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SpeechBubble(
                                tail: TailSide.left,
                                tailAt: 0.6,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(context.l10n.homeHello(profile.name), style: text.headlineMedium?.copyWith(color: MiraboColors.navy)),
                                    const SizedBox(height: 4),
                                    Text(context.l10n.homeQuestion, style: text.titleLarge),
                                  ],
                                ),
                              ),
                              if (hasStory) ...[
                                const SizedBox(height: 22),
                                ChunkyButton(
                                  label: context.l10n.homeOneStory,
                                  icon: Icons.auto_stories_rounded,
                                  color: Capacity.insieme.color,
                                  onPressed: () => open(Capacity.insieme),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              CategoryDock(categories: shelf.keys.toList(), onSelect: open),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pillola con il compagno e il nome: toccandola si torna a "Chi gioca oggi?".
class _SwitchChild extends StatelessWidget {
  const _SwitchChild({required this.name, required this.avatar, required this.onTap});
  final String name;
  final Widget avatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.switchChildA11y(name),
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 16, 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              avatar,
              const SizedBox(width: 6),
              Text(name, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: MiraboColors.navy)),
              const SizedBox(width: 8),
              const Icon(Icons.swap_horiz_rounded, color: MiraboColors.navy),
            ]),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(together ? Icons.people_rounded : Icons.person_rounded, color: MiraboColors.navy, size: 22),
        const SizedBox(width: 8),
        Text(together ? context.l10n.modeTogether : context.l10n.modeAlone, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: MiraboColors.navy)),
      ]),
    );
  }
}
