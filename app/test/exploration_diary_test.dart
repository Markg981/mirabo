import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/exploration_diary.dart';
import 'package:mirabo/models/activity.dart';

void main() {
  Map<String, Object?> round(String skill, String at, {int attempts = 1}) =>
      {'skill': skill, 'at': at, 'attempts': attempts, 'hints': 0};

  final areas = {'forme': ActivityArea.values.first, 'colori': ActivityArea.values.first};

  test('i temi contano presenze e giorni diversi, non esiti né tentativi', () {
    final t = ExplorationDiary.themes([
      round('forme', '2026-10-01T10:00:00'),
      round('forme', '2026-10-01T10:05:00', attempts: 4),
      round('forme', '2026-10-03T09:00:00'),
      round('colori', '2026-10-02T09:00:00'),
      round('sconosciuta', '2026-10-02T09:00:00'),
    ], areas);
    expect(t.map((e) => e.skill), ['forme', 'colori']);
    expect(t.first.rounds, 3);
    expect(t.first.days, 2);
    expect(t.first.resumed, isTrue);
    expect(t.last.resumed, isFalse);
  });

  test('nessun round, nessun tema (non si dice che "non l\'ha fatto")', () {
    expect(ExplorationDiary.themes(const [], areas), isEmpty);
  });

  test('una osservazione del genitore si legge e si cancella in JSON', () {
    final n = ParentNote(when: DateTime(2026, 10, 1, 8), text: 'Ha chiesto perché le foglie cadono');
    final back = ParentNote.fromJson(n.toJson().cast<String, dynamic>());
    expect(back.text, n.text);
    expect(back.when, n.when);
  });
}
