import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../child/companion_widget.dart';

/// Creazione o modifica di un profilo bambino. Lo compila il genitore.
/// Al primo avvio è l'unica schermata; il compagno si sceglie una volta sola.
class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, this.existing, this.firstRun = false});
  final ChildProfile? existing;
  final bool firstRun;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late AgeBand _band = widget.existing?.ageBand ?? AgeBand.b5to7;
  CompanionId? _companion;
  late Set<World> _worlds = widget.existing?.enabledWorlds ?? World.values.toSet();
  late bool _safetyTogetherOnly = widget.existing?.safetyTogetherOnly ?? true;
  late bool _dyslexia = widget.existing?.dyslexiaFont ?? false;
  late bool _lowStim = widget.existing?.lowStimulation ?? false;
  late int _aloneMinutes = widget.existing?.aloneSessionMinutes ?? 20;

  @override
  void initState() {
    super.initState();
    _companion = widget.existing?.companion;
  }

  bool get _valid => _name.text.trim().isNotEmpty && _companion != null;

  Future<void> _save() async {
    final state = AppStateScope.read(context);
    final existing = widget.existing;
    if (existing == null) {
      await state.createProfile(ChildProfile(
        id: 0,
        name: _name.text.trim(),
        ageBand: _band,
        companion: _companion!,
        enabledWorlds: _worlds,
        safetyTogetherOnly: _safetyTogetherOnly,
        dyslexiaFont: _dyslexia,
        lowStimulation: _lowStim,
        aloneSessionMinutes: _aloneMinutes,
      ));
    } else {
      await state.updateProfile(existing.copyWith(
        name: _name.text.trim(),
        ageBand: _band,
        enabledWorlds: _worlds,
        safetyTogetherOnly: _safetyTogetherOnly,
        dyslexiaFont: _dyslexia,
        lowStimulation: _lowStim,
        aloneSessionMinutes: _aloneMinutes,
      ));
    }
    if (mounted && !widget.firstRun) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.firstRun ? 'Benvenuti in Mirabò' : (editing ? 'Modifica profilo' : 'Nuovo profilo'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (widget.firstRun)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Questa parte la compila un adulto. Ci vuole un minuto, e poi il tablet passa al bambino.'),
            ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nome del bambino', helperText: 'Il compagno lo chiamerà così'),
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          Text('Età', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SegmentedButton<AgeBand>(
            segments: [for (final b in AgeBand.values) ButtonSegment(value: b, label: Text('${b.label} (${b.key})'))],
            selected: {_band},
            onSelectionChanged: (s) => setState(() => _band = s.first),
          ),
          const SizedBox(height: 24),
          Text('Il compagno', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(editing
              ? 'Il compagno si sceglie una volta sola: è il suo migliore amico.'
              : 'Fate scegliere al bambino. Si sceglie una volta sola e non si cambia.'),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final c in state.repo.companions)
                Expanded(
                  child: Opacity(
                    opacity: editing && c.id != _companion ? 0.35 : 1,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: editing ? null : () => setState(() => _companion = c.id),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 3,
                            color: _companion == c.id ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            CompanionWidget(companion: c, stage: 0, size: 96),
                            const SizedBox(height: 8),
                            Text(c.name, style: Theme.of(context).textTheme.titleLarge),
                            Text(c.kind, textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            Text(c.tagline, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Mondi abilitati', style: Theme.of(context).textTheme.titleLarge),
          for (final w in World.values)
            CheckboxListTile(
              value: _worlds.contains(w),
              title: Text(_worldLabel(w)),
              onChanged: (v) => setState(() => v == true ? _worlds = {..._worlds, w} : _worlds = _worlds.difference({w})),
            ),
          SwitchListTile(
            value: _safetyTogetherOnly,
            title: const Text('"Il mio corpo" solo in modalità insieme'),
            subtitle: const Text('Consigliato: le storie su sicurezza e corpo si leggono con un adulto'),
            onChanged: (v) => setState(() => _safetyTogetherOnly = v),
          ),
          const SizedBox(height: 16),
          Text('Accessibilità', style: Theme.of(context).textTheme.titleLarge),
          SwitchListTile(
            value: _dyslexia,
            title: const Text('Testo ad alta leggibilità'),
            subtitle: const Text('Spaziatura e interlinea maggiori'),
            onChanged: (v) => setState(() => _dyslexia = v),
          ),
          SwitchListTile(
            value: _lowStim,
            title: const Text('Bassa stimolazione'),
            subtitle: const Text('Colori tenui, nessuna animazione'),
            onChanged: (v) => setState(() => _lowStim = v),
          ),
          const SizedBox(height: 16),
          Text('Sessione "da solo": ${_aloneMinutes} minuti', style: Theme.of(context).textTheme.titleLarge),
          Slider(
            value: _aloneMinutes.toDouble(),
            min: 10,
            max: 30,
            divisions: 4,
            label: '$_aloneMinutes min',
            onChanged: (v) => setState(() => _aloneMinutes = v.round()),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _valid ? _save : null, child: Text(widget.firstRun ? 'Iniziamo' : 'Salva')),
          if (editing && state.profiles.length > 1) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await state.deleteProfile(widget.existing!.id);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Elimina questo profilo'),
            ),
          ],
        ],
      ),
    );
  }

  static String _worldLabel(World w) => switch (w) {
        World.emozioni => 'Emozioni e conflitti',
        World.inclusione => 'Diversità e inclusione',
        World.ambiente => 'Ambiente e viventi',
        World.sicurezza => 'Sicurezza e corpo',
      };
}
