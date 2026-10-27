import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/audio/narration.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

void main() {
  late Directory tmp;
  late List<(String, String)> calls;
  late bool synthWorks;

  NameVoice voice({bool enabled = true}) => NameVoice(
        enabled: enabled,
        cacheDir: () async => tmp,
        playDir: () async => Directory('${tmp.path}/play'),
        keyProvider: () async => List.filled(32, 7),
        synth: (text, language, path) async {
          calls.add((text, language));
          if (!synthWorks) return false;
          await File(path).writeAsBytes([1, 2, 3]);
          return true;
        },
      );

  ChildProfile profile({int id = 1, String name = 'Emma', String language = 'it'}) => ChildProfile(
        id: id,
        name: name,
        ageBand: AgeBand.b6to7,
        companion: CompanionId.bo,
        language: language,
      );

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('mirabo_names');
    calls = [];
    synthWorks = true;
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  group('NameVoice', () {
    test('genera il nome una volta sola e poi lo riusa', () async {
      final v = voice();
      final a = await v.fileFor(profile());
      final b = await v.fileFor(profile());
      expect(a, isNotNull);
      expect(b!.path, a!.path);
      expect(calls, [('Emma', 'it-IT')]);

      // Anche dopo un riavvio (cache nuova in memoria) il file su disco basta.
      await voice().fileFor(profile());
      expect(calls, hasLength(1));
    });

    test('il nome non compare nel nome del file', () async {
      final f = await voice().fileFor(profile());
      expect(f!.path.toLowerCase(), isNot(contains('emma')));
    });

    test('un nome o una lingua nuovi rigenerano e cancellano il vecchio', () async {
      final v = voice();
      final old = await v.fileFor(profile());
      final renamed = await v.fileFor(profile(name: 'Emmy'));
      expect(renamed!.path, isNot(old!.path));
      expect(old.existsSync(), isFalse);

      await v.fileFor(profile(name: 'Emmy', language: 'en'));
      expect(calls.last, ('Emmy', 'en-GB'));
      expect(Directory('${tmp.path}/names').listSync(), hasLength(1));
      expect(Directory('${tmp.path}/play').listSync(), hasLength(1));
    });

    test('se la sintesi fallisce restituisce null e riprova la volta dopo', () async {
      final v = voice();
      synthWorks = false;
      expect(await v.fileFor(profile()), isNull);
      synthWorks = true;
      expect(await v.fileFor(profile()), isNotNull);
      expect(calls, hasLength(2));
    });

    test('forget cancella solo il profilo indicato, o tutti', () async {
      final v = voice();
      final emma = await v.fileFor(profile());
      final teo = await v.fileFor(profile(id: 2, name: 'Teo'));
      await v.forget(1);
      expect(emma!.existsSync(), isFalse);
      expect(teo!.existsSync(), isTrue);
      await v.forget();
      expect(teo.existsSync(), isFalse);
    });

    test("fuori dall'MVP non genera nulla e il nome non arriva al motore", () async {
      final v = voice(enabled: false);
      expect(await v.fileFor(profile()), isNull);
      await v.prepare(profile());
      expect(calls, isEmpty);
      expect(Directory('${tmp.path}/names').existsSync(), isFalse);
    });

    test('spento, forget toglie comunque i file di una versione precedente', () async {
      final old = await voice().fileFor(profile());
      await voice(enabled: false).forget();
      expect(old!.existsSync(), isFalse);
    });

    test('su disco in names/ resta solo il cifrato; il chiaro si rigenera senza TTS', () async {
      final v = voice();
      final f = await v.fileFor(profile());
      final names = Directory('${tmp.path}/names').listSync().whereType<File>().toList();
      expect(names.every((e) => e.path.endsWith('.enc')), isTrue);
      expect(names.single.lengthSync(), greaterThan(3));
      expect(names.single.readAsBytesSync(), isNot([1, 2, 3]));
      f!.deleteSync();
      final again = await voice().fileFor(profile());
      expect(again!.readAsBytesSync(), [1, 2, 3]);
      expect(calls, hasLength(1));
    });

    test('un file in chiaro di una versione precedente in names/ viene tolto', () async {
      final legacy = File('${tmp.path}/names/name_1_abc.wav')..createSync(recursive: true);
      legacy.writeAsBytesSync([9, 9]);
      await voice().fileFor(profile());
      expect(legacy.existsSync(), isFalse);
    });

    test('prepare non fallisce mai', () async {
      final v = NameVoice(cacheDir: () async => throw const FileSystemException('no'));
      await v.prepare(profile());
    });
  });

  group('narrationWithName', () {
    final narration = Uri.file('/a/n.opus');
    final name = Uri.file('/a/name.wav');

    test('senza punti è la registrazione intera', () {
      expect(narrationWithName(narration, name, const []), isA<UriAudioSource>());
      expect(narrationWithName(narration, null, const [1200]), isA<UriAudioSource>());
    });

    test('alterna pezzi e nome nei punti indicati', () {
      final src = narrationWithName(narration, name, const [3000, 1200]) as ConcatenatingAudioSource;
      final shape = src.children.map((c) => c is ClippingAudioSource
          ? 'clip ${c.start?.inMilliseconds}-${c.end?.inMilliseconds}'
          : 'nome').toList();
      expect(shape, ['clip 0-1200', 'nome', 'clip 1200-3000', 'nome', 'clip 3000-null']);
    });

    test('un nome all\'inizio non lascia un pezzo vuoto', () {
      final src = narrationWithName(narration, name, const [0]) as ConcatenatingAudioSource;
      expect(src.children.first, isNot(isA<ClippingAudioSource>()));
      expect(src.children, hasLength(2));
    });
  });
}
