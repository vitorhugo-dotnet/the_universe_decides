import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/widgets/ritual_nav_rail.dart';

void main() {
  testWidgets('normal taps report every navigation item', (tester) async {
    final selected = <int>[];
    final items = List.generate(
      6,
      (index) => (id: 'item-$index', label: 'Item $index'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RitualNavRail(
            items: items,
            selectedIndex: 0,
            onSelected: selected.add,
          ),
        ),
      ),
    );

    for (var index = 0; index < items.length; index++) {
      await tester.tap(find.text('Item $index'));
    }

    expect(selected, [0, 1, 2, 3, 4, 5]);
  });

  testWidgets('long press reports every navigation item exactly once', (
    tester,
  ) async {
    final pressed = <int>[];
    final items = List.generate(
      6,
      (index) => (id: 'item-$index', label: 'Item $index'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RitualNavRail(
            items: items,
            selectedIndex: 0,
            onSelected: (_) {},
            onLongPress: pressed.add,
          ),
        ),
      ),
    );

    for (var index = 0; index < items.length; index++) {
      await tester.longPress(find.text('Item $index'));
    }

    expect(pressed, [0, 1, 2, 3, 4, 5]);
  });

  testWidgets('occupies the documented rail width', (tester) async {
    final items = List.generate(
      6,
      (index) => (id: 'item-$index', label: 'Item $index'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              RitualNavRail(
                items: items,
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
