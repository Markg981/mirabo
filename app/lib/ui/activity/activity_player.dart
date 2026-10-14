import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../models/activity.dart';
import '../../models/profile.dart';
import '../../content/story_repository.dart';
import '../child/companion_widget.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'types/checklist_round.dart';
import 'types/count_round.dart';
import 'types/countdown_round.dart';
import 'types/explore_round.dart';
import 'types/hunt_round.dart';
import 'types/pairs_round.dart';
import 'types/pattern_round.dart';
import 'types/presentation_round.dart';
import 'types/project_round.dart';
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

/// Al massimo [max] opzioni per round (asse autonomia): le giuste restano
/// (almeno una, anche quando sono più di quante ne stanno), le altre si
/// scelgono a caso. L'ordine resta quello del file. Per i tipi senza risposta
/// giusta si tengono [max] opzioni a caso.
List<T> pickOptions<T>(List<T> options, bool Function(T option) isCorrect, int max, {math.Random? random}) {
  if (options.length <= max) return options;
  final correct = [for (var i = 0; i < options.length; i++) if (isCorrect(options[i])) i]..shuffle(random);
  final wrong = [for (var i = 0; i < options.length; i++) if (!isCorrect(options[i])) i]..shuffle(random);
  final keepWrong = correct.isEmpty ? max : math.min(wrong.length, math.max(1, max - correct.length));
  final keep = {...correct.take(max - keepWrong), ...wrong.take(keepWrong)};
  return [for (var i = 0; i < options.length; i++) if (keep.contains(i)) options[i]];
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
    _tts.setLanguage(AppLanguage.fromCode(_profile.language).ttsCode);
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
          button: context.l10n.go,
          onPressed: () => setState(() => _phase = _Phase.rounds),
        ),
      _Phase.outro => _CompanionSays(
          companion: companion,
          stage: _profile.companionStage,
          text: _ctx.withName(widget.activity.outro.forCompanion(_profile.companion)),
          button: context.l10n.seeYouTomorrow,
          onPressed: () => Navigator.of(context).pop(),
        ),
      _Phase.rounds => _buildRounds(level),
    };

    return ExitGuard(
      child: Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.close_rounded,
                      tooltip: context.l10n.close,
                      onPressed: () => leaveChildPage(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.activity.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: MiraboColors.navy),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_phase != _Phase.rounds)
                      RoundIconButton(
                        icon: Icons.volume_up_rounded,
                        tooltip: context.l10n.readAgain,
                        onPressed: () => _ctx.say(_phase == _Phase.intro
                            ? widget.activity.intro.forCompanion(_profile.companion)
                            : widget.activity.outro.forCompanion(_profile.companion)),
                      ),
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
      ),
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
      ActivityType.hunt => HuntRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
      ActivityType.project => ProjectRound(level: level, ctx: _ctx, onRound: _onRound, onFinished: _finish),
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
        constraints: const BoxConstraints(maxWidth: 860),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CompanionWidget(companion: companion, stage: stage, size: 240),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SpeechBubble(
                      tail: TailSide.left,
                      tailAt: 0.7,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                      child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 24)),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: ChunkyButton(
                        label: button,
                        icon: Icons.play_arrow_rounded,
                        color: MiraboColors.leaf,
                        onPressed: onPressed,
                      ),
                    ),
                  ],
                ),
              ),
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

  /// Ogni quanto si ripete la consegna se il bambino non tocca niente
  /// (autonomia 1), e quante volte al massimo.
  static const repeatEvery = Duration(seconds: 15);
  static const maxRepeats = 2;

  int _announcedFor = -1;
  Timer? _repeat;
  final Map<int, List<Object?>> _picked = {};

  /// La consegna del round: detta all'inizio e, con autonomia 1, ripetuta se il
  /// bambino non tocca niente. Si chiama da buildRound: parla una volta per round.
  void announce(String text) {
    if (_announcedFor == index) return;
    _announcedFor = index;
    _repeat?.cancel();
    _repeat = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.ctx.say(text);
    });
    if (MiraboTokens.of(context).repeatPrompt) {
      var left = maxRepeats;
      _repeat = Timer.periodic(repeatEvery, (t) {
        if (!mounted || lastCorrect == true || left-- <= 0) return t.cancel();
        widget.ctx.say(text);
      });
    }
  }

  /// Le opzioni di questo round, tagliate a MiraboTokens.maxOptions. La scelta
  /// resta la stessa per tutto il round.
  List<E> options<E>(List<E> all, bool Function(E option) isCorrect) =>
      (_picked[index] ??= pickOptions<E>(all, isCorrect, MiraboTokens.of(context).maxOptions)) as List<E>;

  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  /// Chiamata dal round quando il bambino risponde: da qui la consegna si
  /// ripete solo se la chiede lui.
  void answer(bool correct, {String? choice}) {
    attempts++;
    _repeat?.cancel();
    if (correct) {
      setState(() => lastCorrect = true);
      widget.onRound(RoundResult(attempts: attempts, hints: hints, choice: choice));
      Future.delayed(const Duration(milliseconds: 900), next);
    } else {
      setState(() {
        lastCorrect = false;
        if (attempts >= 2) hints++;
      });
      widget.ctx.say(attempts == 1 ? context.l10n.activityTryAgain : context.l10n.activityHelp);
    }
  }

  /// Per i tipi senza risposta giusta (scene, checklist, esplora).
  void complete({String? choice}) {
    widget.onRound(RoundResult(attempts: 1, hints: 0, choice: choice));
    next();
  }

  void next() {
    if (!mounted) return;
    _repeat?.cancel();
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
            padding: const EdgeInsets.only(bottom: 14),
            child: StepDots(count: roundCount, current: index, color: MiraboColors.navy),
          ),
        ],
      );
}

/// Tessera grande con emoji e, se c'è, etichetta. Riutilizzata da più tipi.
/// Selezionata diventa verde con la spunta; con l'aiuto attivo ha un alone giallo.
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
    final tokens = MiraboTokens.of(context);
    final green = tokens.tint(MiraboColors.leaf);
    final gold = tokens.tint(MiraboColors.sun);
    final fg = selected ? Colors.white : MiraboColors.ink;
    // Per chi non legge solo la figura; la scritta resta per lo screen reader.
    final label = tokens.textMode.showsLabels ? this.label : null;
    final size = onTap == null ? this.size : math.max(this.size, tokens.minTarget);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: dimmed ? 0.3 : 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BlockTile(
            onTap: onTap,
            width: size,
            height: size,
            color: selected ? green : MiraboColors.paper,
            border: highlight ? Border.all(color: gold, width: 5) : null,
            semanticLabel: this.label ?? emoji,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: TextStyle(fontSize: size * (label == null ? 0.5 : 0.4))),
                if (label != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: fg),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (selected)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: green, width: 3),
                ),
                child: Icon(Icons.check_rounded, color: green, size: 26),
              ),
            ),
        ],
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
    final tokens = MiraboTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 24, 10),
        decoration: BoxDecoration(
          color: MiraboColors.paper,
          borderRadius: BorderRadius.circular(999),
          boxShadow: softShadow(),
        ),
        child: Row(
          children: [
            Tooltip(
              message: context.l10n.listenAgain,
              child: Material(
                color: tokens.tint(MiraboColors.sky),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSay,
                  child: SizedBox.square(
                    dimension: tokens.minTarget,
                    child: Icon(Icons.volume_up_rounded, size: tokens.minTarget * 0.54, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Per chi non legge ancora le frasi la consegna arriva solo a voce.
            Expanded(
              child: tokens.textMode.showsText
                  ? Text(text, style: Theme.of(context).textTheme.titleLarge)
                  : Semantics(label: text, child: const SizedBox(height: 1)),
            ),
          ],
        ),
      ),
    );
  }
}
