import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/l10n.dart';
import '../../models/themes.dart';
import '../activity/activity_player.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'category_widgets.dart';
import 'child_top_bar.dart';
import 'companion_widget.dart';
import 'story_reader.dart';
import 'themes_style.dart';

/// Un tema: le sue tre modalità una accanto all'altra, sempre nello stesso
/// ordine (storia, gioco, cosa da provare) e con il colore del tema, così si
/// vede che parlano della stessa cosa. Ogni esperienza si apre subito, senza
/// aver finito le altre; chiudendola si torna qui.
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key, required this.theme});
  final ChildTheme theme;

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  final _voice = ShortVoice();

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  void _open(Widget page) {
    if (ModalRoute.of(context)?.isCurrent == false) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openExperience(ThemeExperience e) => switch (e) {
        ThemeStory(:final story) => _open(SessionHold(child: StoryReader(story: story))),
        ThemeActivity(:final activity) => _open(SessionHold(child: ActivityPlayer(activity: activity))),
        ThemePractice() => _open(SessionHold(child: PracticeScreen(practice: e, theme: widget.theme))),
      };

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final modes = state.themeFor(profile, widget.theme);
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final name = widget.theme.label(l);

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              ChildTopBar(
                exitIcon: Icons.home_rounded,
                exitTooltip: l.home,
                onExit: () => Navigator.of(context).pop(),
                onListen: () => _voice.say(profile.language, [name, for (final m in ExperienceMode.values) m.label(l)].join('. ')),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.theme.emojis.first, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(name,
                          style: text.headlineMedium?.copyWith(color: MiraboColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Expanded(
                // Limite vicino: niente di nuovo da iniziare, come sulla mensola.
                child: state.windingDown
                    ? const Center(child: WinddownNote())
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final m in ExperienceMode.values)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: _ModeColumn(
                                    mode: m,
                                    color: widget.theme.color,
                                    experiences: modes[m] ?? const [],
                                    onOpen: _openExperience,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una modalità del tema: l'intestazione con icona e nome, sotto le sue
/// esperienze. Se il tema non ne ha ancora, il posto resta (le modalità non
/// si spostano) ma non si tocca.
class _ModeColumn extends StatelessWidget {
  const _ModeColumn({required this.mode, required this.color, required this.experiences, required this.onOpen});
  final ExperienceMode mode;
  final Color color;
  final List<ThemeExperience> experiences;
  final ValueChanged<ThemeExperience> onOpen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final tint = MiraboTokens.of(context).tint(color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.94), borderRadius: BorderRadius.circular(999)),
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: tint, child: Icon(mode.icon, color: Colors.white, size: 24)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(mode.label(l),
                      style: text.titleLarge?.copyWith(color: MiraboColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: experiences.isEmpty
              ? Opacity(
                  opacity: 0.55,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(mode.icon, size: 56, color: MiraboColors.inkSoft),
                      const SizedBox(height: 8),
                      Text(l.modeComing, style: text.titleMedium?.copyWith(color: MiraboColors.inkSoft), textAlign: TextAlign.center),
                    ]),
                  ),
                )
              : LayoutBuilder(builder: (context, box) {
                  const gap = 14.0;
                  final n = experiences.length;
                  // Una carta riempie la colonna; con più carte si dividono lo spazio
                  // finché restano grandi, poi si scorre.
                  final h = math.max(150.0, (box.maxHeight - gap * (n - 1)) / n);
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: n,
                    separatorBuilder: (_, __) => const SizedBox(height: gap),
                    itemBuilder: (_, i) => SizedBox(height: h, child: _card(context, experiences[i], box.maxWidth)),
                  );
                }),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, ThemeExperience e, double width) {
    final l = context.l10n;
    void open() => onOpen(e);
    return switch (e) {
      ThemeStory(:final story) => BigCard(title: story.title, color: color, icon: mode.icon, width: width, onTap: open),
      ThemeActivity(activity: final a) => BigCard(
          title: a.title,
          color: color,
          emojis: a.coverEmojis,
          icon: a.coverEmojis.isEmpty ? mode.icon : null,
          width: width,
          badges: [
            if (a.isHome) (Icons.home_rounded, l.badgeAtHome),
            if (!a.isHome && a.togetherSuggested) (Icons.people_rounded, l.badgeTogether),
          ],
          onTap: open,
        ),
      ThemePractice(:final title) => BigCard(title: title, color: color, icon: mode.icon, width: width, onTap: open),
    };
  }
}

/// Una cosa da provare nella vita vera: il gesto di una storia o l'attività
/// fuori dallo schermo di un gioco. Il compagno la dice e la voce la legge;
/// chiudendo si torna al tema.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.practice, required this.theme});
  final ThemePractice practice;
  final ChildTheme theme;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final _voice = ShortVoice();

  @override
  void initState() {
    super.initState();
    // Chi non legge ancora la sente subito; il riascolta la ripete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _say();
    });
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  void _say() => _voice.say(AppStateScope.of(context).currentProfile?.language, widget.practice.instruction);

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    final l = context.l10n;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              ChildTopBar(
                exitIcon: Icons.close_rounded,
                exitTooltip: l.close,
                onExit: () => Navigator.of(context).pop(),
                onListen: _say,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(ExperienceMode.practice.icon, color: MiraboTokens.of(context).tint(widget.theme.color), size: 32),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(widget.practice.title,
                          style: text.headlineSmall?.copyWith(color: MiraboColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  final size = (c.maxHeight * 0.8).clamp(160.0, 340.0);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CompanionWidget(companion: state.companionOf(profile), stage: profile.companionStage, size: size),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SpeechBubble(
                                  tail: TailSide.left,
                                  tailAt: 0.5,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l.practiceHint, style: text.titleMedium?.copyWith(color: MiraboColors.inkSoft)),
                                      const SizedBox(height: 8),
                                      Text(widget.practice.instruction, style: text.headlineSmall?.copyWith(color: MiraboColors.navy)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),
                                ChunkyButton(
                                  label: l.back,
                                  icon: Icons.arrow_back_rounded,
                                  color: widget.theme.color,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
