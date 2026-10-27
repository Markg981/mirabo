import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../app_state.dart';
import '../../l10n/l10n.dart';
import '../../models/nature_day.dart';
import '../../models/profile.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'companion_widget.dart';

/// Calendario della natura: il mese a sinistra, a destra il giorno scelto
/// (che tempo fa, cosa si è visto) e il suggerimento del compagno per il
/// mese. Si segnano solo oggi e i giorni passati; un giorno saltato resta
/// vuoto e basta, senza rimproveri.
class NatureCalendar extends StatefulWidget {
  const NatureCalendar({super.key, this.now});

  /// Per i test: la data di "oggi".
  final DateTime? now;

  @override
  State<NatureCalendar> createState() => _NatureCalendarState();
}

class _NatureCalendarState extends State<NatureCalendar> {
  late final AppState _state = AppStateScope.read(context);
  late final ChildProfile _profile = _state.currentProfile!;
  final _tts = FlutterTts();
  late final DateTime _today = NatureDay.dateOnly(widget.now ?? DateTime.now());
  late DateTime _month = DateTime(_today.year, _today.month);
  late DateTime _selected = _today;
  Map<int, NatureDay> _days = {};

  @override
  void initState() {
    super.initState();
    _setupVoice();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _say(_tip));
  }

  Future<void> _setupVoice() async {
    try {
      await _tts.setLanguage(AppLanguage.fromCode(_profile.language).ttsCode);
      await _tts.setSpeechRate(0.45);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop().catchError((_) {});
    super.dispose();
  }

  String get _tip => natureTip(context.l10n, _state.hemisphere, month: _month, today: _today);

  Future<void> _say(String line) async {
    try {
      await _tts.stop();
      await _tts.speak(line);
    } catch (_) {}
  }

  Future<void> _load() async {
    final days = await _state.natureMonthOf(_profile, _month);
    if (mounted) setState(() => _days = {for (final d in days) d.day.day: d});
  }

  NatureDay get _day =>
      _days[_selected.day] ?? NatureDay(profileId: _profile.id, day: _selected);

  bool get _selectedInMonth => _selected.year == _month.year && _selected.month == _month.month;

  Future<void> _update(NatureDay d, String spoken) async {
    setState(() => _days = {..._days, d.day.day: d});
    _say(spoken);
    await _state.saveNatureDay(d, now: widget.now);
  }

  void _setWeather(Weather w) {
    final d = _day.weather == w ? _day.copyWith(clearWeather: true) : _day.copyWith(weather: w);
    _update(d, context.l10n.natureWeather(w.name));
  }

  void _toggle(NatureThing t) {
    final before = _day;
    final d = before.toggle(t);
    // Già tre cose segnate: il compagno ricorda il limite invece di non fare nulla.
    if (identical(d, before)) {
      _say(context.l10n.natureUpTo);
      return;
    }
    _update(d, context.l10n.natureThing(t.name));
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      final isCurrent = _month.year == _today.year && _month.month == _today.month;
      _selected = isCurrent ? _today : DateTime(_month.year, _month.month, 1);
      _days = {};
    });
    _load();
    _say(_tip);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final material = MaterialLocalizations.of(context);
    final isCurrentMonth = _month.year == _today.year && _month.month == _today.month;

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    RoundIconButton(icon: Icons.close_rounded, tooltip: l.close, onPressed: () => Navigator.of(context).pop()),
                    const SizedBox(width: 16),
                    const Text('🌦️', style: TextStyle(fontSize: 34)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l.natureTitle,
                          style: text.headlineSmall?.copyWith(color: MiraboColors.navy),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    RoundIconButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: material.previousMonthTooltip,
                      onPressed: () => _changeMonth(-1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(material.formatMonthYear(_month), style: text.titleLarge),
                    ),
                    // Il mese dopo non si guarda: non è ancora successo niente.
                    if (isCurrentMonth)
                      const SizedBox(width: 60)
                    else
                      RoundIconButton(
                        icon: Icons.chevron_right_rounded,
                        tooltip: material.nextMonthTooltip,
                        onPressed: () => _changeMonth(1),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: SoftPanel(
                          padding: const EdgeInsets.all(14),
                          child: _MonthGrid(
                            month: _month,
                            today: _today,
                            selected: _selectedInMonth ? _selected.day : null,
                            days: _days,
                            onSelect: (d) => setState(() => _selected = DateTime(_month.year, _month.month, d)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: _dayPanel(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayPanel(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final day = _day;
    final summary = NatureMonth(_days.values.toList());
    final isToday = _selected == _today;
    return ListView(
      children: [
        GestureDetector(
          onTap: () => _say(_tip),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CompanionWidget(companion: _state.companionOf(_profile), stage: _profile.companionStage, size: 84),
              const SizedBox(width: 6),
              Expanded(
                child: SpeechBubble(
                  tail: TailSide.left,
                  tailAt: 0.8,
                  child: Text(_tip, style: text.bodyMedium?.copyWith(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isToday ? l.natureToday : MaterialLocalizations.of(context).formatMediumDate(_selected),
          style: text.titleLarge?.copyWith(color: MiraboColors.navy),
        ),
        const SizedBox(height: 6),
        Text(l.natureAskWeather, style: text.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 2,
          children: [
            for (final w in Weather.values)
              _EmojiChoice(
                emoji: w.emoji,
                label: l.natureWeather(w.name),
                selected: day.weather == w,
                color: MiraboColors.sky,
                onTap: () => _setWeather(w),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(l.natureAskSeen, style: text.titleMedium),
        Text(l.natureUpTo, style: text.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 2,
          children: [
            for (final t in NatureThing.values)
              _EmojiChoice(
                emoji: t.emoji,
                label: l.natureThing(t.name),
                selected: day.seen.contains(t),
                color: MiraboColors.leaf,
                onTap: () => _toggle(t),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SoftPanel(
          padding: const EdgeInsets.all(16),
          child: summary.observed == 0
              ? Text(l.natureEmptyMonth, style: text.bodyMedium)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l.natureThisMonth} · ${l.natureDays(summary.observed)}', style: text.titleMedium),
                    const SizedBox(height: 6),
                    Wrap(spacing: 14, runSpacing: 4, children: [
                      for (final e in summary.weather.entries) _Count(emoji: e.key.emoji, count: e.value),
                      for (final e in summary.seen.entries) _Count(emoji: e.key.emoji, count: e.value),
                    ]),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.emoji, required this.count});
  final String emoji;
  final int count;

  @override
  Widget build(BuildContext context) =>
      Text('$emoji $count', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: MiraboColors.ink));
}

class _EmojiChoice extends StatelessWidget {
  const _EmojiChoice({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = MiraboTokens.of(context).tint(color);
    return Semantics(
      selected: selected,
      child: BlockTile(
        onTap: onTap,
        width: 70,
        height: 70,
        radius: 20,
        depth: 5,
        color: selected ? MiraboColors.pale(c, 0.55) : MiraboColors.paper,
        border: Border.all(color: selected ? c : MiraboColors.line, width: selected ? 3 : 1.5),
        semanticLabel: label,
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 34))),
      ),
    );
  }
}

/// La griglia del mese: una casella per giorno con il tempo e la prima cosa
/// vista. I giorni futuri non si toccano.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.days,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime today;
  final int? selected;
  final Map<int, NatureDay> days;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final first = material.firstDayOfWeekIndex; // 0 = domenica
    // DateTime.weekday: 1 = lunedì … 7 = domenica.
    final lead = (DateTime(month.year, month.month, 1).weekday % 7 - first + 7) % 7;
    final count = daysInMonth(month);
    final rows = ((lead + count) / 7).ceil();
    final text = Theme.of(context).textTheme;
    final accent = MiraboTokens.of(context).tint(MiraboColors.sky);

    return Column(
      children: [
        Row(children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Text(material.narrowWeekdays[(first + i) % 7],
                    style: text.labelLarge?.copyWith(color: MiraboColors.inkSoft)),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        Expanded(
          child: Column(
            children: [
              for (var r = 0; r < rows; r++)
                Expanded(
                  child: Row(
                    children: [
                      for (var c = 0; c < 7; c++)
                        Expanded(child: _cell(context, r * 7 + c - lead + 1, count, accent)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, int d, int count, Color accent) {
    if (d < 1 || d > count) return const SizedBox.shrink();
    final date = DateTime(month.year, month.month, d);
    final future = date.isAfter(today);
    final entry = days[d];
    final isSelected = selected == d;
    final emojis = [if (entry?.weather != null) entry!.weather!.emoji, ...?entry?.seen.take(1).map((t) => t.emoji)];
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Opacity(
        opacity: future ? 0.35 : 1,
        child: Material(
          color: isSelected ? MiraboColors.pale(accent, 0.6) : MiraboColors.cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isSelected ? accent : (date == today ? MiraboColors.sun : MiraboColors.line),
              width: isSelected || date == today ? 2.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: future ? null : () => onSelect(d),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('$d', style: Theme.of(context).textTheme.labelMedium),
                  ),
                  Expanded(
                    child: FittedBox(
                      child: Text(emojis.join(), style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
