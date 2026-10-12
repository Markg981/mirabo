import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../app_state.dart';
import '../../models/profile.dart';
import '../design/palette.dart';
import '../design/widgets.dart';
import '../parent/adult_gate.dart';
import '../parent/profile_form.dart';
import 'category_screen.dart';
import 'companion_widget.dart';

/// "Chi gioca oggi?": con più figli, ognuno tocca il proprio compagno.
/// Il bambino si riconosce dal compagno prima che dal nome scritto.
/// Aggiungere un bambino passa dal gate degli adulti.
class ChooseChildScreen extends StatelessWidget {
  const ChooseChildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    const Spacer(),
                    RoundIconButton(
                      icon: Icons.lock_rounded,
                      tooltip: context.l10n.parentArea,
                      size: 56,
                      color: MiraboColors.navy,
                      onPressed: () => openParentArea(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: TitleBanner(
                  title: context.l10n.chooseWhoPlays,
                  leading: const Text('👋', style: TextStyle(fontSize: 38)),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Row(
                      children: [
                        for (final p in state.profiles) ...[
                          _ChildTile(profile: p, onTap: () => state.chooseChild(p)),
                          const SizedBox(width: 24),
                        ],
                        _AddTile(
                          onTap: () => AdultGate.open(
                            context,
                            then: () => Navigator.of(context).push(adultRoute((_) => const ProfileForm())),
                          ),
                          label: text,
                        ),
                      ],
                    ),
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

class _ChildTile extends StatelessWidget {
  const _ChildTile({required this.profile, required this.onTap});
  final ChildProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final companion = state.companionOf(profile);
    final text = Theme.of(context).textTheme;
    return BlockTile(
      onTap: onTap,
      width: 260,
      radius: 32,
      depth: 10,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      semanticLabel: '${profile.name}, ${context.l10n.chooseWith(companion.name)}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CompanionWidget(companion: companion, stage: profile.companionStage, size: 200, withHome: true),
          const SizedBox(height: 8),
          Text(profile.name, style: text.headlineMedium?.copyWith(color: MiraboColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(context.l10n.chooseWith(companion.name), style: text.titleMedium?.copyWith(color: MiraboColors.inkSoft)),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap, required this.label});
  final VoidCallback onTap;
  final TextTheme label;

  @override
  Widget build(BuildContext context) {
    return BlockTile(
      onTap: onTap,
      width: 200,
      height: 320,
      radius: 32,
      depth: 10,
      color: const Color(0xFFEAF6FC),
      semanticLabel: context.l10n.chooseAddA11y,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: MiraboColors.sky, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 5)),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 52),
          ),
          const SizedBox(height: 14),
          Text(context.l10n.chooseAdd, style: label.titleLarge?.copyWith(color: MiraboColors.navy)),
          Text(context.l10n.chooseAddHint, style: label.bodySmall),
        ],
      ),
    );
  }
}
