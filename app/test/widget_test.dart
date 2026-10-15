import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/adult_pin.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/ui/parent/adult_gate.dart';

/// Sostituisce il widget_test generato da `flutter create` (la CI lo rigenera se
/// manca): verifica il gate adulti, che è la barriera tra bambino e impostazioni.
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

  Future<void> createPin(WidgetTester tester, String pin) async {
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), pin);
    await tester.enterText(fields.at(1), pin);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets('primo ingresso: crea il PIN, mostra il codice di recupero una volta, poi chiede il PIN', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    await createPin(tester, '1234');
    // Il codice di recupero si vede una volta sola, prima di entrare.
    expect(opened, 0);
    final code = tester.widget<SelectableText>(find.byKey(const Key('recovery-shown'))).data!;
    expect(code, matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}$')));
    await tester.tap(find.text("L'ho scritto"));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(store.data.values.any((v) => v == '1234' || v.contains(code.replaceAll('-', ''))), isFalse);

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

  testWidgets('PIN dimenticato: il codice di recupero vale una volta e lascia un avviso', (tester) async {
    await AdultGate.pin.set('1234');
    final code = await AdultGate.pin.newRecoveryCode();
    await tester.pumpWidget(app());
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ho dimenticato il PIN'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('recovery-code')), 'XXXX-XXXX');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Codice sbagliato'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('recovery-code')), code.toLowerCase());
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await createPin(tester, '5678');
    // Il codice usato non vale più: se ne mostra uno nuovo.
    expect(find.byKey(const Key('recovery-shown')), findsOneWidget);
    await tester.tap(find.text("L'ho scritto"));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(await AdultGate.pin.verify('5678'), PinResult.ok);
    expect((await AdultGate.pin.resetNotice())?.how, RecoveryChannel.code);
  });

  testWidgets('PIN dimenticato senza autenticazione del dispositivo: nessun reset', (tester) async {
    await AdultGate.pin.set('1234');
    await tester.pumpWidget(app());
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ho dimenticato il PIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usa il blocco del tablet'));
    await tester.pumpAndSettle();
    expect(await AdultGate.pin.isSet, isTrue);
    expect(find.textContaining('Non riesco a verificare'), findsOneWidget);
  });

  testWidgets('PIN dimenticato con autenticazione del dispositivo: se ne sceglie uno nuovo', (tester) async {
    await AdultGate.pin.set('1234');
    await AdultGate.pin.newRecoveryCode();
    AdultGate.deviceAuth = (_) async => true;
    await tester.pumpWidget(app());
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ho dimenticato il PIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usa il blocco del tablet'));
    await tester.pumpAndSettle();
    await createPin(tester, '5678');
    // Il codice di recupero c'era già e vale ancora: si entra subito.
    expect(opened, 1);
    expect(await AdultGate.pin.verify('5678'), PinResult.ok);
    expect((await AdultGate.pin.resetNotice())?.how, RecoveryChannel.device);
  });

  testWidgets('il bambino conosce il codice del tablet: con il recupero spento serve il codice di recupero', (tester) async {
    await AdultGate.pin.set('1234');
    await AdultGate.pin.setDeviceRecovery(false);
    var asked = false;
    AdultGate.deviceAuth = (_) async => asked = true;
    await tester.pumpWidget(app());
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ho dimenticato il PIN'));
    await tester.pumpAndSettle();
    expect(find.text('Usa il blocco del tablet'), findsNothing);
    expect(find.textContaining('serve il codice di recupero'), findsOneWidget);
    expect(asked, isFalse);
    expect(await AdultGate.pin.isSet, isTrue);
  });
}
