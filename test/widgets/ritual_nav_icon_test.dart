import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/widgets/ritual_nav_icon.dart';

void main() {
  testWidgets('every navigation id renders an icon in the given colour', (
    tester,
  ) async {
    for (final id in const ['coin', 'dice', 'cards', 'lists', 'tarot', 'about']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: RitualNavIcon(id: id, color: const Color(0xFFAABBCC))),
        ),
      );

      expect(
        find.byType(RitualNavIcon),
        findsOneWidget,
        reason: 'id $id must render',
      );
      expect(tester.takeException(), isNull, reason: 'id $id must not throw');
    }
  });

  testWidgets('an unknown id falls back instead of throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: RitualNavIcon(id: 'nope', color: Color(0xFFFFFFFF))),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
