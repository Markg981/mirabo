import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/package_verifier.dart';

/// Un manifest illeggibile o di forma errata è sempre un PackageVerificationException,
/// mai un FormatException o un TypeError grezzo.
void main() {
  Uint8List zipWithManifest(String manifest) {
    final bytes = utf8.encode(manifest);
    final archive = Archive()..addFile(ArchiveFile('manifest.json', bytes.length, bytes));
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  final verifier = PackageVerifier(publicKeyHex: '00' * 32);

  for (final manifest in ['{', '[]', '"x"', 'null', '{"signature": 5}']) {
    test('manifest $manifest è rifiutato con PackageVerificationException', () {
      expect(verifier.open(zipWithManifest(manifest)), throwsA(isA<PackageVerificationException>()));
    });
  }
}
