import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../models/activity.dart';
import '../../design/palette.dart';
import '../../design/widgets.dart';
import '../activity_player.dart';

/// Conto alla rovescia: il genitore imposta la data dell'evento (una volta);
/// ogni giorno c'è una piccola cosa da fare insieme. Il round registra quale
/// giorno è stato "colorato".
///
/// MVP: la data è tenuta in memoria per la sessione; in fase 1 va nel profilo.
class CountdownRound extends RoundWidget {
  const CountdownRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<CountdownRound> createState() => _CountdownRoundState();
}

class _CountdownRoundState extends State<CountdownRound> {
  DateTime? _eventDate;

  List<String> get _daily => (widget.level['daily'] as List).cast<String>();
  int get _days => widget.level['days'] as int;

  @override
  Widget build(BuildContext context) {
    final event = widget.level['event'] as String;
    final date = _eventDate;
    if (date == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(event, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(context.l10n.countdownPickHint),
            const SizedBox(height: 24),
            ChunkyButton(
              icon: Icons.calendar_month_rounded,
              label: context.l10n.countdownPick,
              color: MiraboColors.sky,
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 120)),
                  initialDate: now.add(Duration(days: _days)),
                );
                if (picked != null) setState(() => _eventDate = picked);
              },
            ),
          ],
        ),
      );
    }
    final today = DateTime.now();
    final remaining = DateUtils.dateOnly(date).difference(DateUtils.dateOnly(today)).inDays;
    final dayIndex = (_days - remaining).clamp(0, _daily.length - 1);
    final todaysTask = remaining <= 0 ? context.l10n.countdownTodayTask(widget.ctx.profile.name) : _daily[dayIndex];

    return Column(
      children: [
        PromptBar(
          text: remaining <= 0 ? context.l10n.countdownToday : context.l10n.countdownDaysTo(remaining, event),
          onSay: () => widget.ctx.say(remaining <= 0 ? context.l10n.countdownTodaySay : context.l10n.countdownDaysSay(remaining, todaysTask)),
        ),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _days; i++)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: i < _days - remaining
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      i == _days - 1 ? '🏫' : '${i + 1}',
                      style: TextStyle(
                        fontSize: 22,
                        color: i < _days - remaining ? Theme.of(context).colorScheme.onPrimary : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('📌', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(todaysTask, style: Theme.of(context).textTheme.bodyLarge)),
                  ChunkyButton(
                    label: context.l10n.done,
                    icon: Icons.check_rounded,
                    color: MiraboColors.leaf,
                    onPressed: () {
                      widget.onRound(const RoundResult());
                      widget.onFinished();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
