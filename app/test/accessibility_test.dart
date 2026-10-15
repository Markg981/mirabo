import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/activity.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/models/themes.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/child/home_screen.dart';
import 'package:mirabo/ui/design/palette.dart';
import 'package:mirabo/ui/design/widgets.dart';

/// Quello che si verifica in automatico dell'analisi 7B (docs/accessibility.md):
/// contrasto dei colori, testo ingrandito, nomi e azioni per lo screen reader,
/// bassa stimolazione. VoiceOver e TalkBack sul dispositivo restano prove a mano.

const _accents = {
  'apricot': MiraboColors.apricot,
  'teal': MiraboColors.teal,
  'plum': MiraboColors.plum,
  'sky': MiraboColors.sky,
  'leaf': MiraboColors.leaf,
  'rose': MiraboColors.rose,
  'sun': MiraboColors.sun,
  'indigo': MiraboColors.indigo,
  'cyan': MiraboColors.cyan,
  'navy': MiraboColors.navy,
};

/// I fondi su cui sta il testo: crema, carta, fondo in bassa stimolazione, riga.
const _surfaces = {
  'cream': MiraboColors.cream,
  'paper': MiraboColors.paper,
  'lowStim': Color(0xFFF2F5F7),
  'line': MiraboColors.line,
};

class _Repo implements StoryRepository {
  @override
  List<Story> get stories => const [];
  @override
  List<Activity> get activities => const [];
  @override
  ThemeCatalog themes = ThemeCatalog.fromJson({'version': 1, 'themes': <String>[], 'cells': <Map<String, dynamic>>[]});
  @override
  List<Story> storiesIn(String lang) => const [];
  @override
  List<Activity> activitiesIn(String lang) => const [];
  @override
  List<Companion> companionsIn(String lang) => const [
        Companion(id: CompanionId.bo, name: 'Bo', kind: 'mammut', tagline: '', growth: ['piccolo', 'cresce', 'grande', 'grandissimo']),
      ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Db implements LocalDb {
  _Db(this.profile);
  ChildProfile profile;
  @override
  Future<List<ChildProfile>> profiles() async => [profile];
  @override
  Future<String?> setting(String key) async => null;
  @override
  Future<void> updateProfile(ChildProfile p) async => profile = p;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('contrasto (riferimento WCAG: 4,5:1 testo normale, 3:1 testo grande)', () {
    test('inchiostro, inchiostro tenue e blu notte su tutti i fondi del testo', () {
      for (final fg in {'ink': MiraboColors.ink, 'inkSoft': MiraboColors.inkSoft, 'navy': MiraboColors.navy}.entries) {
        for (final bg in _surfaces.entries) {
          expect(MiraboColors.contrast(fg.value, bg.value), greaterThanOrEqualTo(MiraboColors.minContrast),
              reason: '${fg.key} su ${bg.key}');
        }
      }
    });

    test('su ogni colore d\'accento, anche in bassa stimolazione, la scritta grande si legge', () {
      for (final low in [false, true]) {
        final tokens = MiraboTokens(lowStimulation: low);
        for (final a in _accents.entries) {
          final bg = tokens.tint(a.value);
          final fg = MiraboColors.onColor(bg, large: true);
          expect(MiraboColors.contrast(fg, bg), greaterThanOrEqualTo(MiraboColors.minContrastLarge),
              reason: '${a.key}${low ? ' (bassa stimolazione)' : ''}');
        }
      }
    });

    test('una selezione con scritte piccole ha fondo e testo a 4,5:1', () {
      for (final low in [false, true]) {
        final tokens = MiraboTokens(lowStimulation: low);
        for (final a in _accents.entries) {
          final on = MiraboColors.readable(tokens.tint(a.value));
          expect(MiraboColors.contrast(on.fg, on.bg), greaterThanOrEqualTo(MiraboColors.minContrast), reason: a.key);
        }
      }
    });

    testWidgets('la scritta dei bottoni è testo grande e si legge sul loro colore', (tester) async {
      for (final a in _accents.entries) {
        await tester.pumpWidget(MaterialApp(
          theme: miraboTheme(dyslexiaFont: false, lowStimulation: false),
          home: Scaffold(body: ChunkyButton(label: 'Fatto', color: a.value, onPressed: () {})),
        ));
        final style = tester.widget<Text>(find.text('Fatto')).style!;
        expect(style.fontSize, greaterThanOrEqualTo(18.67), reason: a.key);
        expect(style.fontWeight!.value, greaterThanOrEqualTo(FontWeight.w700.value), reason: a.key);
        expect(MiraboColors.contrast(style.color!, a.value), greaterThanOrEqualTo(MiraboColors.minContrastLarge), reason: a.key);
      }
    });
  });

  group('testo ingrandito', () {
    for (final scale in [1.5, 2.0]) {
      testWidgets('casa a ${scale}x: nessun contenuto tagliato, i comandi ci sono e si toccano', (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantics = tester.ensureSemantics();
        // Mensola scelta dall'adulto: la casa non la ruota (niente database da finto).
        final p = const ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo, aloneSessionMinutes: 0)
            .withShelf(const []);
        final state = AppState(db: _Db(p), repo: _Repo(), nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')));
        await state.init();
        addTearDown(state.dispose);
        await tester.pumpWidget(AppStateScope(
          state: state,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('it'),
            theme: miraboTheme(dyslexiaFont: false, lowStimulation: false),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const HomeScreen(),
          ),
        ));
        await tester.pump();
        // Un overflow di layout fa fallire il test da solo (eccezione di Flutter).
        expect(tester.takeException(), isNull);
        final l = lookupAppLocalizations(const Locale('it'));
        for (final label in [l.closingA11y, l.parentArea]) {
          final target = find.byTooltip(label);
          expect(target, findsOneWidget, reason: label);
          final box = tester.getRect(target);
          expect(const Rect.fromLTWH(0, 0, 1280, 800).contains(box.center), isTrue, reason: '$label fuori dallo schermo');
          expect(box.shortestSide, greaterThanOrEqualTo(48), reason: '$label troppo piccolo');
        }
        semantics.dispose();
      });
    }
  });

  group('screen reader', () {
    testWidgets('un bottone ha nome e azione, e la scritta non si legge due volte', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: miraboTheme(dyslexiaFont: false, lowStimulation: false),
        home: Scaffold(body: ChunkyButton(label: 'Ancora', icon: Icons.replay_rounded, onPressed: () {})),
      ));
      expect(
        tester.getSemantics(find.byType(ChunkyButton)),
        matchesSemantics(label: 'Ancora', isButton: true, hasTapAction: true, isEnabled: true, hasEnabledState: true),
      );
      semantics.dispose();
    });
  });

  group('bassa stimolazione', () {
    test('spegne le animazioni, non solo i colori', () {
      expect(const MiraboTokens(lowStimulation: true).animate, isFalse);
      expect(const MiraboTokens(lowStimulation: false).animate, isTrue);
    });

    test('la consegna non si ripete da sola più di una volta', () {
      final calm = MiraboTokens.forProfile(lowStimulation: true, interaction: const InteractionProfile(autonomy: 1));
      final usual = MiraboTokens.forProfile(lowStimulation: false, interaction: const InteractionProfile(autonomy: 1));
      expect(calm.repeatPrompt, isTrue);
      expect(calm.maxPromptRepeats, 1);
      expect(usual.maxPromptRepeats, 2);
    });
  });
}
