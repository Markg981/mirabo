import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// Su dispositivo/emulatore, con SQLCipher e Keystore veri: i test in `test/`
/// usano SQLite in chiaro (ffi) e non possono accorgersi di una cifratura persa.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('il file del database è cifrato e senza chiave non si apre', (tester) async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, 'mirabo.db');

    final db = await LocalDb.open();
    await db.setSetting('prova_cifratura', 'valore-riconoscibile');
    expect(await db.setting('prova_cifratura'), 'valore-riconoscibile');
    await db.close();

    final bytes = await File(path).readAsBytes();
    expect(bytes.length, greaterThan(16));
    expect(String.fromCharCodes(bytes.sublist(0, 15)), isNot('SQLite format 3'));
    expect(String.fromCharCodes(bytes).contains('valore-riconoscibile'), isFalse);

    // Senza chiave la lettura deve fallire.
    final senzaChiave = await openDatabase(path, readOnly: true, singleInstance: false);
    await expectLater(
      senzaChiave.rawQuery('SELECT count(*) FROM sqlite_master'),
      throwsA(isA<DatabaseException>()),
    );
    await senzaChiave.close();

    // Con la chiave dell'app si riapre e il dato c'è ancora.
    final riaperto = await LocalDb.open();
    expect(await riaperto.setting('prova_cifratura'), 'valore-riconoscibile');
    await riaperto.removeSetting('prova_cifratura');
    await riaperto.close();
  });
}
