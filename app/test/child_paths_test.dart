import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/games/drawing_game.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/ui/design/palette.dart';
import 'package:mirabo/ui/design/widgets.dart';

/// Percorsi essenziali bambino-genitore (docs/child-paths.md): ripresa,
/// voce che manca, comandi da ascoltare.
class _FakeDb implements LocalDb {
  _FakeDb(this.profile);
  ChildProfile profile;
  final Map<String, String> settings = {};

  @override
  Future<List<ChildProfile>> profiles() async => [profile];
  @override
  Future<String?> setting(String key) async => settings[key];
  @override
  Future<void> setSetting(String key, String value) async => settings[key] = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRepo implements StoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const emma = ChildProfile(id: 1, name: 'Emma', ageBand: AgeBand.b3to5, companion: CompanionId.bo, aloneSessionMinutes: 0, language: 'it');

  Future<(AppState, _FakeDb)> start({Future<bool> Function(String)? voiceCheck}) async {
    final db = _FakeDb(emma);
    final state = AppState(
      db: db,
      repo: _NoRepo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
      voiceCheck: voiceCheck,
    );
    await state.init();
    return (state, db);
  }

  test('storia: si riprende dalla schermata lasciata, per fascia; finita riparte da capo', () async {
    final (state, _) = await start();
    expect(await state.storyPosition(emma, 'lia'), 0);
    await state.saveStoryPosition(emma, 'lia', 4);
    expect(await state.storyPosition(emma, 'lia'), 4);
    // Un'altra fascia ha un'altra variante: non eredita il punto.
    expect(await state.storyPosition(emma.copyWith(ageBand: AgeBand.b6to7), 'lia'), 0);
    await state.saveStoryPosition(emma, 'lia', 0);
    expect(await state.storyPosition(emma, 'lia'), 0);
  });

  test('disegno: il foglio salvato torna uguale; uno illeggibile riparte vuoto', () async {
    const raw = '[{"c":4278190335,"w":18.0,"p":[10.0,20.0,30.0,40.0]},{"e":"⭐","x":5.0,"y":6.0}]';
    expect(encodeMarks(decodeMarks(raw)), raw);
    expect(decodeMarks('non è json'), isEmpty);

    final (state, _) = await start();
    expect(await state.savedDrawing(emma), isNull);
    await state.saveDrawing(emma, raw);
    expect(await state.savedDrawing(emma), raw);
    await state.saveDrawing(emma, null);
    expect(await state.savedDrawing(emma), isNull);
  });

  test('voce di sistema assente: la lingua è segnalata e il testo si mostra anche a chi non legge', () async {
    final (state, _) = await start(voiceCheck: (code) async => !code.startsWith('it'));
    expect(state.voiceMissingFor(emma), isFalse);
    await state.checkVoices();
    expect(state.voicesMissing, {'it'});
    expect(state.voiceMissingFor(emma), isTrue);

    final tokens = MiraboTokens.forProfile(lowStimulation: false, interaction: emma.interaction, voiceMissing: true);
    expect(emma.interaction.reading, ReadingLevel.none);
    expect(tokens.textMode, TextMode.full);
    expect(MiraboTokens.forProfile(lowStimulation: false, interaction: emma.interaction).textMode, TextMode.hidden);
  });

  testWidgets('SpokenButton: l\'altoparlante fa sentire il bottone senza premerlo', (tester) async {
    var pressed = 0;
    final heard = <String>[];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
      home: Scaffold(
        body: SpokenButton(label: 'Ancora', icon: Icons.replay_rounded, onPressed: () => pressed++, onListen: () => heard.add('Ancora')),
      ),
    ));
    await tester.tap(find.byIcon(Icons.volume_up_rounded));
    expect(heard, ['Ancora']);
    expect(pressed, 0);
    await tester.longPress(find.byType(ChunkyButton));
    expect(heard, ['Ancora', 'Ancora']);
    await tester.tap(find.byType(ChunkyButton));
    expect(pressed, 1);
  });
}
