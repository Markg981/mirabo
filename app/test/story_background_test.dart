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
  Completer<int>? savedPosition;

  @override
  Future<int> storyPosition(ChildProfile p, String storyId) async => savedPosition?.future ?? 0;
  @override
  Future<void> saveStoryPosition(ChildProfile p, String storyId, int index) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> recordStory(Story story, {required bool completed}) async {
    if (completed) this.completed++;
  }
}


void main() {
  const emma = ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo, aloneSessionMinutes: 0, language: 'it');

  testWidgets('In background voce e registrazione si fermano, al ritorno la schermata riparte', (tester) async {
    final calls = <String>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    const channels = ['flutter_tts', 'com.ryanheise.just_audio.methods'];
    for (final c in channels) {
      messenger.setMockMethodCallHandler(MethodChannel(c), (call) async {
        calls.add('$c:${call.method}');
        return null;
      });
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

    await tester.pumpWidget(AppStateScope(
      state: state,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('it'),
        home: StoryReader(story: story),
      ),
    ));
    await tester.pumpAndSettle();

    calls.clear();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(calls, contains('flutter_tts:stop'));
    expect(calls.any((c) => c.endsWith(':speak')), isFalse);

    calls.clear();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(calls, contains('flutter_tts:speak'));
  });
}
