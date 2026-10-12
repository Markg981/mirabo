import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/games/game.dart';
import 'package:mirabo/games/memory_game.dart';
import 'package:mirabo/models/story.dart';

void main() {
  test('i giochi rispettano le fasce: il gioco del 15 solo per i grandi', () {
    final small = gamesFor(AgeBand.b3to5).map((g) => g.id);
    final big = gamesFor(AgeBand.b7to10).map((g) => g.id);
    expect(small, isNot(contains('puzzle15')));
    expect(big, contains('puzzle15'));
    expect(small, containsAll(['memory', 'balloons', 'shapes', 'drawing', 'xylophone']));
  });

  test('il memory cresce con la fascia', () {
    expect(MemoryGame.pairsFor(AgeBand.b3to5), lessThan(MemoryGame.pairsFor(AgeBand.b5to7)));
    expect(MemoryGame.pairsFor(AgeBand.b5to7), lessThan(MemoryGame.pairsFor(AgeBand.b7to10)));
  });

  test('una scena composta si legge con i valori di default', () {
    final ill = Illustration.fromJson({
      'alt': 'La cameretta di Lia con la torre',
      'scene': {
        'bg': 'room',
        'items': [
          {'e': '👧', 'x': 0.3, 'y': 0.6, 's': 0.3},
          {'paint': 'tower', 'variant': 'leaning', 'x': 0.6, 'y': 0.55, 's': 0.5, 'rot': 6},
        ],
      },
    });
    final scene = ill.scene!;
    expect(scene.background, 'room');
    expect(scene.dirty, isFalse);
    expect(scene.items.first.emoji, '👧');
    expect(scene.items.first.opacity, 1);
    expect(scene.items.last.paint, 'tower');
    expect(scene.items.last.rotation, 6);
    expect(scene.items.last.flag, isTrue);
  });

  test('senza scena l\'illustrazione resta solo descrizione', () {
    final ill = Illustration.fromJson({'alt': 'Una descrizione qualsiasi'});
    expect(ill.scene, isNull);
  });
}
