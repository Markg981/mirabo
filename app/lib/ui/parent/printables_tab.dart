import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../app_state.dart';
import '../../l10n/l10n.dart';
import '../../models/made_story.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../../printables/printables.dart';
import '../design/palette.dart';
import 'profile_form.dart' show FormSection;

/// Stampabili: fogli in PDF nella lingua del bambino, da stampare o salvare
/// con il dialogo di stampa del sistema. La pagina è nella lingua del tablet.
class PrintablesTab extends StatefulWidget {
  const PrintablesTab({super.key, required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  @override
  State<PrintablesTab> createState() => _PrintablesTabState();
}

class _PrintablesTabState extends State<PrintablesTab> {
  late final Future<(List<Story>, List<MadeStory>)> _data = _load();
  Future<PrintFonts>? _fonts;
  bool _busy = false;

  /// I testi dei fogli sono nella lingua del bambino, non in quella del tablet.
  AppLocalizations get _child => lookupAppLocalizations(AppLanguage.fromCode(widget.profile.language).locale);

  /// Le storie finite che hanno un gesto, e le storie inventate.
  Future<(List<Story>, List<MadeStory>)> _load() async {
    final s = widget.state;
    final p = widget.profile;
    final finished = {for (final e in await s.db.diary(p.id, days: 3650)) if (e.completed) e.storyId};
    final stories = [
      for (final id in finished)
        if (s.repo.byId(id, p.language) case final story? when story.gesture != null) story,
    ];
    return (stories, await s.madeStoriesOf(p));
  }

  Future<void> _print(String name, Future<Uint8List> Function(AppLocalizations l, PrintFonts f) build) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final fonts = await (_fonts ??= PrintFonts.load());
      final bytes = await build(_child, fonts);
      await Printing.layoutPdf(name: 'mirabo-$name.pdf', onLayout: (_) async => bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = widget.profile;
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.data == null) return const Center(child: CircularProgressIndicator());
        final (stories, made) = snap.data!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Text(l.printIntro(p.name), style: Theme.of(context).textTheme.bodyLarge),
            if (_busy) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
            const SizedBox(height: 16),
            FormSection(
              icon: Icons.today_rounded,
              color: MiraboColors.leaf,
              title: l.printEveryday,
              children: [
                _tile(l.printNameTrace, l.printNameTraceHint(p.name), Icons.edit_rounded,
                    () => _print('nome', (c, f) => nameTracingPdf(c, f, p.name))),
                _tile(l.printNature, l.printNatureHint(p.name), Icons.wb_sunny_rounded, () async {
                  final month = DateTime.now();
                  final days = await widget.state.natureMonthOf(p, month);
                  await _print('natura',
                      (c, f) => natureMonthPdf(c, f, p.language, month, days, hemisphere: widget.state.hemisphere, today: month));
                }),
              ],
            ),
            const SizedBox(height: 20),
            FormSection(
              icon: Icons.spa_rounded,
              color: MiraboColors.teal,
              title: l.printGestures,
              children: [
                if (stories.isEmpty) Text(l.printGesturesEmpty(p.name)),
                for (final s in stories)
                  _tile(s.title, l.printGestureHint, Icons.favorite_rounded,
                      () => _print('gesto-${s.id}', (c, f) => gestureSheetPdf(c, f, s))),
              ],
            ),
            const SizedBox(height: 20),
            FormSection(
              icon: Icons.auto_stories_rounded,
              color: MiraboColors.plum,
              title: l.printMade,
              children: [
                if (made.isEmpty) Text(l.printMadeEmpty(p.name)),
                for (final m in made)
                  _tile(m.titleIn(_child), l.printMadeHint, Icons.menu_book_rounded,
                      () => _print('storia-${m.id}', (c, f) => madeStoryBookletPdf(c, f, m, p.name))),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _tile(String title, String subtitle, IconData icon, VoidCallback onTap) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: FilledButton.tonalIcon(
          icon: const Icon(Icons.print_rounded),
          label: Text(context.l10n.printButton),
          onPressed: _busy ? null : onTap,
        ),
      );
}
