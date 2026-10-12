import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../data/development_stats.dart';
import '../../models/activity.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'profile_form.dart';

/// Area genitore: modalità della sessione, profili, schede "Come parlarne",
/// diario e sviluppo (statistiche solo per l'adulto, confronto con sé stesso).
class ParentArea extends StatelessWidget {
  const ParentArea({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.currentProfile!;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.parentArea),
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
                  splashBorderRadius: BorderRadius.circular(14),
                  indicator: BoxDecoration(
                    color: MiraboColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: softShadow(0.8),
                  ),
                  tabs: [
                    Tab(height: 44, text: context.l10n.parentTabSession),
                    Tab(height: 44, text: context.l10n.parentTabProfiles),
                    Tab(height: 44, text: context.l10n.parentTabCards),
                    Tab(height: 44, text: context.l10n.parentTabDiary),
                    Tab(height: 44, text: context.l10n.parentTabGrowth),
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
              _ParentCardsTab(state: state),
              _DiaryTab(state: state, profile: profile),
              _DevelopmentTab(state: state, profile: profile),
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
          icon: Icons.lock_rounded,
          color: MiraboColors.teal,
          title: context.l10n.parentData,
          subtitle: context.l10n.parentDataHint,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _WipeButton(state: state),
            ),
          ],
        ),
      ],
    );
  }
}

class _WipeButton extends StatelessWidget {
  const _WipeButton({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5), width: 1.5),
          ),
          icon: const Icon(Icons.delete_forever_rounded),
          label: Text(context.l10n.parentWipe),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(context.l10n.parentWipeConfirmTitle),
                content: Text(context.l10n.parentWipeConfirm),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
                  FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.parentWipeYes)),
                ],
              ),
            );
            if (ok == true) {
              await state.wipeAll();
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            }
          },
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
      body: Markdown(
        data: story.parentCard!,
        padding: const EdgeInsets.all(24),
      ),
    );
  }
}

class _DiaryTab extends StatelessWidget {
  const _DiaryTab({required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: state.db.diary(profile.id),
      builder: (context, snap) {
        final entries = snap.data ?? const [];
        if (entries.isEmpty) {
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(context.l10n.diaryEmpty)));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            final story = state.repo.byId(e.storyId, AppLanguage.ofDevice().code);
            final answer = _answerLabel(story, e.dialogueAnswer);
            return _carded(ListTile(
              leading: Icon(e.completed ? Icons.check_rounded : Icons.remove_rounded),
              title: Text(story?.title ?? e.storyId),
              subtitle: Text([
                '${e.when.day}/${e.when.month}/${e.when.year}',
                e.mode == SessionMode.together ? context.l10n.diaryTogether : context.l10n.diaryAlone,
                if (answer != null) context.l10n.diaryChose(answer),
              ].join(' · ')),
            ));
          },
        );
      },
    );
  }

  String? _answerLabel(Story? story, String? answerId) {
    if (story == null || answerId == null) return null;
    for (final v in story.variants.values) {
      for (final s in v.screens) {
        for (final o in s.dialogue?.options ?? const <DialogueOption>[]) {
          if (o.id == answerId) return o.label;
        }
      }
    }
    return answerId;
  }
}

class _DevelopmentTab extends StatelessWidget {
  const _DevelopmentTab({required this.state, required this.profile});
  final AppState state;
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SkillStat>>(
      future: DevelopmentStats(state.db).forProfile(profile.id, state.repo.activities),
      builder: (context, snap) {
        final stats = snap.data ?? const <SkillStat>[];
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(context.l10n.growthTitle(profile.name), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(context.l10n.growthIntro),
            const SizedBox(height: 16),
            if (snap.connectionState != ConnectionState.done)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (stats.isEmpty)
              Text(context.l10n.growthEmpty)
            else
              for (final area in ActivityArea.values)
                if (stats.any((s) => s.area == area)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(context.l10n.areaLabel(area.name), style: Theme.of(context).textTheme.titleLarge),
                  ),
                  for (final s in stats.where((s) => s.area == area)) _SkillRow(stat: s),
                ],
            const SizedBox(height: 24),
            Text(context.l10n.growthOffscreen, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        );
      },
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.stat});
  final SkillStat stat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(context.l10n.skillLabel(stat.skill.replaceAll('-', '_')), style: Theme.of(context).textTheme.bodyLarge)),
            if (stat.improved) const Icon(Icons.trending_up_rounded, color: Colors.green),
          ]),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final stage in Stage.values) ...[
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: stat.now != null && stage.index <= stat.now!.index ? scheme.primary : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(7),
                          border: stat.monthAgo == stage ? Border.all(color: scheme.outline, width: 2) : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(context.l10n.stageLabel(stage.name), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
                if (stage != Stage.values.last) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stat.monthAgo == null
                ? context.l10n.growthNew('${stat.rounds}')
                : context.l10n.growthCompare(
                    stat.now == null ? '—' : context.l10n.stageLabel(stat.now!.name),
                    context.l10n.stageLabel(stat.monthAgo!.name),
                  ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
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
      AgeBand.b5to7 => 'mid',
      AgeBand.b7to10 => 'big',
    };
