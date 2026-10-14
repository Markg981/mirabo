import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../design/palette.dart';
import '../../design/widgets.dart';
import '../activity_player.dart';

/// Piccolo progetto aperto (7–10): idea → previsione → prova → revisione. Ogni
/// passaggio è un round. Il tablet non verifica niente: il criterio ("il ponte
/// regge una moneta?") si controlla nel mondo vero e ammette più soluzioni. Nei
/// passaggi di idea, previsione e revisione il bambino può scrivere due righe
/// (facoltative); nella prova dice com'è andata. Tutto finisce nel `choice` del
/// round, così il genitore può rivedere il processo.
class ProjectRound extends RoundWidget {
  const ProjectRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<ProjectRound> createState() => _ProjectRoundState();
}

/// Lunghezza massima della nota: due righe, non un tema.
const projectNoteMax = 140;

/// Passaggio in cui il bambino dice com'è andata la prova.
const projectTestPhase = 'test';

/// Codifica del `choice` di un passaggio: `project=idea;note=...` oppure,
/// per la prova, `project=test;result=held|notyet`. La nota va per ultima.
String encodeProjectChoice(String phase, {String? note, String? result}) {
  final clean = (note ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  if (result != null) return 'project=$phase;result=$result';
  return clean.isEmpty ? 'project=$phase' : 'project=$phase;note=$clean';
}

class _ProjectRoundState extends RoundState<ProjectRound> {
  List<Map<String, dynamic>> get _phases => (widget.level['phases'] as List).cast<Map<String, dynamic>>();
  final _note = TextEditingController();

  @override
  int get roundCount => _phases.length;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _title(BuildContext context, String phase) => switch (phase) {
        'idea' => context.l10n.projectPhaseIdea,
        'prediction' => context.l10n.projectPhasePrediction,
        'test' => context.l10n.projectPhaseTest,
        _ => context.l10n.projectPhaseRevision,
      };

  void _done(String phase, {String? result}) {
    final choice = encodeProjectChoice(phase, note: _note.text, result: result);
    _note.clear();
    complete(choice: choice);
  }

  @override
  Widget buildRound(BuildContext context, int i) {
    final p = _phases[i];
    final phase = p['phase'] as String;
    final text = Theme.of(context).textTheme;
    announce(p['say'] as String);
    return Column(
      children: [
        PromptBar(text: '${i + 1}/${_phases.length} · ${_title(context, phase)}', onSay: () => widget.ctx.say(p['say'] as String)),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p['emoji'] as String, style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 8),
                    Text(widget.ctx.withName(p['label'] as String), style: text.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text(widget.level['goal'] as String, style: text.titleMedium, textAlign: TextAlign.center),
                    if (phase == projectTestPhase) ...[
                      const SizedBox(height: 8),
                      Text(widget.level['criterion'] as String,
                          style: text.titleLarge?.copyWith(color: MiraboColors.navy), textAlign: TextAlign.center),
                    ] else ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _note,
                        maxLength: projectNoteMax,
                        maxLines: 2,
                        decoration: InputDecoration(hintText: context.l10n.projectNoteHint, border: const OutlineInputBorder()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: phase == projectTestPhase
              ? Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ChunkyButton(
                        icon: Icons.check_rounded,
                        label: context.l10n.projectHeld,
                        color: MiraboColors.leaf,
                        onPressed: () => _done(phase, result: 'held')),
                    ChunkyButton(
                        icon: Icons.build_rounded,
                        label: context.l10n.projectNotYet,
                        color: MiraboColors.sky,
                        onPressed: () => _done(phase, result: 'notyet')),
                  ],
                )
              : ChunkyButton(
                  icon: Icons.arrow_forward_rounded,
                  label: i + 1 >= roundCount ? context.l10n.projectFinish : context.l10n.projectNext,
                  color: MiraboColors.leaf,
                  onPressed: () => _done(phase)),
        ),
      ],
    );
  }
}
