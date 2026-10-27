import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/ui/design/widgets.dart';
import 'package:mirabo/ui/parent/profile_form.dart';

class _SlowDb implements LocalDb {
  final List<ChildProfile> saved = [];
  final gate = Completer<void>();
  int inserts = 0;

  @override
  Future<List<ChildProfile>> profiles() async => List.of(saved);
  @override
  Future<ChildProfile> insertProfile(ChildProfile profile) async {
    inserts++;
    await gate.future; // DB lento
    final p = profile;
    saved.add(p);
    return p;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRepo implements StoryRepository {
  @override
  List<Companion> companionsIn(String lang) =>
      const [Companion(id: CompanionId.bo, name: 'Bo', kind: 'orso', tagline: 'ciao', growth: ['a', 'b'])];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('doppio tocco su Salva con DB lento crea un solo profilo', (tester) async {
    tester.view.physicalSize = const Size(1600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final previous = FlutterError.onError;
    FlutterError.onError = (d) {
      if (d.exceptionAsString().contains('ListTile background color')) return;
      previous?.call(d);
    };
    addTearDown(() => FlutterError.onError = previous);

    final db = _SlowDb();
    final state = AppState(
      db: db,
      repo: _FakeRepo(),
      nameVoice: NameVoice(enabled: false),
      voiceCheck: (_) async => true,
    );

    await tester.pumpWidget(AppStateScope(
      state: state,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [for (final l in AppLanguage.values) l.locale],
        home: const ProfileForm(firstRun: true),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.byType(TextField).first, 'Anna');
    await tester.tap(find.text('Bo'));
    await tester.pump();

    final button = find.byType(ChunkyButton).last;
    await tester.ensureVisible(button);
    await tester.tap(button);
    // Oltre la finestra anti-rimbalzo di ChunkyButton (600 ms), col DB ancora occupato.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(button, warnIfMissed: false);
    await tester.pump();

    db.gate.complete();
    await tester.pump(const Duration(milliseconds: 500));

    expect(db.inserts, 1);
    expect(state.profiles.length, 1);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
}
