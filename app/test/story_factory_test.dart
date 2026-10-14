import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/made_story.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/child/read_along_text.dart';
import 'package:mirabo/ui/child/story_factory.dart';

/// Solo la parte di LocalDb che usa la fabbrica.
class _FakeDb implements LocalDb {
  _FakeDb(this.profile);
  final ChildProfile profile;
  final List<MadeStory> saved = [];

  @override
  Future<List<ChildProfile>> profiles() async => [profile];

  @override
  Future<String?> setting(String key) async => null;
  @override
  Future<MadeStory> addMadeStory(MadeStory s) async {
    final row = s.toRow()..['id'] = saved.length + 1;
    saved.add(MadeStory.fromRow(row));
    return saved.last;
  }

  @override
  Future<List<MadeStory>> madeStories(int profileId) async => saved.reversed.toList();

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

void main() {
  /// Quello che il TTS ha dovuto dire, in ordine.
  final spoken = <String>[];

  setUp(() {
    spoken.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async {
        if (call.method == 'speak') spoken.add(call.arguments as String);
        return 1;
      },
    );
  });

  Future<(_FakeDb, AppState)> pumpFactory(WidgetTester tester, AgeBand band) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = _FakeDb(ChildProfile(id: 1, name: 'Emma', ageBand: band, companion: CompanionId.bo));
    final state = AppState(
      db: db,
      repo: _Repo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
    );
    await state.init();
    await tester.pumpWidget(AppStateScope(
      state: state,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        theme: miraboTheme(dyslexiaFont: false, lowStimulation: true),
        home: const StoryFactoryScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    return (db, state);
  }

  testWidgets('si sceglie un pezzo per passo, si salva e si legge', (tester) async {
    final (db, _) = await pumpFactory(tester, AgeBand.b5to7);
    expect(find.text('Qui troverai le storie che inventi.'), findsOneWidget);

    await tester.tap(find.text('Inventane una'));
    await tester.pumpAndSettle();
    expect(spoken.last, 'Chi è il protagonista?');

    // Senza scelta non si va avanti.
    await tester.tap(find.text('Avanti'));
    await tester.pumpAndSettle();
    expect(find.text('Chi è il protagonista?'), findsOneWidget);

    final picks = ['Un piccolo drago', 'Il bosco', 'Il temporale', 'La paura', 'Un orso gentile', 'Una festa'];
    for (final pick in picks) {
      await tester.tap(find.text(pick));
      await tester.pumpAndSettle();
      expect(spoken.last, pick, reason: 'il compagno dice il nome del pezzo');
      await tester.tap(find.text(pick == picks.last ? 'Leggiamo la storia!' : 'Avanti'));
      await tester.pumpAndSettle();
    }

    expect(db.saved, hasLength(1));
    expect(db.saved.single.title, isNull, reason: 'in 5–7 il titolo non si chiede');
    expect(db.saved.single.part(FactoryStep.helper), 'bear');
    const first = "C'era una volta un piccolo drago, che viveva in un bosco pieno di alberi.";
    expect(find.byType(ReadAlongText), findsOneWidget);
    expect(spoken.last, first);

    // Toccando una parola il compagno la ridice.
    await tester.tapAt(tester.getTopLeft(find.byType(ReadAlongText)) + const Offset(20, 14));
    await tester.pump();
    expect(spoken.last, "C'era");

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Avanti'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Fine'), findsOneWidget);
    expect(find.text('Una storia inventata da Emma'), findsOneWidget);
    expect(spoken.last, contains('La metto tra le tue storie'));

    await tester.tap(find.text('A domani!'));
    await tester.pumpAndSettle();
    expect(find.text('Il piccolo drago'), findsOneWidget, reason: 'la storia è tra "Le mie storie"');
  });

  testWidgets('in 7–10 si dà anche il titolo', (tester) async {
    final (db, _) = await pumpFactory(tester, AgeBand.b7to10);
    await tester.tap(find.text('Inventane una'));
    await tester.pumpAndSettle();
    for (final pick in ['Un robot gentile', 'La notte', 'La stellina caduta', 'Il coraggio', 'Una tartaruga saggia', 'La nanna']) {
      await tester.tap(find.text(pick));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Avanti'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Che titolo diamo alla storia?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'La scala per le stelle');
    await tester.tap(find.text('Leggiamo la storia!'));
    await tester.pumpAndSettle();
    expect(db.saved.single.title, 'La scala per le stelle');
    expect(find.text('La scala per le stelle'), findsOneWidget);

    // Sull'ultima pagina di 7–10 si provano altri finali, senza toccare la storia salvata.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Avanti'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Prova un altro finale'), findsOneWidget);
    await tester.tap(find.byType(ChoiceChip).first);
    await tester.pumpAndSettle();
    expect(spoken.last, contains('festa'));
    expect(db.saved.single.part(FactoryStep.ending), 'sleep');
  });

  testWidgets('il karaoke illumina solo la parola letta', (tester) async {
    String? tapped;
    Widget at(int word) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(body: ReadAlongText(text: 'Uno, due tre.', current: word, onWord: (w) => tapped = w)),
        );
    List<TextSpan> spans() =>
        (tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan).children!.cast<TextSpan>();

    await tester.pumpWidget(at(1));
    final lit = spans().where((s) => s.style?.backgroundColor != null).map((s) => s.text).toList();
    expect(lit, ['due']);
    await tester.pumpWidget(at(-1));
    expect(spans().where((s) => s.style?.backgroundColor != null), isEmpty);
    expect(tapped, isNull);
  });
}
