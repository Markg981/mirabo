import 'package:flutter/material.dart';

import 'adult_gate.dart';

import '../../app_state.dart';
import '../../features.dart';
import '../../content/story_repository.dart';
import '../../l10n/l10n.dart';
import '../../models/profile.dart';
import '../../models/story.dart';
import '../child/companion_widget.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import 'backup_section.dart';

/// Creazione o modifica di un profilo bambino. Lo compila il genitore.
/// Al primo avvio è l'unica schermata; il compagno si sceglie una volta sola.
class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, this.existing, this.firstRun = false, this.initialLanguage, this.initialBand});
  final ChildProfile? existing;
  final bool firstRun;

  /// Scelte già fatte nell'onboarding dell'adulto (solo per un profilo nuovo).
  final AppLanguage? initialLanguage;
  final AgeBand? initialBand;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late AgeBand _band = widget.existing?.ageBand ?? widget.initialBand ?? AgeBand.b6to7;

  /// Un profilo con la fascia di prima (5-7, 7-10): nessuna fascia è scelta
  /// finché l'adulto non ne tocca una, e salvare senza sceglierla non la conferma.
  late bool _bandConfirmed = widget.existing?.bandToConfirm == null;
  CompanionId? _companion;
  late Set<World> _worlds = widget.existing?.enabledWorlds ?? World.values.toSet();
  late bool _safetyTogetherOnly = widget.existing?.safetyTogetherOnly ?? true;
  late bool _dyslexia = widget.existing?.dyslexiaFont ?? false;
  late bool _lowStim = widget.existing?.lowStimulation ?? false;
  late bool _readAlong = widget.existing?.readAlong ?? true;
  late int _aloneMinutes = widget.existing?.aloneSessionMinutes ?? 20;
  late String _language = widget.existing?.language ?? (widget.initialLanguage ?? AppLanguage.ofDevice()).code;

  /// Profilo di interazione: segue la fascia d'età finché il genitore non tocca un asse.
  late InteractionProfile _interaction = widget.existing?.interaction ?? InteractionProfile.forAge(_band);
  late bool _interactionChosen = widget.existing != null;

  void _setBand(AgeBand b) => setState(() {
        _band = b;
        _bandConfirmed = true;
        if (!_interactionChosen) _interaction = InteractionProfile.forAge(b);
      });

  void _setInteraction(InteractionProfile p) => setState(() {
        _interaction = p;
        _interactionChosen = true;
      });

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
        readAlong: _readAlong,
        aloneSessionMinutes: _aloneMinutes,
        language: _language,
        interaction: _interaction,
      ));
    } else {
      await state.updateProfile(existing.copyWith(
        name: _name.text.trim(),
        ageBand: _band,
        bandConfirmed: _bandConfirmed,
        // Il compagno si può cambiare: storie, disegni e progressi stanno sul
        // profilo, non sul personaggio, e non si perde niente.
        companion: _companion,
        enabledWorlds: _worlds,
        safetyTogetherOnly: _safetyTogetherOnly,
        dyslexiaFont: _dyslexia,
        lowStimulation: _lowStim,
        readAlong: _readAlong,
        aloneSessionMinutes: _aloneMinutes,
        language: _language,
        interaction: _interaction,
      ));
    }
    if (mounted && !widget.firstRun) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final editing = widget.existing != null;
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    final companions = state.repo.companionsIn(AppLanguage.ofDevice().code);
    final title = widget.firstRun ? l.profileWelcome : (editing ? l.profileEdit : l.profileNew);

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
                  const SizedBox(height: 8),
                  // Tablet nuovo o app reinstallata: si riparte dal backup su Drive
                  // (fuori dall'MVP, Features.cloudBackup).
                  if (Features.cloudBackup)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.settings_backup_restore_rounded),
                        label: Text(l.profileRestoreLink),
                        onPressed: () => restoreFromDrive(context),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                FormSection(
                  icon: Icons.child_care_rounded,
                  color: MiraboColors.sky,
                  title: l.profileChild,
                  subtitle: widget.firstRun ? l.profileFirstRunHint : null,
                  children: [
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(labelText: l.profileName, helperText: l.profileNameHint),
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    Text(l.profileAge, style: text.titleSmall),
                    if (widget.existing?.bandToConfirm case final old? when !_bandConfirmed) ...[
                      const SizedBox(height: 6),
                      Text(l.profileBandToConfirm(old.key.replaceAll('-', '–')), style: text.bodyMedium),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final b in AgeBand.values) ...[
                          Expanded(
                            child: _AgeOption(
                              label: l.ageBandLabel(_bandKey(b)),
                              years: l.profileYears(b.key),
                              selected: _bandConfirmed && _band == b,
                              onTap: () => _setBand(b),
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
                  icon: Icons.translate_rounded,
                  color: MiraboColors.indigo,
                  title: l.profileLanguage,
                  subtitle: l.profileLanguageHint,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final lang in AppLanguage.values)
                          ChoiceChip(
                            label: Text(lang.nativeName),
                            selected: _language == lang.code,
                            onSelected: (_) => setState(() => _language = lang.code),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FormSection(
                  icon: Icons.pets_rounded,
                  color: MiraboColors.apricot,
                  title: l.profileCompanion,
                  subtitle: editing ? l.profileCompanionEditHint : l.profileCompanionNewHint,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final c in companions) ...[
                          Expanded(
                            child: _CompanionOption(
                              companion: c,
                              selected: _companion == c.id,
                              onTap: () => setState(() => _companion = c.id),
                            ),
                          ),
                          if (c != companions.last) const SizedBox(width: 14),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FormSection(
                  icon: Icons.public_rounded,
                  color: MiraboColors.leaf,
                  title: l.profileWorlds,
                  subtitle: l.profileWorldsHint,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final w in World.values)
                          _WorldChip(
                            world: w,
                            label: l.worldLong(w.name),
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
                      title: Text(l.profileSafetyTogether),
                      subtitle: Text(l.profileSafetyTogetherHint),
                      onChanged: (v) => setState(() => _safetyTogetherOnly = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FormSection(
                  icon: Icons.back_hand_rounded,
                  color: MiraboColors.teal,
                  title: l.profileInteraction,
                  subtitle: l.profileInteractionHint(_name.text.trim().isEmpty ? '…' : _name.text.trim()),
                  children: [
                    InteractionAxisPicker<int>(
                      title: l.profileHands,
                      hint: l.profileHandsHint,
                      value: _interaction.hands,
                      options: {1: l.hands1, 2: l.hands2, 3: l.hands3},
                      onChanged: (v) => _setInteraction(_interaction.copyWith(hands: v)),
                    ),
                    const SizedBox(height: 18),
                    InteractionAxisPicker<ReadingLevel>(
                      title: l.profileReading,
                      hint: l.profileReadingHint,
                      value: _interaction.reading,
                      options: {
                        ReadingLevel.none: l.readingNone,
                        ReadingLevel.letters: l.readingLetters,
                        ReadingLevel.words: l.readingWords,
                        ReadingLevel.fluent: l.readingFluent,
                      },
                      onChanged: (v) => _setInteraction(_interaction.copyWith(reading: v)),
                    ),
                    const SizedBox(height: 18),
                    InteractionAxisPicker<int>(
                      title: l.profileAutonomy,
                      hint: l.profileAutonomyHint,
                      value: _interaction.autonomy,
                      options: {1: l.autonomy1, 2: l.autonomy2, 3: l.autonomy3},
                      onChanged: (v) => _setInteraction(_interaction.copyWith(autonomy: v)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FormSection(
                  icon: Icons.tune_rounded,
                  color: MiraboColors.plum,
                  title: l.profileAccess,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _dyslexia,
                      title: Text(l.profileDyslexia),
                      subtitle: Text(l.profileDyslexiaHint),
                      onChanged: (v) => setState(() => _dyslexia = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _lowStim,
                      title: Text(l.profileLowStim),
                      subtitle: Text(l.profileLowStimHint),
                      onChanged: (v) => setState(() => _lowStim = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _readAlong,
                      title: Text(l.profileReadAlong),
                      subtitle: Text(l.profileReadAlongHint),
                      onChanged: (v) => setState(() => _readAlong = v),
                    ),
                    const Divider(height: 28),
                    Row(
                      children: [
                        Expanded(child: Text(l.profileAloneSession, style: text.titleMedium)),
                        Text(_aloneMinutes == 0 ? l.profileNoLimit : l.profileMinutes(_aloneMinutes),
                            style: text.titleMedium?.copyWith(color: MiraboColors.teal)),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _aloneMinutes == 0,
                      title: Text(l.profileNoLimit),
                      subtitle: Text(l.winddownHint),
                      onChanged: (v) => setState(() => _aloneMinutes = v ? 0 : 20),
                    ),
                    if (_aloneMinutes > 0)
                      Slider(
                        value: _aloneMinutes.toDouble(),
                        min: 10,
                        max: 30,
                        divisions: 4,
                        label: l.profileMinutesShort(_aloneMinutes),
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
                          if (!await AdultGate.confirm(context)) return;
                          await state.deleteProfile(widget.existing!.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        label: Text(l.profileDelete),
                      ),
                    const Spacer(),
                    if (!_valid)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          _name.text.trim().isEmpty ? l.profileMissingName : l.profileMissingCompanion,
                          style: text.bodySmall,
                        ),
                      ),
                    ChunkyButton(
                      label: widget.firstRun ? l.profileStart : l.save,
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

  static String _bandKey(AgeBand b) => switch (b) {
        AgeBand.b3to5 => 'small',
        AgeBand.b6to7 => 'mid',
        AgeBand.b8to10 => 'big',
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
                Text(context.l10n.appTagline,
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

/// Un asse del profilo di interazione: titolo, spiegazione, livelli in fila.
class InteractionAxisPicker<T> extends StatelessWidget {
  const InteractionAxisPicker({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String title;
  final String hint;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: text.titleSmall),
        Text(hint, style: text.bodySmall),
        const SizedBox(height: 10),
        SegmentedButton<T>(
          showSelectedIcon: false,
          segments: [for (final e in options.entries) ButtonSegment(value: e.key, label: Text(e.value))],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.single),
        ),
      ],
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
    // Selezionata porta anche gli anni in piccolo: il fondo si scurisce quanto basta.
    final c = MiraboColors.forWhiteText(MiraboTokens.of(context).tint(MiraboColors.sky));
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
              style: text.labelMedium?.copyWith(color: selected ? Colors.white : MiraboColors.inkSoft)),
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
    final on = MiraboColors.readable(c);
    return Semantics(
      checked: selected,
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: selected ? on.bg : MiraboColors.paper,
        shape: StadiumBorder(side: BorderSide(color: selected ? on.bg : MiraboColors.line, width: 1.5)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 18, 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(selected ? Icons.check_circle_rounded : style.icon, color: selected ? on.fg : c, size: 24),
              const SizedBox(width: 8),
              Text(label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: selected ? on.fg : MiraboColors.ink)),
            ]),
          ),
        ),
      ),
    );
  }
}
