import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../models/activity.dart';
import '../../design/palette.dart';
import '../../design/widgets.dart';
import '../activity_player.dart';

/// Lista da spuntare nel momento reale (la sera, per domani). Non c'è giusto o
/// sbagliato e non si registra niente: né quante voci, né chi le ha fatte
/// (docs/privacy/mvp-data.md).
class ChecklistRound extends RoundWidget {
  const ChecklistRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<ChecklistRound> createState() => _ChecklistRoundState();
}

class _ChecklistRoundState extends State<ChecklistRound> {
  List<Map<String, dynamic>> get _items => (widget.level['items'] as List).cast<Map<String, dynamic>>();
  late final List<bool> _done = List.filled(_items.length, false);

  @override
  Widget build(BuildContext context) {
    final allDone = _done.every((d) => d);
    return Column(
      children: [
        PromptBar(text: context.l10n.checklistPrompt, onSay: () => widget.ctx.say(context.l10n.checklistSay)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _items.length,
            itemBuilder: (context, i) => Card(
              child: ListTile(
                leading: Text(_items[i]['emoji'] as String, style: const TextStyle(fontSize: 36)),
                title: Text(_items[i]['label'] as String, style: Theme.of(context).textTheme.bodyLarge),
                trailing: Checkbox(
                  value: _done[i],
                  onChanged: (v) => setState(() {
                    _done[i] = v ?? false;
                    if (_done[i]) widget.ctx.say(_items[i]['label'] as String);
                  }),
                ),
                onTap: () => setState(() => _done[i] = !_done[i]),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ChunkyButton(
              icon: allDone ? Icons.bedtime_rounded : Icons.check_rounded,
              label: allDone ? context.l10n.checklistAllDone : context.l10n.enoughForToday,
              color: MiraboColors.leaf,
            onPressed: () {
              widget.onRound(const RoundResult());
              widget.onFinished();
            },
          ),
        ),
      ],
    );
  }
}
