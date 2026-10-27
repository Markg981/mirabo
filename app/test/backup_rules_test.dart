import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/backup_store.dart';

void main() {
  test('rotazione: restano le ultime 3, il vecchio formato è il più vecchio', () {
    final names = [
      BackupRules.legacyName,
      'mirabo-backup-20261010T090000Z.json',
      'mirabo-backup-20261012T090000Z.json',
      'mirabo-backup-20261011T090000Z.json',
      'altro.json',
    ];
    expect(BackupRules.newestFirst(names).first, 'mirabo-backup-20261012T090000Z.json');
    expect(BackupRules.toPrune(names), [BackupRules.legacyName]);
    expect(BackupRules.toPrune(names.take(2)), isEmpty);
  });

  test('i nomi nuovi si ordinano per data', () {
    final a = BackupRules.newName(DateTime.utc(2026, 10, 1));
    final b = BackupRules.newName(DateTime.utc(2026, 10, 2));
    expect(a.compareTo(b), lessThan(0));
    expect(BackupRules.newestFirst([a, b]).first, b);
  });

  test('download oltre il limite rifiutato', () async {
    Stream<List<int>> s() => Stream.fromIterable([List.filled(10, 1), List.filled(10, 1)]);
    expect((await BackupRules.readLimited(s(), max: 20)).length, 20);
    expect(BackupRules.readLimited(s(), max: 19), throwsFormatException);
  });
}
