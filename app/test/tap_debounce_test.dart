import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/ui/child/category_widgets.dart';
import 'package:mirabo/ui/design/widgets.dart';

void main() {
  Future<void> doubleTap(WidgetTester t, Finder f) async {
    await t.tap(f);
    await t.pump(const Duration(milliseconds: 50));
    await t.tap(f);
    await t.pump(const Duration(milliseconds: 50));
  }

  Widget host(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

  testWidgets('ChunkyButton: doppio tocco = una chiamata', (t) async {
    var n = 0;
    await t.pumpWidget(host(ChunkyButton(label: 'Vai', onPressed: () => n++)));
    await doubleTap(t, find.byType(ChunkyButton));
    expect(n, 1);
  });

  testWidgets('RoundIconButton: doppio tocco = una chiamata', (t) async {
    var n = 0;
    await t.pumpWidget(host(RoundIconButton(icon: Icons.close, tooltip: 'x', onPressed: () => n++)));
    await doubleTap(t, find.byType(RoundIconButton));
    expect(n, 1);
  });

  testWidgets('BigCard: doppio tocco = una chiamata', (t) async {
    var n = 0;
    await t.pumpWidget(host(BigCard(title: 'Natura', color: Colors.green, icon: Icons.eco, onTap: () => n++)));
    await doubleTap(t, find.byType(BigCard));
    expect(n, 1);
  });

  testWidgets('push doppio non avviene', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (c) => ChunkyButton(
          label: 'Apri',
          onPressed: () => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const Scaffold(body: Text('B')))),
        ),
      ),
    ));
    await doubleTap(t, find.byType(ChunkyButton));
    await t.pumpAndSettle();
    final nav = t.state<NavigatorState>(find.byType(Navigator));
    nav.pop();
    await t.pumpAndSettle();
    expect(nav.canPop(), isFalse);
  });
}
