import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/package_verifier.dart';

/// Stesso vettore e stessa uscita attesa di studio/tests/test_manifest_names.py:
/// la forma canonica deve coincidere byte per byte con quella di studio/pack.py.
void main() {
  test('JSON canonico con caratteri non ASCII uguale a quello di Python', () {
    final vettore = {
      'é': 1,
      'a': ['ü', '€', '\u{1F600}'],
      'z': {'！': 'x', 'b': 'è"\\\n'},
    };
    expect(PackageVerifier.canonicalJson(vettore), '{"a":["ü","€","😀"],"z":{"b":"è\\"\\\\\\n","！":"x"},"é":1}');
  });
}
