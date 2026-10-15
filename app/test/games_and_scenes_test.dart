import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/games/game.dart';
import 'package:mirabo/games/memory_game.dart';
import 'package:mirabo/games/shapes_game.dart';
import 'package:mirabo/models/story.dart';

void main() {
  test('i giochi rispettano le fasce: il gioco del 15 solo per i grandi', () {
    final small = gamesFor(AgeBand.b3to5).map((g) => g.id);
    final big = gamesFor(AgeBand.b8to10).map((g) => g.id);
    expect(small, isNot(contains('puzzle15')));
    expect(big, contains('puzzle15'));
    expect(small, containsAll(['memory', 'balloons', 'shapes', 'drawing', 'xylophone']));
  });

  test('il memory cambia regola con la fascia, non solo numero di carte', () {
    final rules = {for (final b in AgeBand.values) MemoryGame.ruleFor(b)};
    expect(rules, hasLength(AgeBand.values.length));

    final rnd = math.Random(3);
    // 3-5: coppie di carte uguali.
    final small = MemoryGame.deal(AgeBand.b3to5, rnd);
    expect(small, hasLength(6));
    for (final c in small) {
      expect(small.where((x) => x.group == c.group).map((x) => x.emoji).toSet(), {c.emoji});
    }
    // 6-7: animale e cibo, due carte diverse dello stesso gruppo.
    final mid = MemoryGame.deal(AgeBand.b6to7, rnd);
    expect(mid, hasLength(12));
    for (final c in mid) {
      expect(mid.where((x) => x.group == c.group).map((x) => x.emoji).toSet(), hasLength(2));
    }
    // 8-10: terne animale, cibo, casa.
    final big = MemoryGame.deal(AgeBand.b8to10, rnd);
    expect(big, hasLength(15));
    for (final c in big) {
      expect(big.where((x) => x.group == c.group).map((x) => x.emoji).toSet(), hasLength(3));
    }
  });

  test('nelle relazioni ogni carta appartiene a un solo gruppo', () {
    final emojis = [for (final g in MemoryGame.relations) ...g.map((c) => c.emoji)];
    expect(emojis.toSet(), hasLength(emojis.length));
  });

  test('gli incastri girano i buchi da 6-7 in su', () {
    expect(ShapesGame.turnsHoles(AgeBand.b3to5), isFalse);
    expect(ShapesGame.turnsHoles(AgeBand.b6to7), isTrue);
    expect(ShapesGame.turnsHoles(AgeBand.b8to10), isTrue);
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
