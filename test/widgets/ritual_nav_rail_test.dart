import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/widgets/ritual_bottom_nav.dart';
import 'package:theuniversedecides/widgets/ritual_nav_rail.dart';

const _items = <RitualNavItem>[
  (id: 'coin', label: 'Coin'),
  (id: 'dice', label: 'Dice'),
  (id: 'cards', label: 'Cards'),
  (id: 'lists', label: 'Lists'),
  (id: 'tarot', label: 'Tarot'),
  (id: 'about', label: 'About'),
];

void main() {
  testWidgets('renders one entry per item and reports taps by index', (
    tester,
  ) async {
    final tapped = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RitualNavRail(
            items: _items,
            selectedIndex: 0,
            onSelected: tapped.add,
          ),
        ),
      ),
    );

    expect(find.text('Tarot'), findsOneWidget);
    await tester.tap(find.text('Tarot'));
    expect(tapped, [4]);
  });

  testWidgets('reports a long press by index, so Entropy Drift still opens', (
    tester,
  ) async {
    final pressed = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RitualNavRail(
            items: _items,
            selectedIndex: 0,
            onSelected: (_) {},
            onLongPress: pressed.add,
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Coin'));
    expect(pressed, [0]);
  });

  testWidgets('occupies the documented rail width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              RitualNavRail(
                items: _items,
                selectedIndex: 0,
                onSelected: (_) {},
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(RitualNavRail)).width,
      kRitualNavRailWidth,
    );
  });
}
