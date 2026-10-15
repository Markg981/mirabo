import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../audio/child_name.dart';
import '../l10n/l10n.dart';
import '../app_state.dart';
import '../ui/child/companion_widget.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

/// Schermata di un gioco: barra in alto, il gioco, e a fine partita il
/// compagno che si complimenta e chiede se rifarlo. Nessun punteggio.
class GameShell extends StatefulWidget {
  const GameShell({super.key, required this.game});
  final GameInfo game;

  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  final _tts = FlutterTts();
  int _run = 0;
  bool _done = false;

  /// L'ultima cosa detta dal gioco: il riascolta la ripete (docs/child-paths.md).
  String? _last;

  @override
  void initState() {
    super.initState();
    _tts.setSpeechRate(0.45);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tts.setLanguage(AppLanguage.fromCode(AppStateScope.read(context).currentProfile!.language).ttsCode);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _say(String text) async {
    _last = text;
    if (mounted) setState(() {});
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Senza voce di sistema il gioco resta giocabile: le consegne sono a figure.
    }
  }

  Future<void> _sayOnly(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _finished() {
    if (!mounted || _done) return;
    final name = AppStateScope.read(context).currentProfile!.name;
    setState(() => _done = true);
    _say(spokenWithName(context.l10n.gameWellDoneSay, name));
  }

  void _again() => setState(() {
        _done = false;
        _run++;
      });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final tokens = MiraboTokens.of(context);
    final ctx = GameContext(band: profile.ageBand, say: _say, onFinished: _finished, calm: tokens.lowStimulation);

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    RoundIconButton(icon: Icons.close_rounded, tooltip: context.l10n.close, onPressed: () => Navigator.of(context).pop()),
                    const SizedBox(width: 16),
                    Text(widget.game.emojis.first, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.game.title(context.l10n),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: MiraboColors.navy),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Il riascolta sta in alto a destra, come in storie e attività.
                    if (_last != null)
                      RoundIconButton(icon: Icons.volume_up_rounded, tooltip: context.l10n.listenAgain, onPressed: () => _sayOnly(_last!)),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: KeyedSubtree(key: ValueKey(_run), child: widget.game.build(ctx))),
                    if (_done)
                      Positioned.fill(
                        child: ColoredBox(
                          color: MiraboColors.navy.withValues(alpha: 0.35),
                          child: Center(
                            child: SoftPanel(
                              padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
                              radius: 36,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CompanionWidget(
                                    companion: state.companionOf(profile),
                                    stage: profile.companionStage,
                                    size: 190,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(context.l10n.gameWellDone(profile.name), style: Theme.of(context).textTheme.headlineMedium),
                                      const SizedBox(height: 4),
                                      Text(context.l10n.gameNiceGame, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          SpokenButton(
                                            label: context.l10n.gameAgain,
                                            icon: Icons.replay_rounded,
                                            color: MiraboColors.leaf,
                                            onPressed: _again,
                                            onListen: () => _sayOnly(context.l10n.gameAgain),
                                          ),
                                          const SizedBox(width: 14),
                                          SpokenButton(
                                            label: context.l10n.gameEnough,
                                            icon: Icons.home_rounded,
                                            color: MiraboColors.sky,
                                            onPressed: () => Navigator.of(context).pop(),
                                            onListen: () => _sayOnly(context.l10n.gameEnough),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}
