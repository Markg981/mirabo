import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/content/package_installer.dart';

void main() {
  test('defaultAppVersion coincide con la versione di pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', multiLine: true)
        .firstMatch(pubspec);
    expect(m, isNotNull, reason: 'versione non trovata in pubspec.yaml');
    expect(defaultAppVersion, m!.group(1));
  });
}
