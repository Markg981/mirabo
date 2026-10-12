import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../content/story_repository.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../child/companion_widget.dart';
import '../design/palette.dart';
import '../design/widgets.dart';

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
    final text = Theme.of(context).textTheme;
    final title = widget.firstRun ? 'Benvenuti in Mirabò' : (editing ? 'Modifica profilo' : 'Nuovo profilo');

    return Scaffold(
      appBar: widget.firstRun ? null : AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
              children: [
                if (widget.firstRun) ...[
                  _WelcomeHeader(title: title),
                  const SizedBox(height: 24),
                ],
                FormSection(
                  icon: Icons.child_care_rounded,
                  color: MiraboColors.sky,
                  title: 'Il bambino',
                  subtitle: widget.firstRun
                      ? 'Questa parte la compila un adulto. Ci vuole un minuto, poi il tablet passa al bambino.'
                      : null,
                  children: [
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nome', helperText: 'Il compagno lo chiamerà così'),
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    Text('Età', style: text.titleSmall),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final b in AgeBand.values) ...[
                          Expanded(
                            child: _AgeOption(
                              label: b.label,
                              years: '${b.key} anni',
                              selected: _band == b,
                              onTap: () => setState(() => _band = b),
                            ),
                          ),
                          if (b != AgeBand.values.last) const SizedBox(width: 12),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FormSection(
                  icon: Icons.pets_rounded,
                  color: MiraboColors.apricot,
                  title: 'Il compagno',
                  subtitle: editing
                      ? 'Il compagno si sceglie una volta sola: è il suo migliore amico.'
                      : 'Fate scegliere al bambino. Si sceglie una volta sola e non si cambia.',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final c in state.repo.companions) ...[
                          Expanded(
                            child: Opacity(
                              opacity: editing && c.id != _companion ? 0.35 : 1,
                              child: _CompanionOption(
                                companion: c,
                                selected: _companion == c.id,
                                onTap: editing ? null : () => setState(() => _companion = c.id),
                              ),
                            ),
                          ),
                          if (c != state.repo.companions.last) const SizedBox(width: 14),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FormSection(
                  icon: Icons.public_rounded,
                  color: MiraboColors.leaf,
                  title: 'Mondi delle storie',
                  subtitle: 'Scegliete i temi che il bambino troverà nella sua libreria.',
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final w in World.values)
                          _WorldChip(
                            world: w,
                            label: _worldLabel(w),
                            selected: _worlds.contains(w),
                            onTap: () => setState(() {
                              _worlds = _worlds.contains(w) ? _worlds.difference({w}) : {..._worlds, w};
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _safetyTogetherOnly,
                      title: const Text('"Il mio corpo" solo in modalità insieme'),
                      subtitle: const Text('Consigliato: le storie su sicurezza e corpo si leggono con un adulto.'),
                      onChanged: (v) => setState(() => _safetyTogetherOnly = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FormSection(
                  icon: Icons.tune_rounded,
                  color: MiraboColors.plum,
                  title: 'Accessibilità e tempo',
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _dyslexia,
                      title: const Text('Testo ad alta leggibilità'),
                      subtitle: const Text('Carattere Lexend, spaziatura e interlinea maggiori.'),
                      onChanged: (v) => setState(() => _dyslexia = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _lowStim,
                      title: const Text('Bassa stimolazione'),
                      subtitle: const Text('Colori tenui, nessuna animazione.'),
                      onChanged: (v) => setState(() => _lowStim = v),
                    ),
                    const Divider(height: 28),
                    Row(
                      children: [
                        Expanded(child: Text('Sessione "da solo"', style: text.titleMedium)),
                        Text('$_aloneMinutes minuti', style: text.titleMedium?.copyWith(color: MiraboColors.teal)),
                      ],
                    ),
                    Slider(
                      value: _aloneMinutes.toDouble(),
                      min: 10,
                      max: 30,
                      divisions: 4,
                      label: '$_aloneMinutes min',
                      onChanged: (v) => setState(() => _aloneMinutes = v.round()),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    if (editing && state.profiles.length > 1)
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () async {
                          await state.deleteProfile(widget.existing!.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        label: const Text('Elimina questo profilo'),
                      ),
                    const Spacer(),
                    if (!_valid)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          _name.text.trim().isEmpty ? 'Manca il nome' : 'Manca il compagno',
                          style: text.bodySmall,
                        ),
                      ),
                    ChunkyButton(
                      label: widget.firstRun ? 'Iniziamo' : 'Salva',
                      icon: widget.firstRun ? Icons.arrow_forward_rounded : Icons.check_rounded,
                      iconAfter: widget.firstRun,
                      color: MiraboColors.leaf,
                      height: 62,
                      onPressed: _valid ? _save : null,
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

  static String _worldLabel(World w) => switch (w) {
        World.emozioni => 'Emozioni e conflitti',
        World.inclusione => 'Diversità e inclusione',
        World.ambiente => 'Ambiente e viventi',
        World.sicurezza => 'Sicurezza e corpo',
      };
}

/// Intestazione del primo avvio: il marchio e i tre compagni.
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final navy = MiraboTokens.of(context).tint(MiraboColors.navy);
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 24, 24),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: MiraboColors.deep(navy, 0.1), offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.displaySmall?.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text('Storie e piccoli passi per crescere.',
                    style: text.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
          for (final id in CompanionId.values)
            CustomPaint(size: const Size.square(92), painter: CompanionPainter(id: id, stage: 1)),
        ],
      ),
    );
  }
}

/// Sezione del modulo: icona colorata, titolo, nota, contenuto in una carta.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SoftPanel(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, color: color, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleLarge),
                    if (subtitle != null) Text(subtitle!, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _AgeOption extends StatelessWidget {
  const _AgeOption({required this.label, required this.years, required this.selected, required this.onTap});
  final String label;
  final String years;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = MiraboTokens.of(context).tint(MiraboColors.sky);
    final text = Theme.of(context).textTheme;
    return BlockTile(
      onTap: onTap,
      radius: 18,
      depth: 5,
      color: selected ? c : MiraboColors.paper,
      border: selected ? null : Border.all(color: MiraboColors.line, width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      semanticLabel: '$label, $years',
      child: Column(
        children: [
          Text(label, style: text.titleMedium?.copyWith(color: selected ? Colors.white : MiraboColors.ink)),
          Text(years,
              style: text.labelMedium?.copyWith(color: selected ? Colors.white.withValues(alpha: 0.9) : MiraboColors.inkSoft)),
        ],
      ),
    );
  }
}

class _CompanionOption extends StatelessWidget {
  const _CompanionOption({required this.companion, required this.selected, required this.onTap});
  final Companion companion;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = MiraboTokens.of(context).tint(MiraboColors.apricot);
    final text = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BlockTile(
          onTap: onTap,
          radius: 24,
          depth: 6,
          color: selected ? MiraboColors.pale(c, 0.85) : MiraboColors.paper,
          edgeColor: selected ? c : null,
          border: Border.all(color: selected ? c : MiraboColors.line, width: selected ? 3 : 1.5),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          semanticLabel: '${companion.name}, ${companion.kind}',
          child: Column(
            children: [
              CompanionWidget(companion: companion, stage: 0, size: 130),
              Text(companion.name, style: text.headlineSmall),
              Text(companion.kind, textAlign: TextAlign.center, style: text.labelMedium?.copyWith(color: MiraboColors.inkSoft)),
              const SizedBox(height: 6),
              Text(companion.tagline, textAlign: TextAlign.center, style: text.bodySmall?.copyWith(color: MiraboColors.ink)),
            ],
          ),
        ),
        if (selected)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
            ),
          ),
      ],
    );
  }
}

class _WorldChip extends StatelessWidget {
  const _WorldChip({required this.world, required this.label, required this.selected, required this.onTap});
  final World world;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = worldStyle(world);
    final c = MiraboTokens.of(context).tint(style.color);
    return Semantics(
      checked: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? c : MiraboColors.paper,
        shape: StadiumBorder(side: BorderSide(color: selected ? c : MiraboColors.line, width: 1.5)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 18, 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(selected ? Icons.check_circle_rounded : style.icon, color: selected ? Colors.white : c, size: 24),
              const SizedBox(width: 8),
              Text(label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: selected ? Colors.white : MiraboColors.ink)),
            ]),
          ),
        ),
      ),
    );
  }
}
