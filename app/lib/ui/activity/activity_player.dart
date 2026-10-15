import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../audio/child_name.dart';
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

  /// Il testo con il nome del bambino; fuori dall'MVP senza nome (audio/child_name.dart).
  String withName(String s) => fillName(s, profile.name);
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
  int _run = 0;

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
        try {
          await _tts.stop();
          await _tts.speak(_ctx.withName(t));
        } catch (_) {
          // Senza voce di sistema il testo resta in vista (vedi MiraboTokens.voiceMissing).
        }
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

  /// Scelta facoltativa a fine attività: cambia solo il livello (una dimensione),
  /// la stessa attività riparte con la stessa voce e gli stessi aiuti.
  /// [delta] 0 = "ancora così": ripete fedelmente lo stesso livello.
  Future<void> _again(int delta) async {
    final max = widget.activity.levels.length;
    var p = (await _state.db.progress(_profile.id, widget.activity.id));
    if (delta != 0) p = await _state.setActivityLevel(p, p.level + delta, max);
    if (!mounted) return;
    setState(() {
      _progress = p;
      _results.clear();
      _saved = false;
      _run++;
      _phase = _Phase.rounds;
    });
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
          button: context.l10n.outroDone,
          onPressed: () => Navigator.of(context).pop(),
          extra: _LevelChoices(
            canEasier: progress.level > 1,
            canHarder: progress.level < widget.activity.levels.length,
            onChoose: _again,
            say: _ctx.say,
          ),
        ),
      _Phase.rounds => KeyedSubtree(key: ValueKey(_run), child: _buildRounds(level)),
    };

    return ExitGuard(
      say: _ctx.say,
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
                      onPressed: () => leaveChildPage(context, say: _ctx.say),
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

/// "Più semplice / Ancora così / Più sfida": tre bottoni con il loro
/// altoparlante, mai obbligatori: "Fatto" chiude comunque.
class _LevelChoices extends StatelessWidget {
  const _LevelChoices({required this.canEasier, required this.canHarder, required this.onChoose, required this.say});
  final bool canEasier;
  final bool canHarder;
  final Future<void> Function(int delta) onChoose;
  final Future<void> Function(String text) say;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget choice(IconData icon, String label, int delta, bool enabled, Color color) => SpokenButton(
          label: label,
          icon: icon,
          color: color,
          onPressed: enabled ? () => onChoose(delta) : null,
          onListen: () => say(label),
        );
    return Wrap(
      spacing: 18,
      runSpacing: 12,
      children: [
        choice(Icons.arrow_downward_rounded, l.levelEasier, -1, canEasier, MiraboColors.navy),
        choice(Icons.replay_rounded, l.levelSame, 0, true, MiraboColors.leaf),
        choice(Icons.arrow_upward_rounded, l.levelHarder, 1, canHarder, MiraboColors.sun),
      ],
    );
  }
}

class _CompanionSays extends StatelessWidget {
  const _CompanionSays({
    required this.companion,
    required this.stage,
    required this.text,
    required this.button,
    required this.onPressed,
    this.extra,
  });
  final Widget? extra;
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
                    if (extra != null) ...[const SizedBox(height: 20), extra!],
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

  int _announcedFor = -1;
  String? _prompt;
  Timer? _repeat;

  /// Aiuto a richiesta, a piccoli passi: 0 = nessuno, 1 = consegna ripetuta,
  /// 2 = elemento indicato, 3 = breve dimostrazione a voce. Il tablet non
  /// completa mai il round da solo: dopo ogni passo il bambino prova.
  int helpStep = 0;
  static const helpSteps = 3;
  final Map<int, List<Object?>> _picked = {};

  /// La consegna del round: detta all'inizio e, con autonomia 1, ripetuta se il
  /// bambino non tocca niente. Si chiama da buildRound: parla una volta per round.
  void announce(String text) {
    if (_announcedFor == index) return;
    _announcedFor = index;
    _prompt = text;
    _repeat?.cancel();
    _repeat = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.ctx.say(text);
    });
    final tokens = MiraboTokens.of(context);
    if (tokens.repeatPrompt) {
      var left = tokens.maxPromptRepeats;
      _repeat = Timer.periodic(repeatEvery, (t) {
        if (!mounted || lastCorrect == true || left-- <= 0) return t.cancel();
        widget.ctx.say(text);
      });
    }
  }

  /// Il comando "Aiuto": ogni tocco porta al passo successivo (ripete la
  /// consegna, indica l'elemento, mostra a voce). Dopo l'ultimo ricomincia dalla consegna.
  void askHelp() {
    if (lastCorrect == true) return;
    _repeat?.cancel();
    final l10n = context.l10n;
    setState(() {
      helpStep = helpStep >= helpSteps ? 1 : helpStep + 1;
      // L'indicazione conta come aiuto usato, ma non risolve nulla.
      if (helpStep >= 2 && hints == 0) hints = 1;
    });
    widget.ctx.say(switch (helpStep) {
      1 => _prompt ?? l10n.activityHelp,
      2 => l10n.activityHelpPoint,
      _ => l10n.activityHelpDemo,
    });
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
      widget.onRound(RoundResult(choice: choice));
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
    widget.onRound(RoundResult(choice: choice));
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
      helpStep = 0;
      lastCorrect = null;
    });
  }

  /// Dopo due errori il round mostra la risposta: true quando l'aiuto è attivo.
  bool get showHint => hints > 0;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(child: buildRound(context, index)),
          // Il comando Aiuto sta sempre nello stesso posto (in basso a destra).
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              children: [
                const SizedBox(width: 60),
                Expanded(child: Center(child: StepDots(count: roundCount, current: index, color: MiraboColors.navy))),
                if (_prompt != null)
                  RoundIconButton(icon: Icons.lightbulb_outline_rounded, tooltip: context.l10n.activityHelpButton, onPressed: askHelp)
                else
                  const SizedBox(width: 60),
              ],
            ),
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
    // Scritta grande (20 px in grassetto): sul verde si legge l'inchiostro.
    final fg = selected ? MiraboColors.onColor(green, large: true) : MiraboColors.ink;
    // Per chi non legge solo la figura; la scritta resta per lo screen reader.
    final label = tokens.textMode.showsLabels ? this.label : null;
    final size = onTap == null ? this.size : math.max(this.size, tokens.minTarget);
    return AnimatedOpacity(
      duration: tokens.animate ? const Duration(milliseconds: 250) : Duration.zero,
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
                color: tokens.tint(MiraboColors.navy),
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
