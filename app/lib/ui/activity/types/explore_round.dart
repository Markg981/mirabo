import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../models/activity.dart';
import '../../design/palette.dart';
import '../../design/widgets.dart';
import '../activity_player.dart';

/// Scena da esplorare: ogni punto toccato racconta qualcosa. Il round finisce
/// quando il bambino vuole (nessun obbligo di toccare tutto); registra quanti
/// punti ha esplorato.
class ExploreRound extends RoundWidget {
  const ExploreRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<ExploreRound> createState() => _ExploreRoundState();
}

class _ExploreRoundState extends State<ExploreRound> {
  List<Map<String, dynamic>> get _spots => (widget.level['spots'] as List).cast<Map<String, dynamic>>();
  final Set<int> _seen = {};
  int? _current;

  @override
  Widget build(BuildContext context) {
    final scene = widget.level['scene'] as String;
    return Column(
      children: [
        PromptBar(text: context.l10n.exploreTap(scene), onSay: () => widget.ctx.say(context.l10n.exploreSay(scene))),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _spots.length; i++)
                  PicTile(
                    emoji: _spots[i]['emoji'] as String,
                    label: _spots[i]['label'] as String,
                    selected: _seen.contains(i),
                    highlight: _current == i,
                    onTap: () {
                      setState(() {
                        _seen.add(i);
                        _current = i;
                      });
                      widget.ctx.say('${_spots[i]['label']}. ${_spots[i]['say']}');
                    },
                  ),
              ],
            ),
          ),
        ),
        if (_current != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(_spots[_current!]['say'] as String, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ChunkyButton(
            color: MiraboColors.leaf,
            onPressed: _seen.isEmpty
                ? null
                : () {
                    widget.onRound(const RoundResult());
                    widget.onFinished();
                  },
            label: _seen.length == _spots.length ? context.l10n.exploreAllSeen : context.l10n.exploreEnough,
          ),
        ),
      ],
    );
  }
}
