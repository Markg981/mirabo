import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../l10n/l10n.dart';
import '../../models/story.dart';
import '../design/palette.dart';
import '../design/widgets.dart';

/// La storia di esempio dell'onboarding: ha anche un'attività per la casa.
const onboardingStoryId = 'sassolino-magico';

/// Onboarding dell'adulto, al primo avvio: cinque passi brevi, tutti saltabili.
/// Promessa, lingua e fascia, assaggio di una storia, attività reale con il
/// materiale, "Prova con tuo figlio". Non raccoglie dati, non chiede account,
/// non mostra prezzi. Si riapre dall'area adulti (`reopened`).
///
/// Punto di aggancio per il PIN degli adulti: [beforeChildProfile] viene
/// atteso dopo l'ultimo passo e prima di passare al profilo del bambino.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.reopened = false, this.beforeChildProfile});

  /// Riaperto dall'area adulti: niente scelta di lingua/fascia, si chiude con "Chiudi".
  final bool reopened;

  /// Facoltativo: es. la configurazione del PIN. Null per ora.
  final Future<void> Function(BuildContext context)? beforeChildProfile;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { promise, setup, taste, activity, go }

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _i = 0;
  late AppLanguage _language;
  AgeBand _band = AgeBand.b5to7;
  bool _init = false;
  Story? _story;

  List<_Step> get _steps => [
        _Step.promise,
        if (!widget.reopened) _Step.setup,
        if (_story != null) _Step.taste,
        if (_story?.homeActivity != null) _Step.activity,
        _Step.go,
      ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (!_init) {
      _init = true;
      _language = state.onboardingLanguage ?? AppLanguage.ofDevice();
    }
    _story = _loadStory(state);
  }

  Story? _loadStory(AppState state) {
    try {
      for (final s in state.repo.storiesIn(_language.code)) {
        if (s.id == onboardingStoryId) return s;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _finish() async {
    final state = AppStateScope.read(context);
    if (widget.reopened) {
      Navigator.of(context).pop();
      return;
    }
    await widget.beforeChildProfile?.call(context);
    await state.finishOnboarding(language: _language, band: _band);
  }

  void _next() {
    if (_i >= _steps.length - 1) {
      _finish();
    } else {
      setState(() => _i++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = _steps;
    final step = steps[_i.clamp(0, steps.length - 1)];
    final last = step == _Step.go;
    return Scaffold(
      body: SceneBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (var k = 0; k < steps.length; k++)
                          Container(
                            width: 28,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: k <= _i ? MiraboColors.navy : MiraboColors.navy.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        const Spacer(),
                        if (!last)
                          TextButton(
                            key: const Key('onboarding-skip'),
                            onPressed: _finish,
                            child: Text(l.onbSkip),
                          ),
                      ],
                    ),
                    Expanded(child: SingleChildScrollView(child: _body(context, step))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_i > 0)
                          TextButton(onPressed: () => setState(() => _i--), child: Text(l.back)),
                        const SizedBox(width: 12),
                        ChunkyButton(
                          key: Key(last ? 'onboarding-go' : 'onboarding-next'),
                          label: last ? (widget.reopened ? l.onbClose : l.onbGoButton) : l.next,
                          icon: last && !widget.reopened ? Icons.favorite_rounded : Icons.arrow_forward_rounded,
                          iconAfter: !last || widget.reopened,
                          color: MiraboColors.leaf,
                          height: 62,
                          onPressed: _next,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, _Step step) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    Widget fact(IconData icon, String t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [Icon(icon, size: 22), const SizedBox(width: 10), Expanded(child: Text(t, style: text.bodyLarge))]),
        );
    Widget head(String t) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Text(t, style: text.headlineSmall),
        );

    switch (step) {
      case _Step.promise:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          head(l.onbPromiseTitle),
          Text(l.onbPromiseBody, style: text.bodyLarge),
          const SizedBox(height: 16),
          // Claim verificati nel codice: nessuna dipendenza pubblicitaria, nessun account del
          // bambino, dati in locale (cloud opt-in), gratuita (README).
          fact(Icons.card_giftcard_rounded, l.onbFactFree),
          fact(Icons.cloud_off_rounded, l.onbFactOffline),
          fact(Icons.block_rounded, l.onbFactNoAds),
          fact(Icons.person_off_rounded, l.onbFactNoAccount),
        ]);
      case _Step.setup:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          head(l.onbSetupTitle),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final lang in AppLanguage.values)
              ChoiceChip(
                key: Key('onb-lang-${lang.code}'),
                label: Text(lang.nativeName),
                selected: _language == lang,
                onSelected: (_) {
                  setState(() => _language = lang);
                  AppStateScope.read(context).setOnboardingLanguage(lang);
                },
              ),
          ]),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final b in AgeBand.values)
              ChoiceChip(
                key: Key('onb-band-${b.key}'),
                label: Text('${b.key} · ${l.ageBandLabel(_bandKey(b))}'),
                selected: _band == b,
                onSelected: (_) => setState(() => _band = b),
              ),
          ]),
          const SizedBox(height: 12),
          Text(l.onbSetupHint, style: text.bodyMedium),
        ]);
      case _Step.taste:
        final s = _story!;
        final screens = s.variants[_band]?.screens ?? s.variants.values.firstOrNull?.screens ?? const [];
        final first = screens.map((x) => x.text).whereType<String>().firstOrNull ?? '';
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          head(l.onbTryTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.title, style: text.titleLarge),
                const SizedBox(height: 8),
                if (first.isNotEmpty) Text(first.replaceAll('{nome}', '').trim(), style: text.bodyLarge),
                const SizedBox(height: 8),
                Text('“${s.keyPhrase}”', style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Text(l.onbTryNote, style: text.bodyMedium),
        ]);
      case _Step.activity:
        final a = _story!.homeActivity!;
        final band = a.bands[_band] ?? a.bands.values.first;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          head(l.onbHomeTitle),
          Text(l.onbHomeIntro, style: text.bodyLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(band.goal, style: text.titleMedium),
                const SizedBox(height: 10),
                Text(l.homeActivityMaterials, style: text.labelLarge),
                for (final m in band.materials) Text('• $m', style: text.bodyLarge),
              ]),
            ),
          ),
        ]);
      case _Step.go:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          head(l.onbGoTitle),
          Text(l.onbGoBody, style: text.bodyLarge),
          const SizedBox(height: 16),
          fact(Icons.card_giftcard_rounded, l.onbFactFree),
          fact(Icons.cloud_off_rounded, l.onbFactOffline),
          fact(Icons.block_rounded, l.onbFactNoAds),
          fact(Icons.person_off_rounded, l.onbFactNoAccount),
        ]);
    }
  }

  static String _bandKey(AgeBand b) => switch (b) {
        AgeBand.b3to5 => 'small',
        AgeBand.b5to7 => 'mid',
        AgeBand.b7to10 => 'big',
      };
}
