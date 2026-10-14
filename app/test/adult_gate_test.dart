import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/adult_pin.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/ui/parent/adult_gate.dart';

void main() {
  late MemoryPinStore store;
  var opened = 0;

  Widget app() => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => AdultGate.open(context, then: () => opened++),
            child: const Text('apri'),
          ),
        ),
      );

  setUp(() {
    store = MemoryPinStore();
    opened = 0;
    AdultGate.pin = AdultPin(store: store, iterations: 10);
    AdultGate.deviceAuth = (_) async => false;
    TestWidgetsFlutterBinding.ensureInitialized();
    TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue = const Locale('it');
    addTearDown(TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocaleTestValue);
  });

  testWidgets('primo ingresso: crea il PIN, poi lo chiede', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), '1234');
    await tester.enterText(fields.at(1), '1234');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(store.data.values.any((v) => v == '1234'), isFalse);

    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '9999');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.text('PIN sbagliato'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(opened, 2);
  });

  testWidgets('PIN dimenticato senza autenticazione del dispositivo: nessun reset', (tester) async {
    await AdultGate.pin.set('1234');
    await tester.pumpWidget(app());
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ho dimenticato il PIN'));
    await tester.pumpAndSettle();
    expect(await AdultGate.pin.isSet, isTrue);
    expect(find.textContaining('Non riesco a verificare'), findsOneWidget);
  });

  testWidgets('PIN dimenticato con autenticazione del dispositivo: se ne sceglie uno nuovo', (tester) async {
    await AdultGate.pin.set('1234');
    AdultGate.deviceAuth = (_) async => true;
    await tester.pumpWidget(app());
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ho dimenticato il PIN'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).at(0), '5678');
    await tester.enterText(find.byType(TextField).at(1), '5678');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(await AdultGate.pin.verify('5678'), PinResult.ok);
  });
}
