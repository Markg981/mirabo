import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/shelf.dart';
import 'package:mirabo/ui/child/category_widgets.dart';

Widget _dock(List<Capacity> cats, List<Capacity> taps, {Capacity? selected}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
      home: Scaffold(body: CategoryDock(categories: cats, selected: selected, onSelect: taps.add)),
    );

void main() {
  testWidgets('ogni categoria ha il nome scritto sotto e il tocco la apre', (tester) async {
    final taps = <Capacity>[];
    await tester.pumpWidget(_dock([Capacity.insieme, Capacity.mani], taps));
    expect(find.text('Io e gli altri'), findsOneWidget);
    expect(find.text('Le mani'), findsOneWidget);
    await tester.tap(find.text('Le mani'));
    expect(taps, [Capacity.mani]);
  });

  testWidgets('la posizione dei bottoni non dipende dalla scelta', (tester) async {
    final cats = [Capacity.insieme, Capacity.mani, Capacity.sensi];
    await tester.pumpWidget(_dock(cats, []));
    final before = tester.getCenter(find.text('Le mani'));
    await tester.pumpWidget(_dock(cats, [], selected: Capacity.mani));
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.text('Le mani')).dx, before.dx);
  });
}
