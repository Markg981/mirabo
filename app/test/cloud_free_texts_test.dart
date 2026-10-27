import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/features.dart';
import 'package:mirabo/l10n/app_localizations.dart';

// Con Features.cloudBackup spento (default) le schermate di onboarding, area
// genitori e cancellazione dati mostrano le varianti "Local": nessuna deve
// promettere cloud o Drive che la build non offre.
void main() {
  test('build di default: backup cloud spento', () {
    expect(Features.cloudBackup, isFalse);
  });

  for (final lang in ['it', 'en', 'de', 'es', 'fr']) {
    test('testi senza cloud/Drive con il flag spento ($lang)', () {
      final l = lookupAppLocalizations(Locale(lang));
      final shown = {
        'onbFactOfflineLocal': l.onbFactOfflineLocal,
        'parentDataHintLocal': l.parentDataHintLocal,
        'dataWipeBodyLocal': l.dataWipeBodyLocal,
        // I backup di iCloud del sistema operativo sono un fatto del telefono,
        // non una promessa dell'app: il nome iCloud resta.
        'dataOutsideBodyLocal': l.dataOutsideBodyLocal.replaceAll('iCloud', ''),
      };
      final banned = RegExp(r'drive|cloud|nube|nuage', caseSensitive: false);
      shown.forEach((k, v) {
        expect(v, isNotEmpty, reason: k);
        expect(banned.hasMatch(v), isFalse, reason: '$lang/$k: $v');
      });
    });
  }
}
