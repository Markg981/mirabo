import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/games/game.dart';
import 'package:mirabo/models/activity.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/shelf.dart';
import 'package:mirabo/models/story.dart';

Activity _activity(String id, String area, {String skill = 'x'}) => Activity.fromJson({
      'id': id,
      'version': 1,
      'title': id,
      'area': area,
      'skill': skill,
      'type': 'tapMatch',
      'ageBands': ['5-7'],
      'intro': {'bo': 'b', 'pilu': 'p', 'tango': 't'},
      'outro': {'bo': 'b', 'pilu': 'p', 'tango': 't'},
      'offscreen': 'o',
      'levels': <Map<String, dynamic>>[],
    });

ShelfItem _game(String id) => GameItem(gameCatalog.firstWhere((g) => g.id == id));

void main() {
  test('le aree e i giochi finiscono sotto le capacità', () {
    expect(capacityOfActivity(_activity('a', 'vita-pratica')), Capacity.mani);
    expect(capacityOfActivity(_activity('a', 'autonomia')), Capacity.mani);
    expect(capacityOfActivity(_activity('a', 'paure')), Capacity.insieme);
    expect(capacityOfActivity(_activity('a', 'cognitivo', skill: 'pregrafismo')), Capacity.parole);
    expect(capacityOfActivity(_activity('a', 'cognitivo', skill: 'numeri')), Capacity.pensare);
    expect(capacityOfGame('xylophone'), Capacity.sensi);
    expect(capacityOfGame('drawing'), Capacity.mani);
    expect(capacityOfGame('memory'), Capacity.pensare);
  });

  test('in automatico al massimo tre materiali per capacità, alternando le fonti', () {
    final available = <ShelfItem>[
      for (var i = 0; i < 4; i++) ActivityItem(_activity('vp$i', 'vita-pratica')),
      ActivityItem(_activity('au0', 'autonomia')),
      _game('drawing'),
      ActivityItem(_activity('cu0', 'cultura')),
    ];
    final shelf = Shelf.arrange(available, null);

    expect(shelf.keys, [Capacity.mani, Capacity.mondo]);
    expect(shelf[Capacity.mani]!.map((i) => i.key), ['activity:vp0', 'activity:au0', 'game:drawing']);
    expect(shelf[Capacity.mondo]!.single.key, 'activity:cu0');
  });

  test('la scelta del genitore vale nel suo ordine e perde ciò che non è più disponibile', () {
    final available = <ShelfItem>[
      for (var i = 0; i < 5; i++) ActivityItem(_activity('vp$i', 'vita-pratica')),
      _game('memory'),
    ];
    final shelf = Shelf.arrange(available, [
      'activity:vp4',
      'activity:sparita',
      'game:memory',
      'activity:vp2',
      'activity:vp1',
      'activity:vp0',
    ]);

    expect(shelf[Capacity.mani]!.map((i) => i.key), ['activity:vp4', 'activity:vp2', 'activity:vp1']);
    expect(shelf[Capacity.pensare]!.map((i) => i.key), ['game:memory']);
    expect(Shelf.arrange(available, const []), isEmpty);
  });

  test('la mensola resta nel profilo; senza colonna (backup v4) è automatica', () {
    const base = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b5to7, companion: CompanionId.tango);
    final chosen = base.withShelf(['activity:vp0', 'game:memory']);

    expect(ChildProfile.fromRow(chosen.toRow()).shelf, ['activity:vp0', 'game:memory']);
    expect(chosen.copyWith(gesturesDone: 2).shelf, ['activity:vp0', 'game:memory']);
    expect(chosen.withShelf(null).shelf, isNull);
    expect(ChildProfile.fromRow(base.toRow()..remove('shelf')).shelf, isNull);
    // Una mensola svuotata dal genitore resta vuota, non torna automatica.
    expect(ChildProfile.fromRow(base.withShelf(const []).toRow()).shelf, isEmpty);
  });
}
