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
import 'package:mirabo/ui/design/widgets.dart';

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

Map<String, dynamic> _lines(String t) => {'bo': t, 'pilu': t, 'tango': t};

Map<String, dynamic> _dialogue(int n, String optId) => {
      'n': n,
      'kind': 'dialogue',
      'illustration': {'alt': 'x', 'scene': {'bg': 'forest', 'items': []}},
      'text': 'Domanda $n',
      'dialogue': {
        'together': 'Chiedi $n',
        'alone': {
          'prompt': _lines('Prompt $n'),
          'options': [
            {'id': optId, 'icon': 'plant', 'label': 'Scelta $n', 'reaction': _lines('Reazione $n')},
          ],
        },
      },
    };

/// Se lo stato del dialogo non si azzera fra le schermate, il secondo dialogo
/// parte già rispondibile e cerca una risposta che non esiste fra le sue opzioni.
void main() {
  testWidgets('il secondo dialogo parte non rispondibile e non lancia', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final ch in ['flutter_tts', 'com.ryanheise.just_audio.methods']) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel(ch), (_) async => null);
    }
    final variant = StoryVariant.fromJson({
      'ageBand': '6-7',
      'screens': [_dialogue(1, 'a'), _dialogue(2, 'b')],
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
        home: StoryReader(story: story),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Scelta 1'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Reazione 1'), findsWidgets);

    final next = find.byWidgetPredicate((w) => w is ChunkyButton && w.onPressed != null);
    await tester.tap(next);
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Scelta 2'), findsOneWidget);
    expect(find.text('Prompt 2'), findsWidgets);
    expect(find.text('Reazione 1'), findsNothing);
    expect(find.text('Reazione 2'), findsNothing);
    // Il secondo dialogo non è ancora rispondibile: "Avanti" resta spento.
    expect(find.byWidgetPredicate((w) => w is ChunkyButton && w.onPressed != null), findsNothing);
  });
}
