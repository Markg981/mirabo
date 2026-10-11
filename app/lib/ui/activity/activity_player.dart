import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../app_state.dart';
import '../../models/activity.dart';
import '../../models/profile.dart';
import '../../content/story_repository.dart';
import '../child/companion_widget.dart';
import 'types/checklist_round.dart';
import 'types/count_round.dart';
import 'types/countdown_round.dart';
import 'types/explore_round.dart';
import 'types/pairs_round.dart';
import 'types/pattern_round.dart';
import 'types/presentation_round.dart';
import 'types/scene_choice_round.dart';
import 'types/sequence_round.dart';
import 'types/spell_round.dart';
import 'types/tap_match_round.dart';
import 'types/trace_round.dart';

/// Contesto condiviso con i widget dei round: voce, nome, compagno.
class ActivityContext {
  ActivityContext({required this.profile, required this.companionName, required this.say});
  final ChildProfile profile;
  final String companionName;
  final Future<void> Function(String text) say;

  String withName(String s) => s.replaceAll('{nome}', profile.name);
}

/// Chi esegue un round chiama [onDone] una volta sola con il risultato.
typedef RoundDone = void Function(RoundResult result);

/// Esegue un'attività: intro del compagno, i round del livello corrente, saluto.
/// I widget dei tipi sono intercambiabili: ricevono il JSON del livello e un
/// callback per ogni round completato.
class ActivityPlayer extends StatefulWidget {
  const ActivityPlayer({super.key, required this.activity});
  final Activity activity;

  @override
  State<ActivityPlayer> createState() => _ActivityPlayerState();
}

enum _Phase { intro, rounds, outro }

class _ActivityPlayerState extends State<ActivityPlayer> {
  final _tts = FlutterTts();
  late final AppState _state;
  late final ChildProfile _profile;
  late final ActivityContext _ctx;
  ActivityProgress? _progress;
  final List<RoundResult> _results = [];
  _Phase _phase = _Phase.intro;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _state = AppStateScope.read(context);
    _profile = _state.currentProfile!;
    _tts.setLanguage('it-IT');
    _tts.setSpeechRate(0.45);
    _ctx = ActivityContext(
      profile: _profile,
      companionName: _state.companionOf(_profile).name,
      say: (t) async {
        await _tts.stop();
        await _tts.speak(_ctx.withName(t));
      },
    );
    _state.db.progress(_profile.id, widget.activity.id).then((p) {
      if (!mounted) return;
      setState(() => _progress = p);
      _ctx.say(widget.activity.intro.forCompanion(_profile.companion));
    });
  }

  @override
  void dispose() {
    _tts.stop();
    if (!_saved && _progress != null) _state.recordActivity(widget.activity, _progress!, _results);
    super.dispose();
  }

  void _onRound(RoundResult r) => _results.add(r);

  Future<void> _finish() async {
    _saved = true;
    await _state.recordActivity(widget.activity, _progress!, _results);
    if (!mounted) return;
    setState(() => _phase = _Phase.outro);
    _ctx.say(widget.activity.outro.forCompanion(_profile.companion));
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    if (progress == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final companion = _state.companionOf(_profile);
    final level = widget.activity.level(progress.level);

    Widget body = switch (_phase) {
      _Phase.intro => _CompanionSays(
          companion: companion,
          stage: _profile.companionStage,
          text: _ctx.withName(widget.activity.intro.forCompanion(_profile.companion)),
          button: 'Via!',
          onPressed: () => setState(() => _phase = _Phase.rounds),
        ),
      _Phase.outro => _CompanionSays(
          companion: companion,
          stage: _profile.companionStage,
          text: _ctx.withName(widget.activity.outro.forCompanion(_profile.companion)),
          button: 'A domani!',
          onPressed: () => Navigator.of(context).pop(),
        ),
      _Phase.rounds => _buildRounds(level),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.title),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            tooltip: 'Rileggi',
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => _ctx.say(_phase == _Phase.intro
                ? widget.activity.intro.forCompanion(_profile.companion)
                : widget.activity.outro.forCompanion(_profile.companion)),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _buildRounds(Map<String, dynamic> level) {
    final a = widget.activity;
    return switch (a.type) {
      ActivityType.tapMatch => TapMatchRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.count => CountRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.sequence => SequenceRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.pattern => PatternRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.trace => TraceRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.checklist => ChecklistRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.sceneChoice => SceneChoiceRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.explore => ExploreRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.countdown => CountdownRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.presentation => PresentationRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.pairs => PairsRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.spell => SpellRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
    };
  }
}

class _CompanionSays extends StatelessWidget {
  const _CompanionSays({
    required this.companion,
    required this.stage,
    required this.text,
    required this.button,
    required this.onPressed,
  });
  final Companion companion;
  final int stage;
  final String text;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CompanionWidget(companion: companion, stage: stage, size: 160),
              const SizedBox(height: 24),
              Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              FilledButton(onPressed: onPressed, child: Text(button)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Base comune ai widget dei round: scorre i round del livello, tiene i tentativi.
abstract class RoundWidget extends StatefulWidget {
  const RoundWidget({
    super.key,
    required this.level,
    required this.ctx,
    required this.onRound,
    required this.onFinished,
  });
  final Map<String, dynamic> level;
  final ActivityContext ctx;
  final RoundDone onRound;
  final VoidCallback onFinished;
}

/// Stato condiviso dai tipi "a round": indice, tentativi, aiuti; sottoclassi
/// implementano [roundCount] e [buildRound].
abstract class RoundState<T extends RoundWidget> extends State<T> {
  int index = 0;
  int attempts = 0;
  int hints = 0;
  bool? lastCorrect;

  int get roundCount;
  Widget buildRound(BuildContext context, int index);

  /// Chiamata dal round quando il bambino risponde.
  void answer(bool correct, {String? choice}) {
    attempts++;
    if (correct) {
      setState(() => lastCorrect = true);
      widget.onRound(RoundResult(attempts: attempts, hints: hints, choice: choice));
      Future.delayed(const Duration(milliseconds: 900), next);
    } else {
      setState(() {
        lastCorrect = false;
        if (attempts >= 2) hints++;
      });
      widget.ctx.say(attempts == 1 ? 'Riprova.' : 'Guarda bene. Ti aiuto io.');
    }
  }

  /// Per i tipi senza risposta giusta (scene, checklist, esplora).
  void complete({String? choice}) {
    widget.onRound(RoundResult(attempts: 1, hints: 0, choice: choice));
    next();
  }

  void next() {
    if (!mounted) return;
    if (index + 1 >= roundCount) {
      widget.onFinished();
      return;
    }
    setState(() {
      index++;
      attempts = 0;
      hints = 0;
      lastCorrect = null;
    });
  }

  /// Dopo due errori il round mostra la risposta: true quando l'aiuto è attivo.
  bool get showHint => hints > 0;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(child: buildRound(context, index)),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('${index + 1} / $roundCount', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      );
}

/// Tessera grande con emoji e, se c'è, etichetta. Riutilizzata da più tipi.
class PicTile extends StatelessWidget {
  const PicTile({
    super.key,
    required this.emoji,
    this.label,
    this.onTap,
    this.selected = false,
    this.dimmed = false,
    this.highlight = false,
    this.size = 140,
  });
  final String emoji;
  final String? label;
  final VoidCallback? onTap;
  final bool selected;
  final bool dimmed;
  final bool highlight;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: onTap != null,
      label: label ?? emoji,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: dimmed ? 0.3 : 1,
        child: Material(
          color: selected ? scheme.primaryContainer : scheme.surface,
          borderRadius: BorderRadius.circular(24),
          elevation: highlight ? 6 : 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  width: 3,
                  color: highlight ? scheme.primary : (selected ? scheme.primary : scheme.outlineVariant),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: TextStyle(fontSize: size * 0.42)),
                  if (label != null) ...[
                    const SizedBox(height: 4),
                    Text(label!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Riga con la consegna e il tasto per riascoltarla.
class PromptBar extends StatelessWidget {
  const PromptBar({super.key, required this.text, required this.onSay});
  final String text;
  final VoidCallback onSay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.volume_up_rounded, size: 32), onPressed: onSay, tooltip: 'Riascolta'),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
        ],
      ),
    );
  }
}
