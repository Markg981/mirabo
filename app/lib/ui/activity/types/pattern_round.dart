import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../activity_player.dart';

/// "Completa la sequenza": si vede la fila con un posto vuoto in fondo e si
/// sceglie cosa viene dopo.
class PatternRound extends RoundWidget {
  const PatternRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<PatternRound> createState() => _PatternRoundState();
}

class _PatternRoundState extends RoundState<PatternRound> {
  List<Map<String, dynamic>> get _rounds => (widget.level['rounds'] as List).cast<Map<String, dynamic>>();
  int _spokenFor = -1;

  @override
  int get roundCount => _rounds.length;

  @override
  Widget buildRound(BuildContext context, int index) {
    final r = _rounds[index];
    final seq = (r['sequence'] as List).cast<String>();
    final choices = (r['choices'] as List).cast<String>();
    final answerValue = r['answer'] as String;
    final prompt = context.l10n.patternPrompt;
    if (_spokenFor != index) {
      _spokenFor = index;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.ctx.say(prompt));
    }
    return Column(
      children: [
        PromptBar(text: prompt, onSay: () => widget.ctx.say(prompt)),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 12,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final s in seq) PicTile(emoji: s, size: 96),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: lastCorrect == true
                      ? Text(answerValue, style: const TextStyle(fontSize: 40))
                      : Text('?', style: Theme.of(context).textTheme.headlineMedium),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 20,
            children: [
              for (final c in choices)
                PicTile(
                  emoji: c,
                  size: 110,
                  highlight: showHint && c == answerValue,
                  dimmed: showHint && c != answerValue,
                  onTap: lastCorrect == true ? null : () => answer(c == answerValue),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
