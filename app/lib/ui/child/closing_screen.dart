import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../audio/child_name.dart';
import '../../l10n/l10n.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'child_top_bar.dart';
import 'companion_widget.dart';

/// "Ho finito": il bambino chiude quando vuole, anche senza limite familiare.
/// Una frase breve riconosce quello che ha fatto e lo lascia andare. Niente
/// avvio dell'attività successiva e un compagno sereno, mai triste o
/// bisognoso. Storie e disegni sono già salvati mentre si fanno: tornare è
/// sempre possibile, da qui o riaprendo l'app. La frase si sente, non solo
/// si legge, e il riascolta la ripete.
class ClosingScreen extends StatefulWidget {
  const ClosingScreen({super.key});

  @override
  State<ClosingScreen> createState() => _ClosingScreenState();
}

class _ClosingScreenState extends State<ClosingScreen> {
  final _voice = ShortVoice();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _say());
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  void _say() {
    if (!mounted) return;
    final profile = AppStateScope.read(context).currentProfile!;
    _voice.say(profile.language, '${spokenWithName(context.l10n.closingTitle, profile.name)} ${context.l10n.closingBody}');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final companion = state.companionOf(profile);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(children: [
                  const Spacer(),
                  RoundIconButton(icon: Icons.volume_up_rounded, tooltip: context.l10n.listenAgain, color: MiraboColors.navy, onPressed: _say),
                ]),
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
                          child: SpeechBubble(
                            tail: TailSide.left,
                            tailAt: 0.6,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.l10n.closingTitle(profile.name), style: text.headlineMedium?.copyWith(color: MiraboColors.navy)),
                                const SizedBox(height: 4),
                                Text(context.l10n.closingBody, style: text.titleLarge),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ChunkyButton(
                  label: context.l10n.closingBack,
                  icon: Icons.home_rounded,
                  color: MiraboColors.sky,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
