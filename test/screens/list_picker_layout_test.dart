import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/list_picker_screen.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('lists lay out through the frame in every band', (tester) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: ListPickerScreen()),
        width: width,
        height: 700,
      );

      expect(
        find.byType(RitualScreenFrame),
        findsOneWidget,
        reason: 'width $width',
      );
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('toggling the mode keeps the wide skeleton', (tester) async {
    await pumpAtWidth(
      tester,
      const ProviderScope(child: ListPickerScreen()),
      width: 1400,
      height: 700,
    );

    // A fixed-width `kRitualStagePaneWidth` (420) SizedBox is the frame's
    // own marker for the two-pane arrangement (`_twoPane()`); it is absent
    // from the single-column `_readingColumn()` arrangement the frame falls
    // back to when `stage` is null. Asserting this survives the toggle (not
    // just the outer frame rect, which a bounded Scaffold body keeps stable
    // either way) is what actually distinguishes "the skeleton held" from
    // "classic mode silently lost its stage pane".
    bool hasStagePane() => find
        .byWidgetPredicate(
          (widget) =>
              widget is SizedBox && widget.width == kRitualStagePaneWidth,
        )
        .evaluate()
        .isNotEmpty;

    final frameBefore = tester.getRect(find.byType(RitualScreenFrame));
    expect(hasStagePane(), isTrue, reason: 'classic mode must keep the pane');

    await tester.tap(find.text('Wheel'));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byType(RitualScreenFrame)),
      frameBefore,
      reason:
          'switching modes must not resize the page, or it reads as having '
          'navigated somewhere else',
    );
    expect(hasStagePane(), isTrue, reason: 'wheel mode must keep the pane');
    expect(tester.takeException(), isNull);

    // Toggle back to classic with items still present: the stage swaps its
    // *content* (wheel -> reveal placeholder) but the skeleton's own size
    // must stay put in both directions, not just wheel-ward.
    final frameWheel = tester.getRect(find.byType(RitualScreenFrame));
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(RitualScreenFrame)), frameWheel);
    expect(
      hasStagePane(),
      isTrue,
      reason: 'classic mode must keep the pane after toggling back',
    );
  });

  testWidgets('expanded classic mode fills the stage pane with the reveal, not a '
      'second copy of the item list', (tester) async {
    final container = ProviderContainer(
      overrides: [
        randomOrgServiceProvider.overrideWithValue(
          RandomOrgService(
            client: MockClient((_) async => http.Response('1', 200)),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Skip the roulette-scan animation so the pick resolves deterministically
    // under pumpAndSettle, matching test/screens/list_picker_history_wiring_test.dart.
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );

    await pumpAtWidth(
      tester,
      UncontrolledProviderScope(
        container: container,
        child: const ListPickerScreen(),
      ),
      width: 1400,
      height: 900,
    );

    await tester.enterText(find.byType(TextField), 'Pizza');
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sushi');
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();

    // Before a pick, items exist but nothing is drawn yet: the stage pane
    // must not show the "add options" placeholder (that would be a lie —
    // there already are enough options) nor a second copy of the item
    // list that already lives in the body pane.
    expect(find.text('Add at least two options to begin.'), findsNothing);
    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Sushi'), findsOneWidget);

    await tester.tap(find.text('Let the universe choose'));
    await tester.pumpAndSettle();

    // Exactly one reveal banner: it lives in the stage pane and must not
    // also be duplicated into the body pane. (_SelectedBanner renders the
    // label in uppercase; the label text is unique to the banner, unlike
    // the winning item's own name, which legitimately appears a second
    // time in its still-visible body-pane row.)
    expect(find.text('CHOSEN BY THE UNIVERSE'), findsOneWidget);
    // Both item rows stay visible in the body pane alongside the reveal.
    expect(find.text('Pizza'), findsAtLeastNWidgets(1));
    expect(find.text('Sushi'), findsAtLeastNWidgets(1));
  });

  testWidgets(
    'classic mode with items added but nothing picked yet shows no reveal '
    'placeholder, matching the pre-refactor screen',
    (tester) async {
      // A wrong implementation that keys the stage purely off
      // `selectedIndex == null` (as an under-specified reading of the task
      // would) shows the empty-state placeholder here even though items
      // exist — which never happened before this refactor.
      await pumpAtWidth(
        tester,
        const ProviderScope(child: ListPickerScreen()),
        width: 400,
        height: 900,
      );

      await tester.enterText(find.byType(TextField), 'Pizza');
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sushi');
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Sushi'), findsOneWidget);
      expect(
        find.text('Add at least two options to begin.'),
        findsNothing,
        reason: 'items already exist, so the empty-state copy must not show',
      );
    },
  );
}
