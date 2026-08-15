import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/dice/dice_web_view.dart';
import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/dice_roll_screen.dart';

import '../support/fake_webview_platform.dart';
import '../support/layout_harness.dart';

void main() {
  setUpAll(FakeWebViewPlatform.register);

  testWidgets('the dice lay out through the frame in every band', (
    tester,
  ) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: DiceRollScreen()),
        width: width,
        height: 700,
      );

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('the dice surface keeps one stable size across bands', (
    tester,
  ) async {
    final sizes = <double>[];

    for (final width in const [400.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: DiceRollScreen()),
        width: width,
        height: 700,
      );

      sizes.add(tester.getSize(find.byType(DiceWebView)).height);
    }

    expect(
      sizes.first,
      sizes.last,
      reason:
          'the dice iframe must not be resized by the band; the physics bridge '
          'breaks when the surface changes size mid-animation',
    );
  });
}
