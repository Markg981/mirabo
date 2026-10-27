import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  test('le date seguono la locale corrente', () async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('it');
    final d = DateTime(2026, 3, 9);
    expect(DateFormat.yMd('en').format(d), '3/9/2026');
    expect(DateFormat.yMd('it').format(d), '09/03/2026');
  });
}
