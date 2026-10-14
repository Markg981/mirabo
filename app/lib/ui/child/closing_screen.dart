import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/l10n.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'companion_widget.dart';

/// "Ho finito": il bambino chiude quando vuole, anche senza limite familiare.
/// Una frase breve riconosce quello che ha fatto e lo lascia andare. Niente
/// avvio dell'attività successiva e un compagno sereno, mai triste o
/// bisognoso. Storie e disegni sono già salvati mentre si fanno: tornare è
/// sempre possibile, da qui o riaprendo l'app.
class ClosingScreen extends StatelessWidget {
  const ClosingScreen({super.key});

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
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.closingBack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
