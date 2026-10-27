import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/l10n/app_localizations.dart';
import 'package:mirabo/ui/parent/parent_area.dart';

/// L'adulto viene avvisato dei pacchetti di contenuti scartati dai controlli.
void main() {
  Future<void> pump(WidgetTester tester, int count, String lang) => tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(lang),
        home: Scaffold(body: RejectedPackagesNote(count: count)),
      ));

  testWidgets('con pacchetti rifiutati la segnalazione compare, con il conteggio', (tester) async {
    await pump(tester, 2, 'it');
    expect(find.byKey(const Key('rejected-packages')), findsOneWidget);
    expect(find.textContaining('2 pacchetti'), findsOneWidget);
  });

  testWidgets('con un solo pacchetto usa il singolare', (tester) async {
    await pump(tester, 1, 'it');
    expect(find.textContaining('1 pacchetto di contenuti'), findsOneWidget);
  });

  testWidgets('senza pacchetti rifiutati non mostra nulla', (tester) async {
    await pump(tester, 0, 'it');
    expect(find.byKey(const Key('rejected-packages')), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('la segnalazione esiste in tutte le lingue', (tester) async {
    for (final lang in ['it', 'en', 'es', 'fr', 'de']) {
      await pump(tester, 3, lang);
      expect(find.byKey(const Key('rejected-packages')), findsOneWidget, reason: lang);
    }
  });
}
