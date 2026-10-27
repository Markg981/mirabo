import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../models/profile.dart';
import '../../models/themes.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'category_screen.dart';
import 'category_widgets.dart';
import 'closing_screen.dart';
import 'companion_widget.dart';
import 'theme_screen.dart';
import 'themes_style.dart';

/// Casa del bambino: il compagno nella sua casa che chiede "cosa facciamo
/// oggi?", sotto i tre temi e, in basso, la mensola divisa per capacità.
/// I temi sono il catalogo completo della sua fascia, sempre nello stesso
/// ordine; la mensola è una scorciatoia con i pochi materiali che l'adulto ha
/// preparato (o quella automatica della settimana), e non nasconde niente.
/// Nessun testo di configurazione; il genitore entra dal lucchetto.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final companion = state.companionOf(profile);
    final shelf = state.shelfFor(profile);
    final hasThemes = !state.repo.themes.isEmpty;
    final text = Theme.of(context).textTheme;

    void open(Widget page) {
      if (ModalRoute.of(context)?.isCurrent == false) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }

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
                    if (MiraboTokens.of(context).voiceMissing) ...[const SizedBox(width: 12), const _NoVoiceChip()],
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
              if (state.windingDown) const WinddownNote(),
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
                              if (hasThemes) ...[
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    for (final t in ChildTheme.values)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: SizedBox(
                                            height: (size * 0.5).clamp(130.0, 190.0),
                                            child: BigCard(
                                              title: t.label(context.l10n),
                                              color: t.color,
                                              emojis: t.emojis,
                                              onTap: () => open(ThemeScreen(theme: t)),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
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
              CategoryDock(categories: shelf.keys.toList(), onSelect: (c) => open(CategoryScreen(initial: c))),
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
      onTap: onTap,
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

/// Manca la voce di sistema: un pittogramma (voce spenta, un grande con il
/// bambino) dice di chiamare un adulto, senza contare sulla lettura.
class _NoVoiceChip extends StatelessWidget {
  const _NoVoiceChip();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.voiceMissingChild,
      excludeSemantics: true,
      child: Tooltip(
        message: context.l10n.voiceMissingChild,
        child: Container(
          key: const Key('no-voice'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: MiraboColors.pale(MiraboColors.sun, 0.6), borderRadius: BorderRadius.circular(999)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.volume_off_rounded, color: MiraboColors.navy, size: 26),
            SizedBox(width: 6),
            Icon(Icons.family_restroom_rounded, color: MiraboColors.navy, size: 26),
          ]),
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
