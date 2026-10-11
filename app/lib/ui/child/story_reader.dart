import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../app_state.dart';
import '../../content/story_repository.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Illustrazione (segnaposto finché non ci sono i file)
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Semantics(
                        image: true,
                        label: screen.illustration.alt,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(24),
                          child: Text(screen.illustration.alt,
                              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ),
                    ),
                  ),
                  // Testo e compagno
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (screen.text != null)
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  screen.text!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          if (screen.isKeyPhrase)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(widget.story.keyPhrase,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      )),
                            ),
                          if (isDialogue) _buildDialogue(context, screen.dialogue!),
                          if (screen.companionLines != null && !isDialogue)
                            _CompanionBubble(
                              companion: companion,
                              stage: _profile.companionStage,
                              text: _withName(screen.companionLines!.forCompanion(_profile.companion)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Barra di navigazione: grande, poche cose.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Chiudi',
                    icon: const Icon(Icons.close_rounded, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    tooltip: 'Rileggi',
                    icon: const Icon(Icons.volume_up_rounded, size: 32),
                    onPressed: _speakCurrent,
                  ),
                  const Spacer(),
                  Text('${_index + 1} / ${_variant.screens.length}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 16),
                  if (_index > 0)
                    IconButton(
                      tooltip: 'Indietro',
                      icon: const Icon(Icons.arrow_back_rounded, size: 32),
                      onPressed: () {
                        setState(() => _index--);
                        _speakCurrent();
                      },
                    ),
                  FilledButton.icon(
                    onPressed: canAdvance ? _next : null,
                    icon: Icon(_isLast ? Icons.waving_hand_rounded : Icons.arrow_forward_rounded),
                    label: Text(_isLast ? 'A domani!' : 'Avanti'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogue(BuildContext context, Dialogue dialogue) {
    final companion = _state.companionOf(_profile);
    if (_mode == SessionMode.together) {
      return Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.people_rounded),
              const SizedBox(width: 12),
              Expanded(child: Text(dialogue.together, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final o in dialogue.options)
              ChoiceChip(
                label: Text(o.label),
                selected: _dialogueAnswer == o.id,
                onSelected: (_) => _choose(o),
                labelStyle: const TextStyle(fontSize: 18),
                padding: const EdgeInsets.all(16),
              ),
          ],
        ),
      ],
    );
  }
}

class _CompanionBubble extends StatelessWidget {
  const _CompanionBubble({required this.companion, required this.stage, required this.text});
  final Companion companion;
  final int stage;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CompanionWidget(companion: companion, stage: stage, size: 72),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
