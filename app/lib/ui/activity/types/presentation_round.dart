import 'package:flutter/material.dart';

import '../../../audio/child_name.dart';
import '../../../l10n/l10n.dart';
import '../../../models/activity.dart';
import '../../design/palette.dart';
import '../../design/widgets.dart';
import '../activity_player.dart';

/// Presentazione da fare a casa: Montessori solo se lo dice la scheda
/// dell'attività (docs/montessori.md). Tre momenti sullo schermo:
/// 1. i materiali da preparare (per il grande);
/// 2. i passi, uno alla volta, letti a voce: il grande li mostra in silenzio,
///    poi mette via il tablet e il bambino lavora da solo;
/// 3. com'è andata: lo segna il genitore (l'ha fatto / da solo / vuole rifarla).
class PresentationRound extends RoundWidget {
  const PresentationRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<PresentationRound> createState() => _PresentationRoundState();
}

enum _Step { materials, steps, done }

class _PresentationRoundState extends State<PresentationRound> {
  _Step _phase = _Step.materials;
  int _step = 0;

  List<Map<String, dynamic>> get _materials => (widget.level['materials'] as List).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get _steps => (widget.level['steps'] as List).cast<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    switch (_phase) {
      case _Step.materials:
        return Column(
          children: [
            PromptBar(text: context.l10n.presentationWhatYouNeed, onSay: () => widget.ctx.say(context.l10n.presentationWhatYouNeedSay(_materials.map((m) => m['label']).join(', ')))),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  Wrap(
                    spacing: 18,
                    runSpacing: 6,
                    children: [
                      for (final m in _materials)
                        PicTile(emoji: m['emoji'] as String, label: m['label'] as String, size: 170),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AdultNote(text: context.l10n.presentationPrepare),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ChunkyButton(
                icon: Icons.arrow_forward_rounded,
                iconAfter: true,
                label: context.l10n.presentationReady,
                color: MiraboColors.leaf,
                onPressed: () {
                  setState(() => _phase = _Step.steps);
                  widget.ctx.say(_steps[0]['text'] as String);
                },
              ),
            ),
          ],
        );
      case _Step.steps:
        final s = _steps[_step];
        final last = _step == _steps.length - 1;
        return Column(
          children: [
            PromptBar(text: context.l10n.presentationStep('${_step + 1}', '${_steps.length}'), onSay: () => widget.ctx.say(s['text'] as String)),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PicTile(emoji: s['emoji'] as String, size: 200),
                      const SizedBox(height: 16),
                      SpeechBubble(
                        tail: TailSide.top,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        child: Text(s['text'] as String, textAlign: TextAlign.center, style: text.titleLarge),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_step > 0)
                    RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: context.l10n.back,
                      size: 64,
                      onPressed: () {
                        setState(() => _step--);
                        widget.ctx.say(_steps[_step]['text'] as String);
                      },
                    ),
                  const SizedBox(width: 20),
                  ChunkyButton(
                    icon: last ? Icons.pan_tool_rounded : Icons.arrow_forward_rounded,
                    iconAfter: !last,
                    color: last ? MiraboColors.apricot : MiraboColors.leaf,
                    label: last ? context.l10n.presentationWorkAlone : context.l10n.next,
                    onPressed: () {
                      if (last) {
                        setState(() => _phase = _Step.done);
                        widget.ctx.say(spokenWithName(context.l10n.presentationYourTurnSay, widget.ctx.profile.name));
                      } else {
                        setState(() => _step++);
                        widget.ctx.say(_steps[_step]['text'] as String);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      case _Step.done:
        return Column(
          children: [
            PromptBar(text: context.l10n.presentationHowDidItGo, onSay: () {}),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _Note(title: context.l10n.presentationControl, text: widget.level['control'] as String),
                  _Note(title: context.l10n.presentationObserve, text: widget.level['observe'] as String),
                  const SizedBox(height: 12),
                  _AdultNote(text: context.l10n.presentationMarkLater),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (final (label, code) in [(context.l10n.presentationWatched, 'watched'), (context.l10n.presentationDid, 'done'), (context.l10n.presentationAlone, 'alone'), (context.l10n.presentationRepeat, 'repeat')])
                    ChunkyButton(
                      label: label,
                      color: MiraboColors.sky,
                      height: 60,
                      onPressed: () {
                        widget.onRound(RoundResult(choice: 'presentation=$code'));
                        widget.onFinished();
                      },
                    ),
                ],
              ),
            ),
          ],
        );
    }
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.title, required this.text});
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SoftPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
}

/// Nota per l'adulto: si distingue dal resto con l'etichetta "Per il grande".
class _AdultNote extends StatelessWidget {
  const _AdultNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => SoftPanel(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBadge(icon: Icons.person_rounded, color: MiraboColors.teal, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${context.l10n.forTheAdult}  ', style: const TextStyle(fontWeight: FontWeight.w800, color: MiraboColors.teal)),
                  TextSpan(text: text),
                ]),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
}
