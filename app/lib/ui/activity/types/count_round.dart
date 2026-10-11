import 'package:flutter/material.dart';

import '../activity_player.dart';

/// "Conta e scegli il numero". Toccando gli oggetti vengono contati a voce
/// (aiuto naturale); poi si sceglie tra i numeri.
class CountRound extends RoundWidget {
  const CountRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<CountRound> createState() => _CountRoundState();
}

class _CountRoundState extends RoundState<CountRound> {
  List<Map<String, dynamic>> get _rounds => (widget.level['rounds'] as List).cast<Map<String, dynamic>>();
  final Set<int> _counted = {};
  int _spokenFor = -1;

  @override
  int get roundCount => _rounds.length;

  @override
  void next() {
    _counted.clear();
    super.next();
  }

  @override
  Widget buildRound(BuildContext context, int index) {
    final r = _rounds[index];
    final count = r['count'] as int;
    final choices = (r['choices'] as List).cast<int>();
    final prompt = r['prompt'] as String;
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
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < count; i++)
                  PicTile(
                    emoji: r['emoji'] as String,
                    size: count > 8 ? 84 : 110,
                    selected: _counted.contains(i),
                    onTap: () {
                      setState(() => _counted.add(i));
                      widget.ctx.say('${_counted.length}');
                    },
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 16,
            children: [
              for (final c in choices)
                FilledButton.tonal(
                  style: FilledButton.styleFrom(minimumSize: const Size(96, 72), textStyle: const TextStyle(fontSize: 32)),
                  onPressed: lastCorrect == true || (showHint && c != count) ? null : () => answer(c == count),
                  child: Text('$c'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
