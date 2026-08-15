import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('the coin lays out through the frame in every band', (
    tester,
  ) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: CoinFlipScreen()),
        width: width,
        height: 700,
      );

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('quick mode bypasses the frame', (tester) async {
    await pumpAtWidth(
      tester,
      const ProviderScope(child: CoinFlipScreen(quickMode: true)),
      width: 400,
    );

    expect(find.byType(RitualScreenFrame), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the coin arena is centered in its pane when expanded',
    (tester) async {
      // FittedBox appears exactly once in CoinFlipScreen: it is the arena
      // built by _buildArena(), i.e. the frame's stage.
      await pumpAtWidth(
        tester,
        const ProviderScope(child: CoinFlipScreen()),
        width: 1400,
        height: 900,
      );

      final arena = tester.getRect(find.byType(FittedBox));

      // Expanded padding is fromLTRB(32, 28, 32, 24); the stage pane is the
      // frame's first kRitualStagePaneWidth (420) logical pixels.
      const paneContentLeft = 32.0;
      final expectedCenteredLeft =
          paneContentLeft + (kRitualStagePaneWidth - arena.width) / 2;

      expect(
        arena.left,
        closeTo(expectedCenteredLeft, 0.5),
        reason:
            'the coin arena must be centered in the expanded stage pane; a '
            'frame that put it flush left in expanded would put it at '
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
