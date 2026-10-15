import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/l10n.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'category_screen.dart';
import 'child_top_bar.dart';
import 'companion_widget.dart';

/// Fine della sessione "da solo": il compagno saluta. Arriva solo quando la
/// storia o l'attività in corso è finita, mai a metà. Da qui si esce solo dal
/// lucchetto: il genitore cambia modalità e la casa torna.
class GoodbyeScreen extends StatefulWidget {
  const GoodbyeScreen({super.key});

  @override
  State<GoodbyeScreen> createState() => _GoodbyeScreenState();
}

class _GoodbyeScreenState extends State<GoodbyeScreen> {
  final _voice = ShortVoice();

  @override
  void initState() {
    super.initState();
    // Le pagine sopra la casa (mensola, giochi) si chiudono: resta il saluto,
    // detto a voce per chi non legge.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
      _say();
    });
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  void _say() {
    if (!mounted) return;
    final profile = AppStateScope.read(context).currentProfile!;
    _voice.say(profile.language, '${context.l10n.goodbyeTitle(profile.name)} ${context.l10n.goodbyeBody}');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final companion = state.companionOf(profile);
    final text = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SceneBackdrop(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      RoundIconButton(icon: Icons.volume_up_rounded, tooltip: context.l10n.listenAgain, color: MiraboColors.navy, onPressed: _say),
                      const Spacer(),
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
                            child: SpeechBubble(
                              tail: TailSide.left,
                              tailAt: 0.6,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.l10n.goodbyeTitle(profile.name), style: text.headlineMedium?.copyWith(color: MiraboColors.navy)),
                                  const SizedBox(height: 4),
                                  Text(context.l10n.goodbyeBody, style: text.titleLarge),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
