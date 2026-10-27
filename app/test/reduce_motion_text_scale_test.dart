import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/child/story_reader.dart';
import 'package:mirabo/ui/design/palette.dart';

class _FakeDb implements LocalDb {
  @override
  Future<List<ChildProfile>> profiles() async =>
      [const ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b6to7, companion: CompanionId.bo, aloneSessionMinutes: 0)];
  @override
  Future<String?> setting(String key) async => null;
  @override
  Future<void> setSetting(String key, String value) async {}
  @override
  Future<void> addDiaryEntry(DiaryEntry entry) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRepo implements StoryRepository {
  @override
  List<Companion> companionsIn(String lang) => const [
        Companion(id: CompanionId.bo, name: 'Bo', kind: 'mammut', tagline: '', growth: ['piccolo', 'cresce', 'grande', 'grandissimo']),
      ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Una schermata con testo lungo e compagno: a testo 2x la colonna destra deve scorrere.
void main() {
  testWidgets('StoryReader a testo 2x: nessun overflow', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final ch in ['flutter_tts', 'com.ryanheise.just_audio.methods']) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel(ch), (_) async => null);
    }
    final variant = StoryVariant.fromJson({
      'ageBand': '6-7',
      'screens': [
        {
          'n': 1,
          'kind': 'situation',
          'illustration': {'alt': 'x', 'scene': {'bg': 'forest', 'items': []}},
          'text': List.filled(12, 'Una frase abbastanza lunga da occupare parecchio spazio.').join(' '),
          'companionLines': {'bo': 'Che bello', 'pilu': 'Che bello', 'tango': 'Che bello'},
        },
      ],
    });
    final story = Story(
      id: 't',
      version: 1,
      title: 'T',
      world: World.ambiente,
      topic: 't',
      variantFiles: const {},
      formats: const [],
      togetherOnly: false,
      keyPhrase: '',
      parentCardFile: '',
      sources: const [],
      variants: {AgeBand.b6to7: variant},
    );
    final state = AppState(
      db: _FakeDb(),
      repo: _NoRepo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
    );
    await state.init();
    addTearDown(state.dispose);
    await tester.pumpWidget(AppStateScope(
      state: state,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        theme: miraboTheme(dyslexiaFont: false, lowStimulation: true),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0), disableAnimations: true),
          child: child!,
        ),
        home: StoryReader(story: story),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    // Un overflow di layout fa fallire il test da solo (eccezione di Flutter).
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('"riduci movimento" del sistema spegne le animazioni', (tester) async {
    late MiraboTokens normale;
    late MiraboTokens ridotto;
    Widget app(bool off, void Function(MiraboTokens) set) => MaterialApp(
          theme: miraboTheme(dyslexiaFont: false, lowStimulation: false),
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: off),
            child: Builder(builder: (c) {
              set(MiraboTokens.of(c));
              return const SizedBox();
            }),
          ),
        );
    await tester.pumpWidget(app(false, (t) => normale = t));
    await tester.pumpWidget(app(true, (t) => ridotto = t));
    expect(normale.animate, isTrue);
    expect(ridotto.animate, isFalse);
  });
}
