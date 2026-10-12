import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../app_state.dart';
import '../../content/story_repository.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'companion_widget.dart';

/// Lettore di una storia: una schermata alla volta, il compagno a lato,
/// la pausa di dialogo a metà, il saluto alla fine. Nessun "prossima storia".
///
/// MVP: la lettura ad alta voce usa il TTS di sistema su tutto il testo.
/// In fase 1 l'audio registrato sostituisce il TTS per la narrazione e il TTS
/// resta solo per il nome del bambino (audio.nameSlots).
class StoryReader extends StatefulWidget {
  const StoryReader({super.key, required this.story});
  final Story story;

  @override
  State<StoryReader> createState() => _StoryReaderState();
}

class _StoryReaderState extends State<StoryReader> {
  final _tts = FlutterTts();
  int _index = 0;
  String? _dialogueAnswer;
  bool _recorded = false;

  late final AppState _state;
  late final ChildProfile _profile;
  late final SessionMode _mode;
  late final StoryVariant _variant;

  @override
  void initState() {
    super.initState();
    _state = AppStateScope.read(context);
    _profile = _state.currentProfile!;
    _mode = _state.mode;
    _variant = widget.story.variants[_profile.ageBand]!;
    _tts.setLanguage('it-IT');
    _tts.setSpeechRate(0.45);
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  @override
  void dispose() {
    _tts.stop();
    if (!_recorded) {
      // Uscita a metà: resta nel diario come non completata.
      _state.recordStory(widget.story, completed: false, dialogueAnswer: _dialogueAnswer);
    }
    super.dispose();
  }

  StoryScreen get _screen => _variant.screens[_index];
  bool get _isLast => _index == _variant.screens.length - 1;

  String _withName(String s) => s.replaceAll('{nome}', _profile.name);

  Future<void> _speakCurrent() async {
    await _tts.stop();
    final parts = <String>[];
    if (_screen.text != null) parts.add(_screen.text!);
    if (_screen.companionLines != null) parts.add(_withName(_screen.companionLines!.forCompanion(_profile.companion)));
    if (_screen.kind == ScreenKind.dialogue && _mode == SessionMode.alone) {
      parts.add(_withName(_screen.dialogue!.alonePrompt.forCompanion(_profile.companion)));
    }
    if (parts.isNotEmpty) await _tts.speak(parts.join(' '));
  }

  Future<void> _next() async {
    if (_isLast) {
      _recorded = true;
      await _state.recordStory(widget.story, completed: true, dialogueAnswer: _dialogueAnswer);
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
    _speakCurrent();
  }

  Future<void> _choose(DialogueOption option) async {
    setState(() => _dialogueAnswer = option.id);
    await _tts.stop();
    await _tts.speak(_withName(option.reaction.forCompanion(_profile.companion)));
  }

  @override
  Widget build(BuildContext context) {
    final companion = _state.companionOf(_profile);
    final screen = _screen;
    final isDialogue = screen.kind == ScreenKind.dialogue;
    final canAdvance = !isDialogue || _mode == SessionMode.together || _dialogueAnswer != null;
    final world = worldStyle(widget.story.world);
    final tokens = MiraboTokens.of(context);
    final accent = tokens.tint(world.color);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                // In alto: chiudi, avanzamento, riascolta.
                Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Chiudi',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(widget.story.title,
                              style: text.titleLarge?.copyWith(color: MiraboColors.navy),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          StepDots(count: _variant.screens.length, current: _index, color: MiraboColors.navy),
                        ],
                      ),
                    ),
                    RoundIconButton(icon: Icons.volume_up_rounded, tooltip: 'Rileggi', onPressed: _speakCurrent),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Illustrazione (segnaposto finché non ci sono i file)
                      Expanded(
                        flex: 5,
                        child: _IllustrationPlaceholder(alt: screen.illustration.alt, color: accent, icon: world.icon),
                      ),
                      const SizedBox(width: 20),
                      // Testo e compagno
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (screen.text != null)
                              Flexible(
                                child: SoftPanel(
                                  padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
                                  child: SingleChildScrollView(
                                    child: Text(screen.text!, style: text.bodyLarge?.copyWith(fontSize: 24)),
                                  ),
                                ),
                              )
                            else
                              const Spacer(),
                            if (screen.isKeyPhrase)
                              Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: tokens.tint(MiraboColors.sun),
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(color: MiraboColors.deep(tokens.tint(MiraboColors.sun), 0.14), offset: const Offset(0, 5)),
                                    ],
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.star_rounded, color: Colors.white, size: 34),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(widget.story.keyPhrase, style: text.titleLarge)),
                                  ]),
                                ),
                              ),
                            if (isDialogue) ...[
                              const SizedBox(height: 14),
                              _buildDialogue(context, screen.dialogue!),
                            ],
                            if (screen.companionLines != null && !isDialogue) ...[
                              const SizedBox(height: 14),
                              _CompanionBubble(
                                companion: companion,
                                stage: _profile.companionStage,
                                text: _withName(screen.companionLines!.forCompanion(_profile.companion)),
                                // Senza testo della storia il compagno ha tutta la colonna.
                                size: screen.text == null ? 190 : 96,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // In basso: indietro e avanti, grandi.
                Row(
                  children: [
                    if (_index > 0)
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Indietro',
                        size: 64,
                        onPressed: () {
                          setState(() => _index--);
                          _speakCurrent();
                        },
                      ),
                    const Spacer(),
                    ChunkyButton(
                      label: _isLast ? 'A domani!' : 'Avanti',
                      icon: _isLast ? Icons.waving_hand_rounded : Icons.arrow_forward_rounded,
                      iconAfter: !_isLast,
                      color: _isLast ? MiraboColors.apricot : MiraboColors.leaf,
                      onPressed: canAdvance ? _next : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogue(BuildContext context, Dialogue dialogue) {
    final companion = _state.companionOf(_profile);
    if (_mode == SessionMode.together) {
      return SoftPanel(
        padding: const EdgeInsets.all(18),
        color: MiraboColors.pale(MiraboTokens.of(context).tint(MiraboColors.teal), 0.85),
        child: Row(
          children: [
            const IconBadge(icon: Icons.people_rounded, color: MiraboColors.teal, size: 52),
            const SizedBox(width: 14),
            Expanded(child: Text(dialogue.together, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompanionBubble(
          companion: companion,
          stage: _profile.companionStage,
          text: _withName(_dialogueAnswer == null
              ? dialogue.alonePrompt.forCompanion(_profile.companion)
              : dialogue.options
                  .firstWhere((o) => o.id == _dialogueAnswer)
                  .reaction
                  .forCompanion(_profile.companion)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final o in dialogue.options)
              BlockTile(
                onTap: () => _choose(o),
                radius: 20,
                depth: 6,
                color: _dialogueAnswer == o.id ? MiraboTokens.of(context).tint(MiraboColors.sky) : MiraboColors.paper,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                semanticLabel: o.label,
                child: Text(
                  o.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _dialogueAnswer == o.id ? Colors.white : MiraboColors.ink,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Riquadro dell'illustrazione finché i disegni non ci sono: il colore e
/// l'icona del mondo, con la descrizione della scena come didascalia.
class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder({required this.alt, required this.color, required this.icon});
  final String alt;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: alt,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(color, Colors.white, 0.15)!, MiraboColors.deep(color, 0.06)],
          ),
          boxShadow: [
            BoxShadow(color: MiraboColors.deep(color, 0.16), offset: const Offset(0, 8)),
            ...softShadow(),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(right: -60, top: -60, child: _disc(240, 0.14)),
            Positioned(left: -40, bottom: -80, child: _disc(260, 0.10)),
            Positioned(left: 40, top: 40, child: _disc(26, 0.35)),
            Positioned(right: 70, bottom: 120, child: _disc(16, 0.4)),
            Center(child: Icon(icon, size: 150, color: Colors.white.withValues(alpha: 0.9))),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(alt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MiraboColors.ink),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disc(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: alpha), shape: BoxShape.circle),
      );
}

class _CompanionBubble extends StatelessWidget {
  const _CompanionBubble({required this.companion, required this.stage, required this.text, this.size = 96});
  final Companion companion;
  final int stage;
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CompanionWidget(companion: companion, stage: stage, size: size),
        const SizedBox(width: 6),
        Expanded(
          child: SpeechBubble(
            tail: TailSide.left,
            tailAt: 0.8,
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}
