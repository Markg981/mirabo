import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/theme.dart';
import 'package:mirabo/ui/parent/adult_gate.dart';

/// Sostituisce il widget_test generato da `flutter create`: verifica il gate
/// adulti, che è la barriera tra bambino e impostazioni.
void main() {
  testWidgets('il gate adulti chiede una moltiplicazione e rifiuta la risposta sbagliata', (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      theme: miraboTheme(dyslexiaFont: false, lowStimulation: false),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => AdultGate.open(context, then: () => opened = true),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    expect(find.textContaining('×'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1');
    await tester.tap(find.text('Entra'));
    await tester.pumpAndSettle();
    expect(find.text('Riprova'), findsOneWidget);
    expect(opened, isFalse);

    final question = tester.widget<Text>(find.textContaining('×')).data!;
    final m = RegExp(r'(\d+) × (\d+)').firstMatch(question)!;
    final answer = int.parse(m.group(1)!) * int.parse(m.group(2)!);
    await tester.enterText(find.byType(TextField), '$answer');
    await tester.tap(find.text('Entra'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
  });
}
