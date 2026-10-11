import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../app_state.dart';
import '../../data/development_stats.dart';
import '../../models/activity.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
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
          title: const Text('Area genitori'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Sessione'),
            Tab(text: 'Profili'),
            Tab(text: 'Come parlarne'),
            Tab(text: 'Diario'),
            Tab(text: 'Sviluppo'),
          ]),
        ),
        body: TabBarView(children: [
          _SessionTab(state: state, profile: profile),
          _ProfilesTab(state: state),
          _ParentCardsTab(state: state),
          _DiaryTab(state: state, profile: profile),
          _DevelopmentTab(state: state, profile: profile),
        ]),
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
      padding: const EdgeInsets.all(24),
      children: [
        Text('Come usate l\'app adesso?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('In modalità "insieme" compaiono le pause di dialogo per voi due. '
            'In modalità "da solo" il bambino risponde toccando e le storie su sicurezza e corpo restano nascoste.'),
        const SizedBox(height: 16),
        SegmentedButton<SessionMode>(
          segments: const [
            ButtonSegment(value: SessionMode.together, icon: Icon(Icons.people_rounded), label: Text('Insieme')),
            ButtonSegment(value: SessionMode.alone, icon: Icon(Icons.person_rounded), label: Text('Da solo')),
          ],
          selected: {state.mode},
          onSelectionChanged: (s) => state.setMode(s.first),
        ),
        const SizedBox(height: 32),
        Text('Dove vivono i dati', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Solo su questo dispositivo. Il backup su Drive e l\'account cloud arrivano nelle prossime versioni.'),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text('Elimina tutti i dati'),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Eliminare tutto?'),
                content: const Text('Profili e diario verranno cancellati da questo dispositivo. Non si può annullare.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina')),
                ],
              ),
            );
            if (ok == true) {
              await state.wipeAll();
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            }
          },
        ),
      ],
    );
  }
}

class _ProfilesTab extends StatelessWidget {
  const _ProfilesTab({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final p in state.profiles)
          ListTile(
            leading: Icon(p.id == state.currentProfile?.id ? Icons.check_circle_rounded : Icons.circle_outlined),
            title: Text(p.name),
            subtitle: Text('${p.ageBand.label} · compagno ${state.companionOf(p).name} · ${p.storiesCompleted} storie'),
            onTap: () => state.selectProfile(p),
            trailing: IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileForm(existing: p))),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nuovo profilo'),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileForm())),
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
    final stories = state.repo.stories.where((s) => s.parentCard != null).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final s in stories)
          ListTile(
            title: Text(s.title),
            subtitle: Text(s.keyPhrase),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _ParentCardPage(story: s))),
          ),
      ],
    );
  }
}

class _ParentCardPage extends StatelessWidget {
  const _ParentCardPage({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
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
          return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Nessuna storia negli ultimi 30 giorni.')));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            final story = state.repo.byId(e.storyId);
            final answer = _answerLabel(story, e.dialogueAnswer);
            return ListTile(
              leading: Icon(e.completed ? Icons.check_rounded : Icons.remove_rounded),
              title: Text(story?.title ?? e.storyId),
              subtitle: Text([
                '${e.when.day}/${e.when.month}/${e.when.year}',
                e.mode == SessionMode.together ? 'insieme' : 'da solo',
                if (answer != null) 'alla pausa ha scelto: "$answer"',
              ].join(' · ')),
            );
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
            Text('Come sta crescendo ${profile.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Il confronto è solo con sé stesso, un mese fa. L\'app vede una parte piccola della sua giornata: '
                'per dubbi sullo sviluppo il riferimento è il pediatra o l\'insegnante.'),
            const SizedBox(height: 16),
            if (snap.connectionState != ConnectionState.done)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (stats.isEmpty)
              const Text('Nessuna attività negli ultimi 30 giorni. Quando ne farà qualcuna, qui vedrai le tappe.')
            else
              for (final area in ActivityArea.values)
                if (stats.any((s) => s.area == area)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(area.label, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  for (final s in stats.where((s) => s.area == area)) _SkillRow(stat: s),
                ],
            const SizedBox(height: 24),
            const Text('Dove non c\'è miglioramento, prova l\'attività fuori dallo schermo suggerita nella scheda: '
                'non più tempo sull\'app.', style: TextStyle(fontStyle: FontStyle.italic)),
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
            Expanded(child: Text(DevelopmentStats.label(stat.skill), style: Theme.of(context).textTheme.bodyLarge)),
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
                      Text(stage.label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
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
                ? 'Negli ultimi 30 giorni: ${stat.rounds} round. Un mese fa non l\'aveva ancora provato.'
                : 'Oggi: ${stat.now?.label ?? "—"} · un mese fa: ${stat.monthAgo!.label} (bordo grigio).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
