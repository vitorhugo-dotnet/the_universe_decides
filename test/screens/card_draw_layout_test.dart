import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/card_draw_screen.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('the card lays out through the frame in every band', (
    tester,
  ) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: CardDrawScreen()),
        width: width,
        height: 700,
      );

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets(
    'the card is centered in its pane when expanded',
    (tester) async {
      // AnimatedSwitcher appears exactly once in CardDrawScreen: it wraps
      // the flipping card, i.e. the frame's stage.
      await pumpAtWidth(
        tester,
        const ProviderScope(child: CardDrawScreen()),
        width: 1400,
        height: 900,
      );

      final card = tester.getRect(find.byType(AnimatedSwitcher));

      // Expanded padding is fromLTRB(32, 28, 32, 24); the stage pane is the
      // frame's first kRitualStagePaneWidth (420) logical pixels.
      const paneContentLeft = 32.0;
      final expectedCenteredLeft =
          paneContentLeft + (kRitualStagePaneWidth - card.width) / 2;

      expect(
        card.left,
        closeTo(expectedCenteredLeft, 0.5),
        reason:
            'the card must be centered in the expanded stage pane; a frame '
            'that put it flush left in expanded would put it at '
            'x=$paneContentLeft instead',
      );
      expect(
        card.left,
        greaterThan(paneContentLeft),
        reason: 'sanity check: the card must not be flush against the '
            "pane's left edge in expanded",
      );
    },
  );
}
