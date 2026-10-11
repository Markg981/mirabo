import 'package:flutter/material.dart';

import '../../../models/activity.dart';
import '../activity_player.dart';

/// Presentazione Montessori da fare a casa. Tre momenti sullo schermo:
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
            PromptBar(text: 'Cosa serve', onSay: () => widget.ctx.say('Cosa serve: ${_materials.map((m) => m['label']).join(', ')}')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  for (final m in _materials)
                    ListTile(
                      leading: Text(m['emoji'] as String, style: const TextStyle(fontSize: 36)),
                      title: Text(m['label'] as String, style: text.bodyLarge),
                    ),
                  const SizedBox(height: 12),
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Per il grande: prepara tutto su un vassoio prima di chiamare il bambino. '
                          'Mostra i passi una volta, lentamente e senza parlare; poi lascia fare.', style: text.bodyMedium),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Tutto pronto'),
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
            PromptBar(text: 'Passo ${_step + 1} di ${_steps.length}', onSay: () => widget.ctx.say(s['text'] as String)),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s['emoji'] as String, style: const TextStyle(fontSize: 96)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _step--);
                        widget.ctx.say(_steps[_step]['text'] as String);
                      },
                      child: const Text('Indietro'),
                    ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    icon: Icon(last ? Icons.pan_tool_rounded : Icons.arrow_forward_rounded),
                    label: Text(last ? 'Ora lavora da solo' : 'Avanti'),
                    onPressed: () {
                      if (last) {
                        setState(() => _phase = _Step.done);
                        widget.ctx.say('Adesso tocca a te, ${widget.ctx.profile.name}. Il tablet lo mettiamo via.');
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
            PromptBar(text: 'Per il grande: com\'è andata?', onSay: () {}),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _Note(title: 'Controllo dell\'errore', text: widget.level['control'] as String),
                  _Note(title: 'Cosa osservare', text: widget.level['observe'] as String),
                  const SizedBox(height: 12),
                  const Text('Segna quando ha finito di lavorare, anche dopo un po\'. Non correggere mentre lavora.'),
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
                  for (final (label, code) in [('Ha guardato', 'watched'), ('L\'ha fatto', 'done'), ('Da solo', 'alone'), ('Vuole rifarla', 'repeat')])
                    FilledButton.tonal(
                      onPressed: () {
                        widget.onRound(RoundResult(attempts: 1, hints: 0, choice: 'presentation=$code'));
                        widget.onFinished();
                      },
                      child: Text(label),
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
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(title, style: Theme.of(context).textTheme.titleLarge),
          subtitle: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
}
