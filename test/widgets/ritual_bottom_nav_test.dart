import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/widgets/ritual_bottom_nav.dart';

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
          bottomNavigationBar: RitualBottomNav(
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
          bottomNavigationBar: RitualBottomNav(
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
}
