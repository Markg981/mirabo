import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/data/usage_tracker.dart';

/// Solo la parte di LocalDb che usano le impostazioni.
class _FakeDb implements LocalDb {
  final map = <String, String>{};
  @override
  Future<String?> setting(String key) async => map[key];
  @override
  Future<void> setSetting(String key, String value) async => map[key] = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('conta solo il tempo in primo piano, per bambino e per giorno', () async {
    final db = _FakeDb();
    var now = DateTime(2026, 10, 14, 10, 0, 0);
    int? child = 1;
    final t = UsageTracker(db: db, profileId: () => child, clock: () => now);

    t.resume();
    now = now.add(const Duration(minutes: 5));
    t.pause(); // app in secondo piano: 5 min al bambino 1
    now = now.add(const Duration(minutes: 30)); // fuori dal primo piano: non conta
    t.resume();
    now = now.add(const Duration(minutes: 2));
    t.tick(); // ancora il bambino 1
    child = 2; // passa il tablet al fratello
    t.tick(); // main lo chiama a ogni cambio di stato
    now = now.add(const Duration(minutes: 3));
    t.pause();

    final one = await t.lastDays(1);
    final two = await t.lastDays(2);
    expect(one.last.minutes, 7);
    expect(two.last.minutes, 3);
    expect(one.length, 7);
    expect(one.first.seconds, 0);
  });

  test('dopo forget(id) un tick non riscrive i secondi del bambino eliminato', () async {
    final db = _FakeDb();
    var now = DateTime(2026, 10, 14, 10, 0, 0);
    int? child = 1;
    final t = UsageTracker(db: db, profileId: () => child, clock: () => now);
    t.resume();
    now = now.add(const Duration(minutes: 5));
    await t.forget(1); // il bambino 1 sta per essere eliminato
    db.map.removeWhere((k, _) => k.startsWith('usage.1.'));
    now = now.add(const Duration(minutes: 2));
    t.tick(force: true); // il listener di main dopo notifyListeners
    await t.flush();
    expect(db.map.keys.where((k) => k.startsWith('usage.1.')), isEmpty);
  });

  test('dopo wipeAll il nuovo bambino con lo stesso id riparte da zero', () async {
    final db = _FakeDb();
    var now = DateTime(2026, 10, 14, 10, 0, 0);
    int? child = 1;
    final t = UsageTracker(db: db, profileId: () => child, clock: () => now);
    t.resume();
    now = now.add(const Duration(minutes: 5));
    await t.forget(); // wipeAll
    db.map.clear();
    child = null;
    t.tick(force: true);
    await t.flush();
    child = 1; // AUTOINCREMENT riparte da 1
    final r = await t.lastDays(1);
    expect(r.last.seconds, 0);
    expect(db.map.keys.where((k) => k.startsWith('usage.')), isEmpty);
  });
}
