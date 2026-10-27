import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/adult_pin.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/ui/parent/adult_gate.dart';

/// Il codice di recupero è salvato prima di mostrarlo: il tasto Indietro non deve chiuderlo.
void main() {
  testWidgets('con il codice di recupero in vista, Indietro non chiude il dialog', (tester) async {
    AdultGate.pin = AdultPin(store: MemoryPinStore(), iterations: 10, derive: AdultPin.syncKdf);
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: [for (final l in AppLanguage.values) l.locale],
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold();
      }),
    ));
    bool? result;
    AdultGate.confirm(ctx).then((v) => result = v);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '4821');
    await tester.enterText(fields.at(1), '4821');
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextField), findsNothing); // fase showCode

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(result, isNull);

    await tester.tap(find.byType(FilledButton).last); // "L'ho scritto"
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(result, isTrue);
  });
}
