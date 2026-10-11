import 'package:flutter/material.dart';

import '../../../models/activity.dart';
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
        PromptBar(text: 'Cosa è già pronto?', onSay: () => widget.ctx.say('Cosa è già pronto per domani?')),
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
                      label: const Text('da solo'),
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
          child: FilledButton.icon(
            icon: Icon(allDone ? Icons.bedtime_rounded : Icons.check_rounded),
            label: Text(allDone ? 'Tutto pronto, buonanotte' : 'Per oggi basta così'),
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
