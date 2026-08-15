import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/about_me_screen.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('about lays out through the frame in every band', (tester) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: AboutMeScreen()),
        width: width,
        height: 700,
      );
      await tester.pump();

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('about never widens past a readable measure', (tester) async {
    await pumpAtWidth(
      tester,
      const ProviderScope(child: AboutMeScreen()),
      width: 1400,
      height: 700,
    );
    await tester.pump();

    final title = find.text('About me').first;
    expect(
      tester.getRect(title).left,
      greaterThan(kRitualReadingMaxWidth / 4),
      reason: 'a stageless page must stay centred, not hug the left edge',
    );
  });
}
