import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/child/closing_screen.dart';

class _FakeDb implements LocalDb {
  @override
  Future<List<ChildProfile>> profiles() async =>
      [const ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b6to7, companion: CompanionId.bo, aloneSessionMinutes: 0)];
  @override
  Future<String?> setting(String key) async => null;

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

void main() {
  testWidgets('la chiusura riconosce il lavoro, non avvia nulla e si può tornare', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClosingScreen())),
            child: const Text('apri'),
          ),
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('apri'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Bel lavoro, Emma!'), findsOneWidget);
    // Nessun avvio automatico: la chiusura resta lì finché il bambino non torna.
    await tester.pump(const Duration(minutes: 5));
    expect(find.text('Bel lavoro, Emma!'), findsOneWidget);

    await tester.tap(find.text('Torna a casa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Bel lavoro, Emma!'), findsNothing);
  });
}
