import 'package:flutter/material.dart';

import '../activity_player.dart';

/// "Tocca quello giusto": una o più opzioni corrette. Con più corrette, il round
/// finisce quando sono state toccate tutte; un tocco sbagliato conta un tentativo.
class TapMatchRound extends RoundWidget {
  const TapMatchRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<TapMatchRound> createState() => _TapMatchRoundState();
}

class _TapMatchRoundState extends RoundState<TapMatchRound> {
  List<Map<String, dynamic>> get _rounds => (widget.level['rounds'] as List).cast<Map<String, dynamic>>();
  final Set<int> _found = {};
  final Set<int> _wrong = {};

  @override
  int get roundCount => _rounds.length;

  @override
  void next() {
    _found.clear();
    _wrong.clear();
    super.next();
  }

  static bool _correct(Map<String, dynamic> o) => o['correct'] == true;

  /// Le opzioni del round tagliate per l'autonomia: la giusta c'è sempre.
  List<Map<String, dynamic>> _options(Map<String, dynamic> r) =>
      options((r['options'] as List).cast<Map<String, dynamic>>(), _correct);

  void _tap(int i, Map<String, dynamic> r) {
    final options = _options(r);
    final correctCount = options.where((o) => o['correct'] == true).length;
    if (options[i]['correct'] == true) {
      setState(() => _found.add(i));
      widget.ctx.say(options[i]['label'] as String? ?? '');
      if (_found.length == correctCount) answer(true);
    } else {
      setState(() => _wrong.add(i));
      answer(false);
    }
  }

  @override
  Widget buildRound(BuildContext context, int index) {
    final r = _rounds[index];
    final options = _options(r);
    final prompt = r['prompt'] as String;
    announce('$prompt. ${r['say'] ?? ''}');
    return Column(
      children: [
        PromptBar(text: prompt, onSay: () => widget.ctx.say('$prompt. ${r['say'] ?? ''}')),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < options.length; i++)
                  PicTile(
                    emoji: options[i]['emoji'] as String? ?? '❔',
                    label: options[i]['label'] as String?,
                    selected: _found.contains(i),
                    dimmed: _wrong.contains(i) || (showHint && options[i]['correct'] != true),
                    highlight: showHint && options[i]['correct'] == true && !_found.contains(i),
                    onTap: _found.contains(i) || lastCorrect == true ? null : () => _tap(i, r),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
