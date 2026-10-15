import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../app_state.dart';
import '../../audio/child_name.dart';
import '../../features.dart';
import '../../l10n/l10n.dart';
import '../../models/made_story.dart';
import '../../models/profile.dart';
import '../../models/read_along.dart';
import '../../models/story.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'companion_widget.dart';
import 'read_along_text.dart';
import 'scene_illustration.dart';
import 'story_reader.dart' show IllustrationFrame;

/// Voce del compagno per le schermate della fabbrica, nella lingua del bambino.
FlutterTts _voiceFor(ChildProfile p) => FlutterTts()
  ..setLanguage(AppLanguage.fromCode(p.language).ttsCode)
  ..setSpeechRate(0.45);

/// Fabbrica di storie: il bambino inventa una storia scegliendo sei pezzi
/// (chi, dove, cosa succede, come si sente, chi aiuta, come finisce) e
/// l'app la compone, la illustra con la scena e la legge. Le storie restano
/// in "Le mie storie" e il genitore le può stampare come libretto.
class StoryFactoryScreen extends StatefulWidget {
  const StoryFactoryScreen({super.key});

  @override
  State<StoryFactoryScreen> createState() => _StoryFactoryScreenState();
}

class _StoryFactoryScreenState extends State<StoryFactoryScreen> {
  late Future<List<MadeStory>> _mine = _load();

  Future<List<MadeStory>> _load() {
    final state = AppStateScope.read(context);
    return state.madeStoriesOf(state.currentProfile!);
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    setState(() {
      _mine = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(title: l.factoryTitle, emoji: '✨'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CompanionWidget(companion: state.companionOf(profile), stage: profile.companionStage, size: 130),
                    const SizedBox(width: 8),
                    ChunkyButton(
                      label: l.factoryNew,
                      icon: Icons.auto_fix_high_rounded,
                      color: MiraboColors.plum,
                      onPressed: () => _open(const SessionHold(child: _FactoryBuilder())),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l.factoryMine, style: text.titleLarge?.copyWith(color: MiraboColors.navy)),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<MadeStory>>(
                    future: _mine,
                    builder: (context, snap) {
                      final mine = snap.data ?? const <MadeStory>[];
                      if (snap.connectionState == ConnectionState.done && mine.isEmpty) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: SoftPanel(child: Text(l.factoryMineEmpty, style: text.titleMedium)),
                        );
                      }
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: mine.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) => _MadeStoryCard(
                          story: mine[i],
                          onTap: () => _open(SessionHold(child: MadeStoryReader(story: mine[i]))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.emoji, this.trailing});
  final String title;
  final String emoji;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundIconButton(icon: Icons.close_rounded, tooltip: context.l10n.close, onPressed: () => Navigator.of(context).pop()),
        const SizedBox(width: 16),
        Text(emoji, style: const TextStyle(fontSize: 34)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: MiraboColors.navy),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MadeStoryCard extends StatelessWidget {
  const _MadeStoryCard({required this.story, required this.onTap});
  final MadeStory story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = story.titleIn(context.l10n);
    return BlockTile(
      onTap: onTap,
      width: 220,
      color: MiraboColors.paper,
      padding: const EdgeInsets.all(16),
      semanticLabel: title,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${story.emoji(FactoryStep.who)}${story.emoji(FactoryStep.problem)}${story.emoji(FactoryStep.helper)}',
            style: const TextStyle(fontSize: 44),
          ),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Le scelte, una alla volta: il compagno fa la domanda, il bambino tocca
/// una figura e sente il suo nome. In fascia 8–10 alla fine dà il titolo.
class _FactoryBuilder extends StatefulWidget {
  const _FactoryBuilder();

  @override
  State<_FactoryBuilder> createState() => _FactoryBuilderState();
}

class _FactoryBuilderState extends State<_FactoryBuilder> {
  late final ChildProfile _profile = AppStateScope.read(context).currentProfile!;
  late final FlutterTts _tts = _voiceFor(_profile);
  final Map<FactoryStep, String> _parts = {};
  final _title = TextEditingController();
  int _step = 0;
  bool _saving = false;

  bool get _asksTitle => _profile.ageBand == AgeBand.b8to10;
  int get _count => FactoryStep.values.length + (_asksTitle ? 1 : 0);
  bool get _onTitle => _step == FactoryStep.values.length;
  bool get _isLast => _step == _count - 1;
  FactoryStep? get _current => _onTitle ? null : FactoryStep.values[_step];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ask());
  }

  @override
  void dispose() {
    _tts.stop();
    _title.dispose();
    super.dispose();
  }

  Future<void> _say(String line) async {
    await _tts.stop();
    await _tts.speak(line);
  }

  void _ask() {
    final step = _current;
    _say(step == null ? context.l10n.factoryNameIt : context.l10n.factoryAsk(step.name));
  }

  void _pick(FactoryStep step, String id) {
    setState(() => _parts[step] = id);
    _say(StoryParts.label(context.l10n, step, id));
  }

  void _go(int step) {
    setState(() => _step = step);
    _ask();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final state = AppStateScope.read(context);
    final saved = await state.saveMadeStory(MadeStory(
      profileId: _profile.id,
      title: _asksTitle ? _title.text.trim() : null,
      parts: Map.of(_parts),
      when: DateTime.now(),
    ));
    if (!mounted) return;
    await _tts.stop();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SessionHold(child: MadeStoryReader(story: saved, justMade: true))));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = AppStateScope.of(context);
    final step = _current;
    final canGo = step == null || _parts.containsKey(step);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                _TopBar(
                  title: l.factoryTitle,
                  emoji: '✨',
                  trailing: RoundIconButton(icon: Icons.volume_up_rounded, tooltip: l.readAgain, onPressed: _ask),
                ),
                const SizedBox(height: 8),
                StepDots(count: _count, current: _step, color: MiraboColors.navy),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CompanionWidget(companion: state.companionOf(_profile), stage: _profile.companionStage, size: 96),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SpeechBubble(
                        tail: TailSide.left,
                        tailAt: 0.8,
                        child: Text(step == null ? l.factoryNameIt : l.factoryAsk(step.name), style: text.titleLarge),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: step == null
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: TextField(
                              controller: _title,
                              maxLength: 40,
                              textCapitalization: TextCapitalization.sentences,
                              style: text.headlineSmall,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: MiraboColors.paper,
                                hintText: capitalize(l.factoryWhoThe(_parts[FactoryStep.who]!)),
                              ),
                            ),
                          ),
                        )
                      : _Choices(step: step, selected: _parts[step], onPick: (id) => _pick(step, id)),
                ),
                Row(
                  children: [
                    if (_step > 0)
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l.back,
                        size: 64,
                        onPressed: () => _go(_step - 1),
                      ),
                    const Spacer(),
                    ChunkyButton(
                      label: _isLast ? l.factoryRead : l.next,
                      icon: _isLast ? Icons.auto_stories_rounded : Icons.arrow_forward_rounded,
                      iconAfter: !_isLast,
                      color: _isLast ? MiraboColors.plum : MiraboColors.leaf,
                      onPressed: !canGo || _saving ? null : (_isLast ? _finish : () => _go(_step + 1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices({required this.step, required this.selected, required this.onPick});
  final FactoryStep step;
  final String? selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final accent = MiraboTokens.of(context).tint(MiraboColors.plum);
    final parts = StoryParts.of(step);
    return LayoutBuilder(builder: (context, c) {
      // Tutte le figure in vista, senza scorrere: tre per riga.
      final rows = (parts.length / 3).ceil();
      final side = ((c.maxHeight - 24 * rows) / rows).clamp(90.0, 170.0);
      return Center(
        child: Wrap(
          spacing: 18,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (final p in parts)
              BlockTile(
                onTap: () => onPick(p.id),
                width: side * 1.25,
                height: side,
                radius: 24,
                depth: 6,
                color: selected == p.id ? MiraboColors.pale(accent, 0.6) : MiraboColors.paper,
                border: Border.all(color: selected == p.id ? accent : MiraboColors.line, width: selected == p.id ? 3 : 1.5),
                semanticLabel: StoryParts.label(l, step, p.id),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: FittedBox(child: Text(p.emoji, style: const TextStyle(fontSize: 64)))),
                    Text(
                      StoryParts.label(l, step, p.id),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// Lettore di una storia inventata: la scena, il testo in karaoke e la voce.
/// Alla fine "Fine" e chi l'ha inventata.
class MadeStoryReader extends StatefulWidget {
  const MadeStoryReader({super.key, required this.story, this.justMade = false});
  final MadeStory story;

  /// Appena uscita dalla fabbrica: alla fine il compagno dice che la conserva.
  final bool justMade;

  @override
  State<MadeStoryReader> createState() => _MadeStoryReaderState();
}

class _MadeStoryReaderState extends State<MadeStoryReader> {
  late final ChildProfile _profile = AppStateScope.read(context).currentProfile!;
  late final FlutterTts _tts = _voiceFor(_profile);
  late List<MadePage> _pages;
  late MadeStory _story = widget.story;
  int _index = 0;
  int _word = -1;
  bool _readsText = false;

  /// L'ultima pagina è "Fine": non ha scena, solo il titolo e l'autore.
  bool get _onEnd => _index == _pages.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = _story.pages(context.l10n);
  }

  @override
  void initState() {
    super.initState();
    if (_profile.readAlong) {
      _tts.setProgressHandler((_, start, __, ___) {
        if (_readsText && !_onEnd) _highlight(wordAtChar(readAlongWords(_pages[_index].text), start));
      });
      _tts.setCompletionHandler(() => _highlight(-1));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _highlight(int w) {
    if (mounted && w != _word) setState(() => _word = w);
  }

  Future<void> _say(String line, {bool text = false}) async {
    _readsText = false;
    _highlight(-1);
    await _tts.stop();
    _readsText = text;
    await _tts.speak(line);
  }

  void _read() {
    final l = context.l10n;
    if (!_onEnd) {
      _say(_pages[_index].text, text: true);
    } else {
      _say([
        l.factoryEnd,
        // "Una storia inventata da …" senza nome non dice niente: si salta.
        if (Features.spokenName) l.factoryBy(_profile.name),
        if (widget.justMade) spokenWithName(l.factoryDone, _profile.name),
      ].join('. '));
    }
  }

  void _go(int i) {
    setState(() => _index = i);
    _read();
  }

  /// 8–10: sull'ultima pagina si provano gli altri finali e si confrontano.
  /// La scelta resta solo per questa lettura: la storia salvata non cambia.
  bool get _comparesEndings => _profile.ageBand == AgeBand.b8to10 && _index == _pages.length - 1;

  void _tryEnding(String id) {
    setState(() {
      _story = _story.withEnding(id);
      _pages = _story.pages(context.l10n);
    });
    _read();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = AppStateScope.of(context);
    final companion = state.companionOf(_profile);
    final text = Theme.of(context).textTheme;
    final accent = MiraboTokens.of(context).tint(MiraboColors.plum);

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                _TopBar(
                  title: widget.story.titleIn(l),
                  emoji: widget.story.emoji(FactoryStep.who),
                  trailing: RoundIconButton(icon: Icons.volume_up_rounded, tooltip: l.readAgain, onPressed: _read),
                ),
                const SizedBox(height: 8),
                StepDots(count: _pages.length + 1, current: _index, color: MiraboColors.navy),
                const SizedBox(height: 14),
                Expanded(
                  child: _onEnd
                      ? Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CompanionWidget(companion: companion, stage: _profile.companionStage, size: 200),
                              const SizedBox(width: 12),
                              Flexible(
                                child: SpeechBubble(
                                  tail: TailSide.left,
                                  tailAt: 0.6,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l.factoryEnd, style: text.displaySmall?.copyWith(color: MiraboColors.navy)),
                                      const SizedBox(height: 6),
                                      Text(l.factoryBy(_profile.name), style: text.titleLarge),
                                      if (widget.justMade) ...[
                                        const SizedBox(height: 10),
                                        Text(l.factoryDone(_profile.name), style: text.bodyLarge),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: IllustrationFrame(
                                alt: _pages[_index].text,
                                color: accent,
                                child: SceneIllustration(
                                  key: ValueKey(_index),
                                  scene: _pages[_index].scene,
                                  companion: companion,
                                  stage: _profile.companionStage,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 4,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: SoftPanel(
                                  padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
                                  child: SingleChildScrollView(
                                    child: ReadAlongText(
                                      text: _pages[_index].text,
                                      current: _word,
                                      enabled: _profile.readAlong,
                                      onWord: _say,
                                      style: text.bodyLarge?.copyWith(fontSize: 26),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                if (_comparesEndings) ...[
                  const SizedBox(height: 8),
                  Text(l.factoryOtherEnding, style: text.titleMedium),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: [
                      for (final p in StoryParts.ending)
                        ChoiceChip(
                          label: Text('${p.emoji} ${StoryParts.label(l, FactoryStep.ending, p.id)}'),
                          selected: _story.part(FactoryStep.ending) == p.id,
                          onSelected: (_) => _tryEnding(p.id),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_index > 0)
                      RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: l.back, size: 64, onPressed: () => _go(_index - 1)),
                    const Spacer(),
                    ChunkyButton(
                      label: _onEnd ? l.outroDone : l.next,
                      icon: _onEnd ? Icons.waving_hand_rounded : Icons.arrow_forward_rounded,
                      iconAfter: !_onEnd,
                      color: _onEnd ? MiraboColors.apricot : MiraboColors.leaf,
                      onPressed: _onEnd ? () => Navigator.of(context).pop() : () => _go(_index + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
