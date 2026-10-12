import 'package:flutter/material.dart';

import '../../design/palette.dart';
import '../../design/widgets.dart';
import '../activity_player.dart';

/// Mini-scena con scelte: nessuna risposta è sbagliata. Dopo la scelta si vede
/// "cosa succede"; il bambino può provare le altre scelte prima di andare avanti.
class SceneChoiceRound extends RoundWidget {
  const SceneChoiceRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<SceneChoiceRound> createState() => _SceneChoiceRoundState();
}

class _SceneChoiceRoundState extends RoundState<SceneChoiceRound> {
  List<Map<String, dynamic>> get _scenes => (widget.level['scenes'] as List).cast<Map<String, dynamic>>();
  int? _chosen;
  String? _firstChoice;
  int _spokenFor = -1;

  @override
  int get roundCount => _scenes.length;

  @override
  void next() {
    _chosen = null;
    _firstChoice = null;
    super.next();
  }

  @override
  Widget buildRound(BuildContext context, int index) {
    final s = _scenes[index];
    final options = (s['options'] as List).cast<Map<String, dynamic>>();
    final text = s['text'] as String;
    final prompt = s['prompt'] as String;
    if (_spokenFor != index) {
      _spokenFor = index;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.ctx.say('$text $prompt'));
    }
    final chosen = _chosen;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Text(s['emoji'] as String, style: const TextStyle(fontSize: 56)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: Theme.of(context).textTheme.bodyLarge),
                    Text(prompt, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              RoundIconButton(icon: Icons.volume_up_rounded, tooltip: 'Riascolta', onPressed: () => widget.ctx.say('$text $prompt')),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < options.length; i++)
                  PicTile(
                    emoji: options[i]['emoji'] as String,
                    label: options[i]['label'] as String,
                    size: 170,
                    selected: chosen == i,
                    onTap: () {
                      setState(() {
                        _chosen = i;
                        _firstChoice ??= options[i]['label'] as String;
                      });
                      widget.ctx.say(options[i]['outcome'] as String);
                    },
                  ),
              ],
            ),
          ),
        ),
        if (chosen != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: SoftPanel(
              padding: const EdgeInsets.all(18),
              child: Row(
                  children: [
                    Expanded(child: Text(options[chosen]['outcome'] as String, style: Theme.of(context).textTheme.bodyLarge)),
                    const SizedBox(width: 12),
                    ChunkyButton(
                      color: MiraboColors.leaf,
                      icon: Icons.arrow_forward_rounded,
                      iconAfter: true,
                      onPressed: () => complete(choice: _firstChoice),
                      label: index + 1 >= roundCount ? 'Fine' : 'Avanti',
                    ),
                  ],
                ),
            ),
          ),
      ],
    );
  }
}
