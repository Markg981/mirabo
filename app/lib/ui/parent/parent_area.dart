import 'package:flutter/material.dart';
import 'adult_gate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../features.dart';
import '../../data/adult_pin.dart';
import '../../data/exploration_diary.dart';
import '../../data/usage_tracker.dart';
import '../../data/parent_digest.dart';
import '../../models/activity.dart';
import '../../models/made_story.dart';
import '../../models/nature_day.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'backup_section.dart';
import 'onboarding_screen.dart';
import 'data_deletion.dart';
import 'printables_tab.dart';
import 'profile_form.dart';
import 'shelf_tab.dart';

/// Area genitore: modalità della sessione, profili, mensola, schede "Come parlarne",
/// diario, sviluppo (statistiche solo per l'adulto, confronto con sé stesso)
/// e stampabili.
class ParentArea extends StatelessWidget {
  const ParentArea({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.parentArea),
          actions: [
            IconButton(
              key: const Key('reopen-onboarding'),
              icon: const Icon(Icons.waving_hand_rounded),
              tooltip: context.l10n.onbReopen,
              onPressed: () => Navigator.of(context).push(adultRoute((_) => const OnboardingScreen(reopened: true))),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TabBar(
                  // Sette schede: su un tablet piccolo le etichette scorrono invece di troncarsi.
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  splashBorderRadius: BorderRadius.circular(14),
                  indicator: BoxDecoration(
                    color: MiraboColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: softShadow(0.8),
                  ),
                  tabs: [
                    Tab(height: 44, text: context.l10n.parentTabSession),
                    Tab(height: 44, text: context.l10n.parentTabProfiles),
                    Tab(height: 44, text: context.l10n.parentTabShelf),
                    Tab(height: 44, text: context.l10n.parentTabCards),
                    Tab(height: 44, text: context.l10n.parentTabDiary),
                    Tab(height: 44, text: context.l10n.parentTabGrowth),
                    Tab(height: 44, text: context.l10n.parentTabPrint),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: TabBarView(children: [
              _SessionTab(state: state, profile: profile),
              _ProfilesTab(state: state),
              ShelfTab(state: state),
              _ParentCardsTab(state: state),
              _DiaryTab(state: state, profile: profile),
              _DevelopmentTab(state: state, profile: profile),
              PrintablesTab(state: state, profile: profile),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SessionTab extends StatelessWidget {
  const _SessionTab({required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      children: [
        for (final p in state.profiles)
          if (p.bandToConfirm != null) _BandConfirmCard(state: state, profile: p),
        for (final code in state.voicesMissing)
          Card(
            key: Key('voice-missing-$code'),
            child: ListTile(
              leading: const Icon(Icons.volume_off_rounded),
              title: Text(context.l10n.voiceMissingParent(AppLanguage.fromCode(code).nativeName)),
              trailing: IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: context.l10n.listenAgain, onPressed: state.checkVoices),
            ),
          ),
        FormSection(
          icon: Icons.people_rounded,
          color: MiraboColors.sky,
          title: context.l10n.parentHowUse,
          subtitle: context.l10n.parentHowUseHint,
          children: [
            SegmentedButton<SessionMode>(
              segments: [
                ButtonSegment(value: SessionMode.together, icon: const Icon(Icons.people_rounded), label: Text(context.l10n.modeTogether)),
                ButtonSegment(value: SessionMode.alone, icon: const Icon(Icons.person_rounded), label: Text(context.l10n.modeAlone)),
              ],
              selected: {state.mode},
              onSelectionChanged: (s) => state.setMode(s.first),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FormSection(
          icon: Icons.public_rounded,
          color: MiraboColors.teal,
          title: context.l10n.parentPlace,
          subtitle: context.l10n.parentPlaceHint,
          children: [
            SegmentedButton<Hemisphere>(
              segments: [
                for (final h in Hemisphere.values) ButtonSegment(value: h, label: Text(context.l10n.hemisphere(h.name))),
              ],
              selected: {state.hemisphere},
              onSelectionChanged: (s) => state.setHemisphere(s.first),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FormSection(
          icon: Icons.lock_rounded,
          color: MiraboColors.teal,
          title: context.l10n.parentData,
          subtitle: context.l10n.parentDataHint,
          children: [
            const _PinSection(),
            const SizedBox(height: 12),
            DataDeletionSection(state: state),
          ],
        ),
        // Il backup su Drive è fuori dall'MVP (Features.cloudBackup).
        if (Features.cloudBackup) ...[
          const SizedBox(height: 20),
          FormSection(
            icon: Icons.cloud_rounded,
            color: MiraboColors.sky,
            title: context.l10n.backupTitle,
            subtitle: context.l10n.backupHint,
            children: [BackupSection(state: state)],
          ),
        ],
      ],
    );
  }
}

/// PIN dell'area adulta (docs/adult-gate.md): cambio, codice di recupero,
/// recupero con il blocco del tablet e l'avviso di un reset non ancora visto.
class _PinSection extends StatefulWidget {
  const _PinSection();

  @override
  State<_PinSection> createState() => _PinSectionState();
}

class _PinSectionState extends State<_PinSection> {
  PinResetNotice? _notice;
  bool? _device;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notice = await AdultGate.pin.resetNotice();
    final device = await AdultGate.pin.deviceRecovery;
    if (!mounted) return;
    setState(() {
      _notice = notice;
      _device = device;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final notice = _notice;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (notice != null)
        Card(
          key: const Key('pin-reset-notice'),
          color: Theme.of(context).colorScheme.errorContainer,
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded),
            title: Text(l.gateResetNotice(
              MaterialLocalizations.of(context).formatMediumDate(notice.at),
              notice.how == RecoveryChannel.code ? l.gateResetHowCode : l.gateResetHowDevice,
            )),
            trailing: TextButton(
              onPressed: () async {
                await AdultGate.pin.clearResetNotice();
                _load();
              },
              child: Text(l.gateResetSeen),
            ),
          ),
        ),
      Wrap(spacing: 12, runSpacing: 8, children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.pin_outlined),
          label: Text(l.gateChangePin),
          onPressed: () => AdultGate.changePin(context),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.key_rounded),
          label: Text(l.gateNewRecovery),
          onPressed: () => AdultGate.newRecoveryCode(context),
        ),
      ]),
      if (_device != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _device!,
          title: Text(l.gateDeviceRecovery),
          subtitle: Text(l.gateDeviceRecoveryHint),
          onChanged: (v) async {
            if (await AdultGate.setDeviceRecovery(context, v)) _load();
          },
        ),
    ]);
  }
}

/// Profilo creato con le fasce di prima (5-7, 7-10): l'adulto sceglie fra le
/// due fasce attuali possibili. Finché non sceglie non cambia nulla per il
/// bambino; dopo, il profilo di interazione resta quello che era.
class _BandConfirmCard extends StatelessWidget {
  const _BandConfirmCard({required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final old = profile.bandToConfirm!;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SoftPanel(
        key: Key('band-confirm-${profile.id}'),
        padding: const EdgeInsets.all(20),
        color: MiraboColors.pale(MiraboTokens.of(context).tint(MiraboColors.sky), 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconBadge(icon: Icons.child_care_rounded, color: MiraboColors.sky, size: 48),
                const SizedBox(width: 14),
                Expanded(child: Text(l.bandConfirmTitle(profile.name, old.key.replaceAll('-', '–')), style: text.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Text(l.bandConfirmHint(profile.name), style: text.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final b in old.choices)
                  OutlinedButton(
                    key: Key('band-confirm-${profile.id}-${b.key}'),
                    onPressed: () => state.confirmBand(profile, b),
                    child: Text('${l.profileYears(b.key.replaceAll('-', '–'))} · ${l.ageBandLabel(_bandKey(b))}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilesTab extends StatelessWidget {
  const _ProfilesTab({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        for (final p in state.profiles)
          _carded(ListTile(
            leading: Icon(p.id == state.currentProfile?.id ? Icons.check_circle_rounded : Icons.circle_outlined),
            title: Text(p.name),
            subtitle: Text(context.l10n.parentProfileLine(context.l10n.ageBandLabel(_bandKey(p.ageBand)), state.companionOf(p).name, p.storiesCompleted)),
            onTap: () => state.selectProfile(p),
            trailing: IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => Navigator.of(context).push(adultRoute((_) => ProfileForm(existing: p))),
            ),
          )),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            icon: const Icon(Icons.add_rounded),
            label: Text(context.l10n.parentNewProfile),
            onPressed: () => Navigator.of(context).push(adultRoute((_) => const ProfileForm())),
          ),
        ),
      ],
    );
  }
}

class _ParentCardsTab extends StatelessWidget {
  const _ParentCardsTab({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final stories = state.repo.storiesIn(AppLanguage.ofDevice().code).where((s) => s.parentCard != null).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        for (final s in stories)
          _carded(ListTile(
            title: Text(s.title),
            subtitle: Text(s.keyPhrase),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(adultRoute((_) => _ParentCardPage(story: s))),
          )),
      ],
    );
  }
}

class _ParentCardPage extends StatelessWidget {
  const _ParentCardPage({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    final draft = AppStateScope.of(context).repo.isDraft(story.id, AppLanguage.ofDevice().code);
    return Scaffold(
      appBar: AppBar(
        title: Text(story.title),
        actions: [
          if (draft)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(avatar: const Icon(Icons.translate_rounded, size: 18), label: Text(context.l10n.translationDraft)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          MarkdownBody(data: story.parentCard!),
          if (story.homeActivity case final activity?) HomeActivityView(activity: activity),
        ],
      ),
    );
  }
}

/// L'attività della storia, una sezione per fascia: cosa serve, preparazione,
/// supervisione e alternative. Il bambino la fa senza tornare nell'app.
class HomeActivityView extends StatelessWidget {
  const HomeActivityView({super.key, required this.activity});
  final HomeActivity activity;

  String _supervision(AppLocalizations l, Supervision s) => switch (s) {
        Supervision.together => l.supervisionTogether,
        Supervision.nearby => l.supervisionNearby,
        Supervision.free => l.supervisionFree,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    Widget list(String heading, List<String> items, {bool numbered = false}) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(heading, style: theme.textTheme.titleSmall),
              for (final (n, item) in items.indexed) Text('${numbered ? '${n + 1}.' : '•'} $item'),
            ],
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.homeActivityHeading, style: theme.textTheme.labelLarge),
          Text(activity.title, style: theme.textTheme.headlineSmall),
          if (activity.intro case final intro?) Padding(padding: const EdgeInsets.only(top: 8), child: Text(intro)),
          for (final entry in activity.bands.entries)
            Card(
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.profileYears('${entry.key.minAge}–${entry.key.maxAge}'), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(entry.value.goal),
                    list(l.homeActivitySteps, entry.value.steps, numbered: true),
                    list(l.homeActivityMaterials, entry.value.materials),
                    list(l.homeActivityPreparation, entry.value.preparation),
                    list(l.homeActivitySupervision, ['${_supervision(l, entry.value.supervision)}. ${entry.value.supervisionNote}']),
                    list(l.homeActivityAlternatives, entry.value.alternatives),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DiaryTab extends StatefulWidget {
  const _DiaryTab({required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  @override
  State<_DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<_DiaryTab> {
  late Future<_DiaryData> _data = _load();

  /// Il diario mostra 30 giorni; i gesti vengono da tutte le storie finite;
  /// il racconto della settimana usa anche i round delle attività a casa.
  /// L'idea per oggi guarda tutti i round e le idee delle ultime due settimane:
  /// la prima apertura del giorno la sceglie e la salva.
  Future<_DiaryData> _load() async {
    final state = widget.state;
    final db = state.db;
    final id = widget.profile.id;
    final now = DateTime.now();
    final lang = AppLanguage.ofDevice().code;
    final profile = state.profiles.firstWhere((p) => p.id == id, orElse: () => widget.profile);
    final allEntries = await db.diary(id, days: 3650);
    final rounds = await db.rounds(id, from: now.subtract(const Duration(days: 3650)));
    final ideas = ideasFor(
      now: now,
      band: profile.ageBand,
      diary: allEntries,
      rounds: rounds,
      history: await db.dailyIdeas(id, since: now.subtract(const Duration(days: 15))),
      story: (s) => state.repo.byId(s, lang),
      activities: state.repo.activitiesIn(lang),
      dismissed: await db.dismissedIdeas(id),
    );
    if (ideas.isNotEmpty) await db.saveDailyIdea(id, ideaDay(now), ideas.first.key);
    final weekAgo = now.subtract(const Duration(days: 7)).toIso8601String();
    final week = [for (final r in rounds) if ((r['at'] as String).compareTo(weekAgo) >= 0) r];
    return (await db.diary(id), allEntries, await db.gestures(id), week, ideas);
  }

  Future<void> _mark(String storyId) async {
    await widget.state.recordGesture(widget.profile, storyId);
    setState(() => _data = _load());
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.data == null) return const Center(child: CircularProgressIndicator());
        final (entries, allEntries, gestures, rounds, ideas) = snap.data!;
        final lang = AppLanguage.ofDevice().code;
        final profile = state.profiles.firstWhere((p) => p.id == widget.profile.id, orElse: () => widget.profile);
        final finished = [
          for (final id in <String>{for (final e in allEntries) if (e.completed) e.storyId})
            if (state.repo.byId(id, lang) case final story?) story,
        ];
        final withGesture = [for (final s in finished) if (s.gesture != null) s];
        final now = DateTime.now();
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            _IdeaSection(
              name: profile.name,
              ideas: ideas,
              onDismiss: (key) async {
                await state.db.dismissIdea(widget.profile.id, key);
                if (mounted) setState(() => _data = _load());
              },
            ),
            const SizedBox(height: 20),
            _WeekSection(
              name: profile.name,
              week: WeekDigest.build(
                now: now,
                diary: entries,
                gestureEntries: gestures,
                rounds: rounds,
                story: (id) => state.repo.byId(id, lang),
                activity: (id) => state.repo.activityById(id, lang),
              ),
            ),
            const SizedBox(height: 20),
            _GesturesSection(
              profile: profile,
              companion: state.companionOf(widget.profile).name,
              stories: withGesture,
              gestures: gestures,
              onMark: _mark,
            ),
            const SizedBox(height: 20),
            if (entries.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(context.l10n.diaryEmpty)))
            else
              for (final e in entries) _entryTile(context, e, state.repo.byId(e.storyId, lang)),
          ],
        );
      },
    );
  }

  Widget _entryTile(BuildContext context, DiaryEntry e, Story? story) {
    return _carded(ListTile(
      leading: Icon(e.completed ? Icons.check_rounded : Icons.remove_rounded),
      title: Text(story?.title ?? e.storyId),
      subtitle: Text([
        '${e.when.day}/${e.when.month}/${e.when.year}',
        e.mode == SessionMode.together ? context.l10n.diaryTogether : context.l10n.diaryAlone,
      ].join(' · ')),
    ));
  }
}

/// Diario a 30 giorni, tutto il diario, gesti, round della settimana, idee per oggi.
typedef _DiaryData = (List<DiaryEntry>, List<DiaryEntry>, List<GestureEntry>, List<Map<String, Object?>>, List<DailyIdea>);

/// Un'idea per oggi (3.4.3): una cosa concreta da fare fuori dallo schermo,
/// presa dalla scheda "Come parlarne" di una storia finita o da una presentazione.
/// Le idee arrivano già in ordine di priorità: la prima è quella di oggi,
/// "Un'altra idea" passa alla successiva.
class _IdeaSection extends StatefulWidget {
  const _IdeaSection({required this.name, required this.ideas, required this.onDismiss});
  final String name;
  final List<DailyIdea> ideas;

  /// Il genitore scarta l'idea: non viene più riproposta.
  final Future<void> Function(String key) onDismiss;

  @override
  State<_IdeaSection> createState() => _IdeaSectionState();
}

class _IdeaSectionState extends State<_IdeaSection> {
  int _skip = 0;

  @override
  Widget build(BuildContext context) {
    final idea = widget.ideas.isEmpty ? null : widget.ideas[_skip % widget.ideas.length];
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final reason = switch (idea) {
      null => null,
      DailyIdea(reason: IdeaReason.repeat) => l10n.ideaReasonRepeat(widget.name),
      StoryIdea(:final story) => l10n.ideaReasonStory(widget.name, story.title),
      DailyIdea(reason: IdeaReason.tryAlone) => l10n.ideaReasonTryAlone,
      HomeIdea(reason: IdeaReason.capacity, :final capacity) => l10n.ideaReasonCapacity(widget.name, capacity.name),
      _ => l10n.ideaReasonNone(widget.name),
    };
    return FormSection(
      icon: Icons.lightbulb_rounded,
      color: MiraboColors.sky,
      title: context.l10n.ideaTitle,
      subtitle: context.l10n.ideaIntro(widget.name),
      children: [
        if (reason != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(reason, style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
          ),
        ...switch (idea) {
          null => [Text(context.l10n.ideaEmpty(widget.name))],
          StoryIdea(:final story, text: final body) => [
              Text(context.l10n.ideaFromStory(story.title), style: text.titleMedium),
              const SizedBox(height: 6),
              MarkdownBody(data: body),
            ],
          HomeIdea(:final activity, :final materials) => [
              Text(context.l10n.ideaHome(activity.title, context.l10n.areaLabel(activity.area.name)), style: text.titleMedium),
              const SizedBox(height: 6),
              Text(materials.isEmpty ? l10n.ideaNeedsNothing : l10n.presentationWhatYouNeedSay(materials.join(', '))),
              Text(context.l10n.ideaHomeHint, style: text.bodySmall),
            ],
        },
        if (idea != null) ...[
          const SizedBox(height: 4),
          Text(switch (idea.prep) {
            IdeaPrep.none => l10n.ideaPrepNone,
            IdeaPrep.quick => l10n.ideaPrepQuick,
            IdeaPrep.short => l10n.ideaPrepShort,
          }),
          Text(l10n.ideaVariant(idea.variant ?? (idea is StoryIdea ? l10n.ideaVariantStory(widget.name) : l10n.ideaVariantHome))),
          Wrap(
            spacing: 8,
            children: [
              TextButton(onPressed: () => widget.onDismiss(idea.key), child: Text(l10n.ideaNoMaterials)),
              TextButton(onPressed: () => widget.onDismiss(idea.key), child: Text(l10n.ideaNotInterested)),
            ],
          ),
        ],
        if (widget.ideas.length > 1)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.ideaAnother),
              onPressed: () => setState(() => _skip++),
            ),
          ),
      ],
    );
  }
}

/// Racconto della settimana (3.4.1): gli ultimi 7 giorni in poche frasi,
/// senza numeri da migliorare.
class _WeekSection extends StatelessWidget {
  const _WeekSection({required this.name, required this.week});
  final String name;
  final WeekDigest week;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String titles(Iterable<String> t) => t.join(', ');
    final lines = <String>[
      if (week.isEmpty) l10n.weekEmpty,
      if (week.stories.isNotEmpty) ...[
        l10n.weekStories(week.stories.length, titles(week.stories.map((s) => s.title))),
        if (week.together == week.sessions)
          l10n.weekAllTogether
        else if (week.together == 0)
          l10n.weekAllAlone
        else
          l10n.weekTogether(week.together, week.sessions),
      ],
      if (week.gestures.isNotEmpty)
        l10n.weekGestures(week.gestures.length, titles(week.gestures.map((s) => s.title)))
      else if (week.stories.any((s) => s.gesture != null))
        l10n.weekNoGestures,
      if (week.home.isNotEmpty) l10n.weekHome(titles(week.home.map((a) => a.title))),
    ];
    return FormSection(
      icon: Icons.auto_stories_rounded,
      color: MiraboColors.teal,
      title: l10n.weekTitle(name),
      subtitle: l10n.weekIntro,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(line, style: Theme.of(context).textTheme.bodyLarge),
          ),
        if (week.stories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l10n.weekKeyPhrase(week.stories.first.keyPhrase),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }
}

/// I gesti delle storie fatti davvero: il genitore, se vuole, li segna nel
/// diario. Non fanno crescere il compagno e non sbloccano nulla. Il bambino
/// non ha questo pulsante.
class _GesturesSection extends StatelessWidget {
  const _GesturesSection({
    required this.profile,
    required this.companion,
    required this.stories,
    required this.gestures,
    required this.onMark,
  });
  final ChildProfile profile;
  final String companion;
  final List<Story> stories;
  final List<GestureEntry> gestures;
  final Future<void> Function(String storyId) onMark;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return FormSection(
      icon: Icons.spa_rounded,
      color: MiraboColors.teal,
      title: context.l10n.gesturesTitle,
      subtitle: context.l10n.gesturesIntro(companion, profile.name),
      children: [
        if (stories.isEmpty)
          Text(context.l10n.gesturesEmpty(profile.name))
        else
          for (final s in stories) _row(context, s, now),
      ],
    );
  }

  Widget _row(BuildContext context, Story story, DateTime now) {
    final mine = gestures.where((g) => g.storyId == story.id);
    final today = mine.any((g) => g.when.year == now.year && g.when.month == now.month && g.when.day == now.day);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story.gesture!, style: Theme.of(context).textTheme.bodyLarge),
                Text('${story.title} · ${context.l10n.gestureTimes(mine.length)}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          today
              ? Chip(avatar: const Icon(Icons.check_rounded, size: 18), label: Text(context.l10n.gestureMarked))
              : FilledButton.tonal(onPressed: () => onMark(story.id), child: Text(context.l10n.gestureMark)),
        ],
      ),
    );
  }
}

class _DevelopmentTab extends StatefulWidget {
  const _DevelopmentTab({required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  @override
  State<_DevelopmentTab> createState() => _DevelopmentTabState();
}

/// Il processo dei piccoli progetti: idea, previsione, prova, revisione, con le
/// note del bambino. Solo da leggere: nessun voto.
class _ProjectLog extends StatelessWidget {
  const _ProjectLog({required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  String _phase(BuildContext context, String phase) => switch (phase) {
        'idea' => context.l10n.projectPhaseIdea,
        'prediction' => context.l10n.projectPhasePrediction,
        'test' => context.l10n.projectPhaseTest,
        _ => context.l10n.projectPhaseRevision,
      };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProjectStep>>(
      future: ExplorationDiary(state.db).projectLog(profile.id),
      builder: (context, snap) {
        final steps = snap.data ?? const <ProjectStep>[];
        if (steps.isEmpty) return const SizedBox.shrink();
        final titles = {for (final a in state.repo.activities) a.id: a.title};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 4),
              child: Text(context.l10n.projectLogTitle(profile.name), style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final s in steps.take(24))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${titles[s.activityId] ?? s.activityId} · ${_phase(context, s.phase)}'),
                subtitle: switch ((s.result, s.note)) {
                  ('held', _) => Text(context.l10n.projectResultHeld),
                  ('notyet', _) => Text(context.l10n.projectResultNotYet),
                  (_, final n?) when n.isNotEmpty => Text(n),
                  _ => null,
                },
              ),
          ],
        );
      },
    );
  }
}

/// Diario descrittivo: temi esplorati e ripresi, storie inventate dal bambino
/// e osservazioni del genitore. Niente tappe, livelli o confronti.
class _DevelopmentTabState extends State<_DevelopmentTab> {
  final _note = TextEditingController();
  late Future<(List<ThemeExploration>, List<MadeStory>, List<ParentNote>)> _data = _load();

  ExplorationDiary get _diary => ExplorationDiary(widget.state.db);

  Future<(List<ThemeExploration>, List<MadeStory>, List<ParentNote>)> _load() async => (
        await _diary.forProfile(widget.profile.id, widget.state.repo.activities),
        await widget.state.madeStoriesOf(widget.profile),
        await _diary.notes(widget.profile.id),
      );

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    await _diary.addNote(widget.profile.id, _note.text);
    _note.clear();
    setState(() => _data = _load());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    return FutureBuilder<(List<ThemeExploration>, List<MadeStory>, List<ParentNote>)>(
      future: _data,
      builder: (context, snap) {
        final data = snap.data;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l.growthTitle(widget.profile.name), style: theme.titleLarge),
            const SizedBox(height: 8),
            Text(l.growthIntro),
            const SizedBox(height: 16),
            _UsageCard(state: widget.state, profile: widget.profile),
            const SizedBox(height: 16),
            if (data == null)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else ...[
              if (data.$1.isEmpty)
                Text(l.growthEmpty)
              else
                for (final area in ActivityArea.values)
                  if (data.$1.any((t) => t.area == area)) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text(l.areaLabel(area.name), style: theme.titleLarge),
                    ),
                    for (final t in data.$1.where((t) => t.area == area))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.exploreTheme(l.skillLabel(t.skill.replaceAll('-', '_')))),
                        subtitle: Text(t.resumed ? l.exploreResumed(t.days) : l.exploreOnce),
                      ),
                  ],
              const SizedBox(height: 24),
              Text(l.exploreCreationsTitle, style: theme.titleLarge),
              const SizedBox(height: 4),
              if (data.$2.isEmpty)
                Text(l.exploreCreationsEmpty)
              else
                for (final m in data.$2)
                  ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.auto_stories_outlined), title: Text(m.titleIn(l))),
              const SizedBox(height: 24),
              Text(l.exploreNotesTitle, style: theme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(hintText: l.exploreNotesHint, border: const OutlineInputBorder()),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _add, child: Text(l.exploreNotesAdd)),
              ),
              if (data.$3.isEmpty)
                Text(l.exploreNotesEmpty)
              else
                for (final n in data.$3)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(n.text),
                    subtitle: Text('${n.when.day}/${n.when.month}/${n.when.year}'),
                    trailing: IconButton(
                      tooltip: l.exploreNotesDelete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await _diary.removeNote(widget.profile.id, n);
                        setState(() => _data = _load());
                      },
                    ),
                  ),
            ],
            _ProjectLog(state: widget.state, profile: widget.profile),
            const SizedBox(height: 24),
            Text(l.growthOffscreen, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        );
      },
    );
  }
}

/// Riga di elenco dentro una carta, con lo spazio fra una e l'altra.
Widget _carded(Widget tile) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(child: tile),
    );

String _bandKey(AgeBand b) => switch (b) {
      AgeBand.b3to5 => 'small',
      AgeBand.b6to7 => 'mid',
      AgeBand.b8to10 => 'big',
    };

/// Tempi d'uso contestualizzati: schermo acceso (l'unica cosa che l'app misura),
/// gesti segnati dalla famiglia e, soprattutto, cosa i minuti non dicono.
/// Dati neutri: nessun obiettivo, nessun giudizio.
class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return FutureBuilder<(List<DayUsage>, int)>(
      future: () async {
        final days = await state.usage?.lastDays(profile.id) ?? const <DayUsage>[];
        final gestures = (await state.db.gestures(profile.id)).where((g) => g.when.isAfter(weekAgo)).length;
        return (days, gestures);
      }(),
      builder: (context, snap) {
        final days = snap.data?.$1 ?? const <DayUsage>[];
        final total = days.fold<int>(0, (a, d) => a + d.seconds);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.usageTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (days.isNotEmpty) ...[
                Text(l.usageWeek((total / 60).round(), days.where((d) => d.seconds > 0).length)),
                Text(l.usageToday(days.last.minutes)),
              ],
              Text(l.usageGestures(snap.data?.$2 ?? 0)),
              Text(profile.aloneSessionMinutes <= 0 ? l.usageNoLimit : l.usageLimit(profile.aloneSessionMinutes)),
              const SizedBox(height: 8),
              Text(l.usageCannot, style: const TextStyle(fontStyle: FontStyle.italic)),
            ]),
          ),
        );
      },
    );
  }
}
