import 'dart:async';
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
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/activity/activity_player.dart';

class _Db implements LocalDb {
  _Db(this.progressFuture);
  final Future<ActivityProgress> Function() progressFuture;
  @override
  Future<List<ChildProfile>> profiles() async =>
      [const ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b6to7, companion: CompanionId.bo, aloneSessionMinutes: 0)];
  @override
  Future<String?> setting(String key) async => null;
  @override
  Future<ActivityProgress> progress(int profileId, String activityId) => progressFuture();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repo implements StoryRepository {
  @override
  List<Companion> companionsIn(String lang) => const [
        Companion(id: CompanionId.bo, name: 'Bo', kind: 'mammut', tagline: '', growth: ['piccolo', 'cresce', 'grande', 'grandissimo']),
      ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _activity = Activity(
  id: 'a1',
  version: 1,
  title: 'Prova',
  area: ActivityArea.values.first,
  skill: 's',
  type: ActivityType.tapMatch,
  ageBands: {AgeBand.b6to7},
  togetherSuggested: false,
  intro: CompanionLines.fromJson({'bo': 'a', 'pilu': 'a', 'tango': 'a'}),
  outro: CompanionLines.fromJson({'bo': 'a', 'pilu': 'a', 'tango': 'a'}),
  offscreen: '',
  levels: const [{}],
);

void main() {
  Future<void> open(WidgetTester tester, Future<ActivityProgress> Function() progress) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = AppState(
      db: _Db(progress),
      repo: _Repo(),
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
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ActivityPlayer(activity: _activity))),
            child: const Text('apri'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('durante il caricamento la X permette di uscire', (tester) async {
    final never = Completer<ActivityProgress>();
    await open(tester, () => never.future);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ActivityPlayer), findsNothing);
    expect(find.text('apri'), findsOneWidget);
  });

  testWidgets('se la lettura del progresso fallisce si parte comunque', (tester) async {
    await open(tester, () => Future<ActivityProgress>.error(Exception('db')));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Prova'), findsOneWidget);
  });
}
