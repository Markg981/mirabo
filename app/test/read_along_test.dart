import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/audio/narration.dart';
import 'package:mirabo/models/read_along.dart';

void main() {
  group('parole del testo', () {
    test('la punteggiatura resta fuori, gli apostrofi dentro', () {
      const text = "Ciao, Emma! L'albero dorme… sì.";
      final words = readAlongWords(text).map((w) => text.substring(w.start, w.end)).toList();
      expect(words, ['Ciao', 'Emma', "L'albero", 'dorme', 'sì']);
    });

    test('lettere accentate, tedesco e numeri', () {
      const text = 'Größer als 10 Bäume — très bien';
      final words = readAlongWords(text).map((w) => text.substring(w.start, w.end)).toList();
      expect(words, ['Größer', 'als', '10', 'Bäume', 'très', 'bien']);
    });

    test('dal carattere del TTS alla parola', () {
      final words = readAlongWords('Uno due tre');
      expect(wordAtChar(words, 0), 0);
      expect(wordAtChar(words, 3), 1, reason: 'lo spazio porta alla parola dopo');
      expect(wordAtChar(words, 4), 1);
      expect(wordAtChar(words, 10), 2);
      // Oltre il testo (la battuta del compagno letta dopo): nessuna parola.
      expect(wordAtChar(words, 30), -1);
    });

    test('dal tempo della registrazione alla parola', () {
      const timings = [(0, 'C’era'), (400, 'una'), (650, 'volta')];
      expect(wordAtTime(timings, 0), 0);
      expect(wordAtTime(timings, 399), 0);
      expect(wordAtTime(timings, 400), 1);
      expect(wordAtTime(timings, 5000), 2);
      expect(wordAtTime(const [(200, 'x')], 100), -1);
    });
  });

  group('registrazione con il nome', () {
    test('senza nome è un pezzo solo', () {
      expect(narrationOffsets(const []), [0]);
      expect(narrationTime([0], null, const Duration(milliseconds: 1200)), 1200);
    });

    test('i pezzi seguono gli slot del nome, in ordine', () {
      final offsets = narrationOffsets(const [3000, 1000]);
      // pezzo 0–1000, nome, pezzo 1000–3000, nome, resto da 3000
      expect(offsets, [0, null, 1000, null, 3000]);
      expect(narrationTime(offsets, 0, const Duration(milliseconds: 500)), 500);
      expect(narrationTime(offsets, 1, const Duration(milliseconds: 200)), isNull, reason: 'mentre si sente il nome');
      expect(narrationTime(offsets, 2, const Duration(milliseconds: 500)), 1500);
      expect(narrationTime(offsets, 4, Duration.zero), 3000);
    });

    test('nome all\'inizio: nessun pezzo vuoto', () {
      expect(narrationOffsets(const [0]), [null, 0]);
    });
  });
}
