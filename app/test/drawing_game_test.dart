import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/games/drawing_game.dart';
import 'package:mirabo/games/game.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

class _Db implements LocalDb {
  _Db(this.profile);
  final ChildProfile profile;
  final Map<String, String> settings = {};
  int writes = 0;
  Completer<void>? gate;

  @override
  Future<List<ChildProfile>> profiles() async => [profile];
  @override
  Future<String?> setting(String key) async {
    final g = gate;
    if (g != null) await g.future;
    return settings[key];
  }

  @override
  Future<void> setSetting(String key, String value) async {
    writes++;
    settings[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRepo implements StoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const emma = ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo, aloneSessionMinutes: 0, language: 'it');
  final key = AppState.drawingKey(emma.id);

  Future<(AppState, _Db)> start() async {
    final db = _Db(emma);
    final state = AppState(
      db: db,
      repo: _NoRepo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
    );
    await state.init();
    return (state, db);
  }

  Widget host(AppState state) => AppStateScope(
        state: state,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: DrawingGame(ctx: GameContext(band: AgeBand.b3to5, say: (_) async {}, onFinished: () {}, calm: false)),
          ),
        ),
      );

  final sheet = find.byWidgetPredicate((w) => w is CustomPaint && w.painter.runtimeType.toString() == '_SheetPainter');

  CustomPainter painter(WidgetTester t) => t.widget<CustomPaint>(sheet).painter!;

  testWidgets('shouldRepaint è falso a foglio invariato, vero dopo un segno', (tester) async {
    final (state, _) = await start();
    await tester.pumpWidget(host(state));
    await tester.pump();
    final before = painter(tester);
    await tester.pump();
    expect(painter(tester).shouldRepaint(before), isFalse);

    final g = await tester.startGesture(tester.getCenter(sheet));
    await g.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(painter(tester).shouldRepaint(before), isTrue);
    await g.up();
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('il salvataggio è a fine tratto e raggruppato, non a ogni punto', (tester) async {
    final (state, db) = await start();
    await tester.pumpWidget(host(state));
    await tester.pump();
    final g = await tester.startGesture(tester.getCenter(sheet));
    for (var i = 0; i < 20; i++) {
      await g.moveBy(const Offset(5, 0));
      await tester.pump();
    }
    expect(db.writes, 0);
    await g.up();
    await tester.pump(const Duration(seconds: 2));
    expect(db.writes, 1);
  });

  testWidgets('uscire prima del caricamento non cancella il disegno salvato', (tester) async {
    final (state, db) = await start();
    const saved = '[{"e":"⭐","x":10.0,"y":10.0}]';
    db.settings[key] = saved;
    db.gate = Completer<void>();
    await tester.pumpWidget(host(state));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    db.gate!.complete();
    await tester.pump();
    expect(db.settings[key], saved);
    expect(db.writes, 0);
  });

  testWidgets('uscendo con un tratto non ancora salvato, il disegno si salva', (tester) async {
    final (state, db) = await start();
    await tester.pumpWidget(host(state));
    await tester.pump();
    final g = await tester.startGesture(tester.getCenter(sheet));
    await g.up();
    await tester.pumpWidget(const SizedBox());
    expect(db.writes, 1);
    expect(db.settings[key], isNotEmpty);
  });
}
