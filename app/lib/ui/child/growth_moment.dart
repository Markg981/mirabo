import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../app_state.dart';
import '../../content/story_repository.dart';
import '../../l10n/l10n.dart';
import '../../models/story.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'companion_widget.dart';

/// Se il compagno del bambino è appena cresciuto, glielo fa vedere: prima com'era,
/// poi com'è adesso, con la sua casa. Una volta sola, senza punteggi.
Future<void> showGrowthIfPending(BuildContext context) async {
  final state = AppStateScope.read(context);
  final profile = state.currentProfile;
  if (profile == null) return;
  final growth = state.takeGrowth(profile);
  if (growth == null) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => GrowthMoment(
      companion: state.companionOf(profile),
      growth: growth,
      found: state.worldsFound(profile),
      ttsCode: AppLanguage.fromCode(profile.language).ttsCode,
    ),
  );
}

class GrowthMoment extends StatefulWidget {
  const GrowthMoment({super.key, required this.companion, required this.growth, required this.found, required this.ttsCode});
  final Companion companion;
  final CompanionGrowth growth;
  final Set<World> found;
  final String ttsCode;

  @override
  State<GrowthMoment> createState() => _GrowthMomentState();
}

class _GrowthMomentState extends State<GrowthMoment> {
  final _tts = FlutterTts();
  late int _shown = widget.growth.from;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final animate = MiraboTokens.of(context).animate;
    final text = '${widget.companion.stageLabel(widget.growth.to)}. ${context.l10n.companionGrew}';
    if (!animate) _shown = widget.growth.to;
    Future.delayed(Duration(milliseconds: animate ? 900 : 0), () {
      if (!mounted) return;
      setState(() => _shown = widget.growth.to);
      _tts
        ..setLanguage(widget.ttsCode)
        ..setSpeechRate(0.45)
        ..speak(text);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = MiraboTokens.of(context).animate;
    final text = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: MiraboColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: animate ? const Duration(milliseconds: 700) : Duration.zero,
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(a), child: child),
              ),
              child: CompanionWidget(
                key: ValueKey(_shown),
                companion: widget.companion,
                stage: _shown,
                size: 260,
                withHome: true,
                found: widget.found,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.companion.stageLabel(widget.growth.to),
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: MiraboColors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SpeechBubble(
                tail: TailSide.top,
                tailAt: 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Text(context.l10n.companionGrew,
                    style: text.bodyLarge?.copyWith(fontSize: 22), textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 24),
            ChunkyButton(
              label: context.l10n.companionGrewOk,
              icon: Icons.favorite_rounded,
              color: MiraboColors.leaf,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
