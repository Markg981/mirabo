import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../models/activity.dart';
import '../../design/palette.dart';
import '../../design/widgets.dart';
import '../activity_player.dart';

/// Lista da spuntare nel momento reale (la sera, per domani). Ogni voce ha due
/// stati: fatto, e "da solo" (lo spunta il genitore). Non c'è giusto o sbagliato:
/// il round registra quante voci sono state fatte da solo.
class ChecklistRound extends RoundWidget {
  const ChecklistRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<ChecklistRound> createState() => _ChecklistRoundState();
}

class _ChecklistRoundState extends State<ChecklistRound> {
  List<Map<String, dynamic>> get _items => (widget.level['items'] as List).cast<Map<String, dynamic>>();
  late final List<bool> _done = List.filled(_items.length, false);
  late final List<bool> _alone = List.filled(_items.length, false);

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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilterChip(
                      label: Text(context.l10n.checklistAlone),
                      selected: _alone[i],
                      onSelected: _done[i] ? (v) => setState(() => _alone[i] = v) : null,
                    ),
                    const SizedBox(width: 12),
                    Checkbox(
                      value: _done[i],
                      onChanged: (v) => setState(() {
                        _done[i] = v ?? false;
                        if (!_done[i]) _alone[i] = false;
                        if (_done[i]) widget.ctx.say(_items[i]['label'] as String);
                      }),
                    ),
                  ],
                ),
                onTap: () => setState(() {
                  _done[i] = !_done[i];
                  if (!_done[i]) _alone[i] = false;
                }),
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
              final alone = _alone.where((a) => a).length;
              final done = _done.where((d) => d).length;
              widget.onRound(RoundResult(attempts: 1, hints: 0, choice: 'done=$done;alone=$alone;of=${_items.length}'));
              widget.onFinished();
            },
          ),
        ),
      ],
    );
  }
}
