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

  testWidgets(
    'the dice arena is centered in its pane when expanded, unlike its '
    'flush-left position in compact',
    (tester) async {
      // stageAlignment: centerLeft only applies to the stacked (compact /
      // medium) arrangement; _twoPane always centers the stage in its
      // fixed-width kRitualStagePaneWidth pane. This is the permanent guard
      // for the gap that let the flush-left compensation leak into expanded
      // silently: no golden or test covered the expanded band for dice
      // before this test existed.
      await pumpAtWidth(
        tester,
        const ProviderScope(child: DiceRollScreen()),
        width: 1400,
        height: 900,
      );

      final arena = tester.getRect(find.byType(DiceWebView));

      // Expanded padding is fromLTRB(32, 28, 32, 24); the stage pane is the
      // frame's first kRitualStagePaneWidth (420) logical pixels.
      const paneContentLeft = 32.0;
      final expectedCenteredLeft =
          paneContentLeft + (kRitualStagePaneWidth - arena.width) / 2;

      expect(
        arena.left,
        closeTo(expectedCenteredLeft, 0.5),
        reason:
            'the dice arena must be centered in the expanded stage pane, '
            'not flush left the way it is in compact; a frame that leaked '
            'stageAlignment: centerLeft into _twoPane would put it at '
            'x=$paneContentLeft instead',
      );
      expect(
        arena.left,
        greaterThan(paneContentLeft),
        reason: 'sanity check: the arena must not be flush against the '
            "pane's left edge in expanded",
      );
    },
  );
}
