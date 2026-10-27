import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/package_verifier.dart';

/// Un archivio oltre i limiti è rifiutato dalle intestazioni, prima di decomprimere.
void main() {
  final verifier = PackageVerifier(publicKeyHex: '00' * 32);

  Uint8List zip(Map<String, int> sizes) {
    final archive = Archive();
    sizes.forEach((name, n) => archive.addFile(ArchiveFile(name, n, Uint8List(n))));
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  Future<void> rifiutato(Uint8List bytes, String frammento) async {
    await expectLater(
      verifier.open(bytes),
      throwsA(isA<PackageVerificationException>().having((e) => e.message, 'message', contains(frammento))),
    );
  }

  test('archivio troppo grande', () => rifiutato(Uint8List(PackageVerifier.maxArchiveBytes + 1), 'archivio troppo grande'));

  test('troppe voci', () {
    final sizes = {for (var i = 0; i <= PackageVerifier.maxEntries; i++) 'f$i': 0};
    return rifiutato(zip(sizes), 'troppe voci');
  });

  test('rapporto di compressione sospetto', () {
    const n = 4 * 1024 * 1024;
    return rifiutato(zip({'a.bin': n}), 'rapporto di compressione');
  });

  test('un archivio nei limiti arriva al manifest', () {
    return rifiutato(zip({'a.txt': 10}), 'manifest.json assente');
  });
}
