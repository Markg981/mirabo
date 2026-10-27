import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/app_localizations.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/ui/child/story_reader.dart';
import 'package:mirabo/ui/design/widgets.dart';

class _FakeDb implements LocalDb {
  _FakeDb(this.profile);
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

class _NoRepo implements StoryRepository {
  @override
  List<Companion> companionsIn(String lang) =>
      [const Companion(id: CompanionId.bo, name: 'Bo', kind: 'k', tagline: 't', growth: ['g'])];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Conta le registrazioni e rende lento il salvataggio, come un disco vero.
class _CountingState extends AppState {
  _CountingState(ChildProfile p)
      : super(
          db: _FakeDb(p),
          repo: _NoRepo(),
          nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
        );
  int completed = 0;
  bool failWrites = false;
  Completer<int>? savedPosition;

  @override
  Future<int> storyPosition(ChildProfile p, String storyId) async => savedPosition?.future ?? 0;
  @override
  Future<void> saveStoryPosition(ChildProfile p, String storyId, int index) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> recordStory(Story story, {required bool completed}) async {
    if (failWrites) throw const FileSystemException('disco pieno');
    if (completed) this.completed++;
  }
}

class _Obs extends NavigatorObserver {
  _Obs(this.popped);
  final List<Route<dynamic>> popped;
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => popped.add(route);
}

void main() {
  const emma = ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo, aloneSessionMinutes: 0, language: 'it');

  testWidgets('"Ho finito" due volte: una sola registrazione e una sola route rimossa', (tester) async {
    // TTS e audio non hanno plugin nei test.
    final messenger = tester.binding.defaultBinaryMessenger;
    const channels = ['flutter_tts', 'com.ryanheise.just_audio.methods'];
    for (final c in channels) {
      messenger.setMockMethodCallHandler(MethodChannel(c), (_) async => null);
    }
    addTearDown(() {
      for (final c in channels) {
        messenger.setMockMethodCallHandler(MethodChannel(c), null);
      }
    });

    final state = _CountingState(emma);
    await state.init();
    addTearDown(state.dispose);

    const story = Story(
      id: 'prova',
      version: 1,
      title: 'Prova',
      world: World.emozioni,
      topic: 't',
      variantFiles: {},
      formats: [],
      togetherOnly: false,
      keyPhrase: 'k',
      parentCardFile: '',
      sources: [],
      variants: {
        AgeBand.b3to5: StoryVariant(ageBand: AgeBand.b3to5, screens: [
          StoryScreen(n: 1, kind: ScreenKind.closing, illustration: Illustration(alt: 'a'), text: 'Fine'),
        ]),
      },
    );

    final popped = <Route<dynamic>>[];
    await tester.pumpWidget(AppStateScope(
      state: state,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        navigatorObservers: [_Obs(popped)],
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StoryReader(story: story))),
            child: const Text('apri'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();

    final done = find.byType(ChunkyButton);
    await tester.tap(done);
    await tester.tap(done, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(state.completed, 1);
    expect(popped.length, 1);
    expect(find.text('apri'), findsOneWidget);
  });

  testWidgets('se la registrazione fallisce il bambino esce comunque', (tester) async {
    // TTS e audio non hanno plugin nei test.
    final messenger = tester.binding.defaultBinaryMessenger;
    const channels = ['flutter_tts', 'com.ryanheise.just_audio.methods'];
    for (final c in channels) {
      messenger.setMockMethodCallHandler(MethodChannel(c), (_) async => null);
    }
    addTearDown(() {
      for (final c in channels) {
        messenger.setMockMethodCallHandler(MethodChannel(c), null);
      }
    });

    final state = _CountingState(emma)..failWrites = true;
    await state.init();
    addTearDown(state.dispose);

    const story = Story(
      id: 'prova',
      version: 1,
      title: 'Prova',
      world: World.emozioni,
      topic: 't',
      variantFiles: {},
      formats: [],
      togetherOnly: false,
      keyPhrase: 'k',
      parentCardFile: '',
      sources: [],
      variants: {
        AgeBand.b3to5: StoryVariant(ageBand: AgeBand.b3to5, screens: [
          StoryScreen(n: 1, kind: ScreenKind.closing, illustration: Illustration(alt: 'a'), text: 'Fine'),
        ]),
      },
    );

    final popped = <Route<dynamic>>[];
    await tester.pumpWidget(AppStateScope(
      state: state,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        navigatorObservers: [_Obs(popped)],
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StoryReader(story: story))),
            child: const Text('apri'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();

    final done = find.byType(ChunkyButton);
    await tester.tap(done);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(state.completed, 0);
    expect(popped.length, 1);
    expect(find.text('apri'), findsOneWidget);
  });

  testWidgets('la ripresa che arriva dopo "Avanti" non riporta indietro la schermata', (tester) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    const channels = ['flutter_tts', 'com.ryanheise.just_audio.methods'];
    for (final c in channels) {
      messenger.setMockMethodCallHandler(MethodChannel(c), (_) async => null);
    }
    addTearDown(() {
      for (final c in channels) {
        messenger.setMockMethodCallHandler(MethodChannel(c), null);
      }
    });

    final state = _CountingState(emma)..savedPosition = Completer<int>();
    await state.init();
    addTearDown(state.dispose);

    StoryScreen screen(int n, ScreenKind kind) => StoryScreen(n: n, kind: kind, illustration: const Illustration(alt: 'a'), text: 'Schermata $n');
    final story = Story(
      id: 'prova',
      version: 1,
      title: 'Prova',
      world: World.emozioni,
      topic: 't',
      variantFiles: const {},
      formats: const [],
      togetherOnly: false,
      keyPhrase: 'k',
      parentCardFile: '',
      sources: const [],
      variants: {
        AgeBand.b3to5: StoryVariant(ageBand: AgeBand.b3to5, screens: [
          screen(1, ScreenKind.hook),
          screen(2, ScreenKind.situation),
          screen(3, ScreenKind.situation),
          screen(4, ScreenKind.closing),
        ]),
      },
    );

    await tester.pumpWidget(AppStateScope(
      state: state,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        home: StoryReader(story: story),
      ),
    ));
    await tester.pump();
    expect(find.text('Schermata 1'), findsOneWidget);

    // Tocco rapidissimo su "Avanti" mentre la ripresa è ancora in corso.
    await tester.tap(find.byType(ChunkyButton).last);
    await tester.pump();
    expect(find.text('Schermata 2'), findsOneWidget);

    state.savedPosition!.complete(2);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Schermata 2'), findsOneWidget);
    expect(find.text('Schermata 3'), findsNothing);
  });
}
