import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
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
      'ageBands': ['6-7'],
      'intro': {'bo': 'b', 'pilu': 'p', 'tango': 't'},
      'outro': {'bo': 'b', 'pilu': 'p', 'tango': 't'},
      'offscreen': 'o',
      'levels': <Map<String, dynamic>>[],
    });

ShelfItem _game(String id) => GameItem(gameCatalog.firstWhere((g) => g.id == id));

/// Un catalogo ampio: quattro attività per ognuna delle sei capacità.
List<Activity> _catalog() => [
      for (final area in ['sociale', 'vita-pratica', 'sensoriale', 'linguaggio', 'matematica', 'cultura'])
        for (var i = 0; i < 4; i++) _activity('$area$i', area),
    ];

List<ShelfItem> _items() => [for (final a in _catalog()) ActivityItem(a)];

Map<Capacity, int> _perCapacity(Iterable<String> keys, List<ShelfItem> available) {
  final byKey = {for (final i in available) i.key: i};
  final out = <Capacity, int>{};
  for (final k in keys) {
    final c = byKey[k]!.capacity;
    out[c] = (out[c] ?? 0) + 1;
  }
  return out;
}

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

  test('in automatico pochi materiali per fascia, una capacità per volta', () {
    final available = _items();
    for (final (band, size) in [(AgeBand.b3to5, 4), (AgeBand.b6to7, 6), (AgeBand.b8to10, 8)]) {
      final keys = Shelf.keysOf(Shelf.arrange(available, null, band));
      expect(keys, hasLength(size), reason: band.key);
      expect(_perCapacity(keys, available).values.every((n) => n <= Shelf.maxPerCapacity), isTrue);
    }
    // 3-5: le prime quattro capacità, una ciascuna.
    expect(Shelf.arrange(available, null, AgeBand.b3to5).keys,
        [Capacity.insieme, Capacity.mani, Capacity.sensi, Capacity.parole]);
    // 8-10: un giro completo, poi il secondo riparte dalla prima capacità.
    final big = Shelf.arrange(available, null, AgeBand.b8to10);
    expect(big[Capacity.insieme]!.length, 2);
    expect(big[Capacity.mani]!.length, 2);
    expect(big[Capacity.mondo]!.length, 1);
  });

  test('in automatico dentro una capacità si alternano le fonti', () {
    final available = <ShelfItem>[
      for (var i = 0; i < 4; i++) ActivityItem(_activity('vp$i', 'vita-pratica')),
      ActivityItem(_activity('au0', 'autonomia')),
      _game('drawing'),
      ActivityItem(_activity('cu0', 'cultura')),
    ];
    final shelf = Shelf.arrange(available, null, AgeBand.b8to10);

    expect(shelf.keys, [Capacity.mani, Capacity.mondo]);
    expect(shelf[Capacity.mani]!.map((i) => i.key), ['activity:vp0', 'activity:au0']);
    expect(shelf[Capacity.mondo]!.single.key, 'activity:cu0');
  });

  test('la scelta del genitore vale nel suo ordine, entro i tetti, e perde ciò che non è più disponibile', () {
    final available = <ShelfItem>[
      for (var i = 0; i < 5; i++) ActivityItem(_activity('vp$i', 'vita-pratica')),
      _game('memory'),
    ];
    final shelf = Shelf.arrange(
        available,
        [
          'activity:vp4',
          'activity:sparita',
          'game:memory',
          'activity:vp2',
          'activity:vp1',
          'activity:vp0',
        ],
        AgeBand.b6to7);

    expect(shelf[Capacity.mani]!.map((i) => i.key), ['activity:vp4', 'activity:vp2']);
    expect(shelf[Capacity.pensare]!.map((i) => i.key), ['game:memory']);
    expect(Shelf.arrange(available, const [], AgeBand.b6to7), isEmpty);

    // Il tetto totale vale anche per la scelta del genitore.
    final all = _items();
    expect(Shelf.keysOf(Shelf.arrange(all, [for (final i in all) i.key], AgeBand.b3to5)), hasLength(4));
  });

  group('rotazione', () {
    final available = _items();
    final t0 = DateTime(2026, 10, 5, 9);
    List<String> rotate(List<String> current,
            {List<ShelfUse> usage = const [], List<ShelfStint> history = const [], DateTime? now}) =>
        Shelf.rotate(
          available: available,
          band: AgeBand.b6to7,
          current: current,
          usage: usage,
          history: history,
          now: now ?? t0,
        );

    test('la prima mensola è quella che si riempie da sola', () {
      expect(rotate(const []), Shelf.keysOf(Shelf.arrange(available, null, AgeBand.b6to7)));
    });

    test('dopo una settimana cambia, ma un materiale usato tre volte resta', () {
      final first = rotate(const []);
      final worked = first[2];
      final next = rotate(first,
          usage: [for (var d = 1; d <= 3; d++) ShelfUse(worked, t0.add(Duration(days: d)))],
          history: [for (final k in first) ShelfStint(k, t0)],
          now: t0.add(const Duration(days: 7)));

      expect(next, contains(worked));
      expect(next, hasLength(6));
      // Tutto il resto è uscito.
      expect(next.where(first.contains), [worked]);
      expect(_perCapacity(next, available).values.every((n) => n <= Shelf.maxPerCapacity), isTrue);
    });

    test('resta anche ciò che il bambino vuole rifare, ma non ciò che ha usato una volta sola', () {
      final first = rotate(const []);
      final day2 = t0.add(const Duration(days: 2));
      final next = rotate(first,
          usage: [ShelfUse(first[0], day2, repeat: true), ShelfUse(first[1], day2)], now: t0.add(const Duration(days: 7)));
      expect(next, contains(first[0]));
      expect(next, isNot(contains(first[1])));
    });

    test('gli usi di più di una settimana fa non contano', () {
      final first = rotate(const []);
      final next = rotate(first,
          usage: [for (var d = 1; d <= 3; d++) ShelfUse(first[0], t0.add(Duration(days: d)))],
          now: t0.add(const Duration(days: 14)));
      expect(next, isNot(contains(first[0])));
    });

    test('resta al massimo metà della mensola: qualcosa di nuovo entra sempre', () {
      final first = rotate(const []);
      final next = rotate(first,
          usage: [
            for (final k in first) ...[
              ShelfUse(k, t0.add(const Duration(days: 1))),
              ShelfUse(k, t0.add(const Duration(days: 2))),
            ],
          ],
          now: t0.add(const Duration(days: 7)));
      expect(next.where(first.contains), hasLength(3));
      expect(next, hasLength(6));
    });

    test('un materiale appena uscito non rientra la settimana dopo', () {
      final w0 = rotate(const []);
      final h0 = [for (final k in w0) ShelfStint(k, t0)];
      final t1 = t0.add(const Duration(days: 7));
      final w1 = rotate(w0, history: h0, now: t1);
      final left = w0.where((k) => !w1.contains(k)).toList();
      expect(left, hasLength(6));

      final h1 = [
        for (final s in h0) ShelfStint(s.key, s.from, t1),
        for (final k in w1) ShelfStint(k, t1),
      ];
      final w2 = rotate(w1, history: h1, now: t1.add(const Duration(days: 7)));
      expect(w2.where(left.contains), isEmpty);
      expect(w2.where(w1.contains), isEmpty);
      expect(w2, hasLength(6));
    });

    test('con un catalogo piccolo la mensola non resta vuota', () {
      final few = available.where((i) => i.capacity == Capacity.mani).toList();
      List<String> turn(List<String> current, DateTime now) => Shelf.rotate(
          available: few, band: AgeBand.b6to7, current: current, usage: const [], history: const [], now: now);
      final first = turn(const [], t0);
      final next = turn(first, t0.add(const Duration(days: 7)));
      expect(first, hasLength(2));
      expect(next, hasLength(2));
      expect(next.where(first.contains), isEmpty);
    });
  });

  group('mensola automatica salvata', () {
    late DateTime now;
    late _FakeDb db;
    late AppState state;
    const base = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b6to7, companion: CompanionId.tango);

    setUp(() async {
      now = DateTime(2026, 10, 5, 9);
      db = _FakeDb(base);
      state = AppState(db: db, repo: _Repo(_catalog()), nameVoice: _SilentVoice(), clock: () => now);
      await state.init();
    });

    List<String> shown() => Shelf.keysOf(state.shelfFor(state.currentProfile!, mode: SessionMode.together));

    test('stessa settimana stessa mensola; dopo sette giorni cambia, ma ciò che è usato resta', () async {
      await state.rotateShelf(state.currentProfile!);
      final first = shown();
      expect(state.currentProfile!.shelfAuto, first);
      expect(first, hasLength(6));

      now = now.add(const Duration(days: 6, hours: 23));
      await state.rotateShelf(state.currentProfile!);
      expect(shown(), first);

      final worked = first[3];
      db.usage.addAll([for (var h = 1; h <= 3; h++) ShelfUse(worked, now.subtract(Duration(hours: h)))]);
      now = now.add(const Duration(hours: 1));
      await state.rotateShelf(state.currentProfile!);
      final second = shown();
      expect(second, isNot(first));
      expect(second, contains(worked));
      expect(second.length, lessThanOrEqualTo(Shelf.size(AgeBand.b6to7)));
      expect(state.currentProfile!.shelfRotatedAt, now);
    });

    test('"Cambia adesso" ruota subito; la scelta del genitore non si tocca', () async {
      await state.rotateShelf(state.currentProfile!);
      final first = shown();
      await state.rotateShelf(state.currentProfile!, force: true);
      expect(shown().where(first.contains), isEmpty);

      await state.setShelf(state.currentProfile!, [first[0]]);
      await state.rotateShelf(state.currentProfile!, force: true);
      expect(shown(), [first[0]]);
    });

    test('la mensola automatica resta nel profilo anche quando il genitore sceglie', () {
      final row = ChildProfile.fromRow(base.withAutoShelf(['activity:a'], now).withShelf(['activity:b']).toRow());
      expect(row.shelf, ['activity:b']);
      expect(row.shelfAuto, ['activity:a']);
      expect(row.shelfRotatedAt, now);
      expect(row.withShelf(null).shelfAuto, ['activity:a']);
    });
  });

  test('la mensola resta nel profilo; senza colonna (backup v4) è automatica', () {
    const base = ChildProfile(id: 1, name: 'T', ageBand: AgeBand.b6to7, companion: CompanionId.tango, readAlong: false);
    final chosen = base.withShelf(['activity:vp0', 'game:memory']);

    expect(ChildProfile.fromRow(chosen.toRow()).shelf, ['activity:vp0', 'game:memory']);
    expect(chosen.copyWith(gesturesDone: 2).shelf, ['activity:vp0', 'game:memory']);
    expect(chosen.readAlong, isFalse);
    expect(chosen.withShelf(null).shelf, isNull);
    expect(ChildProfile.fromRow(base.toRow()..remove('shelf')).shelf, isNull);
    expect(ChildProfile.fromRow(base.toRow()..remove('shelf_auto')..remove('shelf_rotated_at')).shelfAuto, isNull);
    // Una mensola svuotata dal genitore resta vuota, non torna automatica.
    expect(ChildProfile.fromRow(base.withShelf(const []).toRow()).shelf, isEmpty);
  });
}

/// Solo la parte di LocalDb che usa la mensola.
class _FakeDb implements LocalDb {
  _FakeDb(this.profile);
  ChildProfile profile;
  final List<ShelfUse> usage = [];
  final List<ShelfStint> history = [];

  @override
  Future<List<ChildProfile>> profiles() async => [profile];

  @override
  Future<String?> setting(String key) async => null;
  @override
  Future<void> updateProfile(ChildProfile p) async => profile = p;
  @override
  Future<List<ShelfUse>> shelfUsage(int profileId, {required DateTime since}) async =>
      usage.where((u) => !u.at.isBefore(since)).toList();
  @override
  Future<List<ShelfStint>> shelfHistory(int profileId) async => List.of(history);
  @override
  Future<void> moveShelf(int profileId,
      {required List<String> before, required List<String> after, required DateTime at}) async {
    for (var n = 0; n < history.length; n++) {
      final s = history[n];
      if (s.to == null && before.contains(s.key) && !after.contains(s.key)) history[n] = ShelfStint(s.key, s.from, at);
    }
    history.addAll([for (final k in after.where((k) => !before.contains(k))) ShelfStint(k, at)]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repo implements StoryRepository {
  _Repo(this._activities);
  final List<Activity> _activities;

  @override
  List<Story> storiesIn(String lang) => const [];
  @override
  List<Activity> activitiesIn(String lang) => _activities;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SilentVoice implements NameVoice {
  @override
  bool get enabled => false;

  @override
  Future<void> forget([int? profileId]) async {}

  @override
  Future<void> prepare(ChildProfile p) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
