import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';

import '../support/layout_harness.dart';

const _header = Text('HEADER');
const _body = Text('BODY');
const _stage = SizedBox(key: ValueKey('stage'), width: 100, height: 100);

void main() {
  testWidgets('every slot renders in every band', (tester) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(header: _header, body: _body, stage: _stage),
        width: width,
      );

      expect(find.text('HEADER'), findsOneWidget, reason: 'width $width');
      expect(find.text('BODY'), findsOneWidget, reason: 'width $width');
      expect(find.byKey(const ValueKey('stage')), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('compact stacks the stage above the body', (tester) async {
    await pumpAtWidth(
      tester,
      const RitualScreenFrame(header: _header, body: _body, stage: _stage),
      width: 400,
    );

    final stage = tester.getRect(find.byKey(const ValueKey('stage')));
    final body = tester.getRect(find.text('BODY'));
    expect(stage.bottom, lessThanOrEqualTo(body.top));
  });

  testWidgets('expanded puts the stage left of the body', (tester) async {
    await pumpAtWidth(
      tester,
      const RitualScreenFrame(header: _header, body: _body, stage: _stage),
      width: 1400,
    );

    final stage = tester.getRect(find.byKey(const ValueKey('stage')));
    final body = tester.getRect(find.text('BODY'));
    expect(stage.right, lessThanOrEqualTo(body.left));
  });

  testWidgets('a frame with no stage stays a single column when expanded', (
    tester,
  ) async {
    await pumpAtWidth(
      tester,
      const RitualScreenFrame(header: _header, body: _body),
      width: 1400,
    );

    final header = tester.getRect(find.text('HEADER'));
    final body = tester.getRect(find.text('BODY'));
    expect(header.bottom, lessThanOrEqualTo(body.top),
        reason: 'a stageless screen must not be forced into two panes');
    expect(body.width, lessThanOrEqualTo(kRitualReadingMaxWidth));
  });

  testWidgets('medium caps the column at the documented width', (tester) async {
    await pumpAtWidth(
      tester,
      const RitualScreenFrame(
        header: _header,
        // Infinite width, so the column's cap is what bounds the probe. A
        // probe with no width would measure 0 and pass against any cap.
        body: SizedBox(key: ValueKey('wide'), width: double.infinity, height: 20),
      ),
      width: 900,
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('wide'))).width,
      lessThanOrEqualTo(kRitualMediumMaxWidth),
    );
  });

  testWidgets(
    'compact scrolls the padding with the content instead of fixing it '
    'outside the viewport',
    (tester) async {
      // A distinctive value (not the default) so a false pass can't be
      // explained by some other, unrelated padding happening to match.
      const padding = EdgeInsets.fromLTRB(11, 13, 17, 19);
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(
          header: _header,
          body: _body,
          compactPadding: padding,
        ),
        width: 400,
      );

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(
        scrollView.padding,
        padding,
        reason:
            'compactPadding must be passed to SingleChildChildScrollView so '
            'it scrolls away with the content, exactly like the pre-plan '
            '`SingleChildScrollView(padding: ...)`. An enclosing Padding '
            'around the scroll view instead leaves scrollView.padding null '
            'and fixes the inset outside the viewport as chrome.',
      );
    },
  );

  testWidgets(
    'a stageless frame still gets a gap between header and body in the '
    'stacked (compact/medium) arrangement, matching _readingColumn',
    (tester) async {
      for (final width in const [400.0, 800.0]) {
        await pumpAtWidth(
          tester,
          const RitualScreenFrame(header: _header, body: _body),
          width: width,
        );

        final header = tester.getRect(find.text('HEADER'));
        final body = tester.getRect(find.text('BODY'));

        expect(
          body.top - header.bottom,
          20.0,
          reason:
              'a stageless _stacked() must supply the same 20px gap that '
              '_readingColumn() already supplies between header and body; a '
              'frame that renders them with no gap in between (the bug this '
              'test exists to catch) would report 0.0 here at width $width',
        );
      }
    },
  );

  testWidgets(
    'medium scrolls the padding with the content, matching compact',
    (tester) async {
      const padding = EdgeInsets.fromLTRB(11, 13, 17, 19);
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(
          header: _header,
          body: _body,
          compactPadding: padding,
        ),
        width: 800,
      );

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(
        scrollView.padding,
        padding,
        reason: 'medium must give the scrolling path the same '
            'inside-vs-outside padding treatment as compact',
      );
    },
  );

  testWidgets(
    'compact keeps the flexing stage (the coin) unscrolled with its '
    'padding enclosing the whole arrangement',
    (tester) async {
      const padding = EdgeInsets.fromLTRB(11, 13, 17, 19);
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(
          header: _header,
          body: _body,
          stage: _stage,
          stageFlexes: true,
          compactPadding: padding,
        ),
        width: 400,
      );

      // The flexing path never scrolls, so there is nothing to fix here:
      // the compactPadding must still enclose the arrangement as a Padding.
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Padding && widget.padding == padding,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'stageSpacing controls the gap around the stage in compact',
    (tester) async {
      for (final spacing in const [24.0, 11.0]) {
        await pumpAtWidth(
          tester,
          RitualScreenFrame(
            header: _header,
            body: _body,
            stage: _stage,
            stageSpacing: spacing,
          ),
          width: 400,
        );

        final header = tester.getRect(find.text('HEADER'));
        final stage = tester.getRect(find.byKey(const ValueKey('stage')));
        final body = tester.getRect(find.text('BODY'));

        expect(
          stage.top - header.bottom,
          spacing,
          reason: 'the gap above the stage must equal stageSpacing '
              '($spacing), not a hardcoded value',
        );
        expect(
          body.top - stage.bottom,
          spacing,
          reason: 'the gap below the stage must equal stageSpacing '
              '($spacing), not a hardcoded value',
        );
      }
    },
  );

  testWidgets(
    'stageSpacingAfter overrides the gap below the stage independently of '
    'stageSpacing above it',
    (tester) async {
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(
          header: _header,
          body: _body,
          stage: _stage,
          stageSpacing: 22,
          stageSpacingAfter: 0,
        ),
        width: 400,
      );

      final header = tester.getRect(find.text('HEADER'));
      final stage = tester.getRect(find.byKey(const ValueKey('stage')));
      final body = tester.getRect(find.text('BODY'));

      expect(
        stage.top - header.bottom,
        22.0,
        reason: 'the gap above the stage must still use stageSpacing',
      );
      expect(
        body.top - stage.bottom,
        0.0,
        reason: 'stageSpacingAfter must override the gap below the stage; '
            'a frame that ignores it and falls back to stageSpacing would '
            'leave a 22px gap here instead of 0',
      );
    },
  );

  testWidgets(
    'omitting stageSpacingAfter keeps the gap below the stage equal to '
    'stageSpacing, matching every existing call site',
    (tester) async {
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(
          header: _header,
          body: _body,
          stage: _stage,
          stageSpacing: 11,
        ),
        width: 400,
      );

      final stage = tester.getRect(find.byKey(const ValueKey('stage')));
      final body = tester.getRect(find.text('BODY'));

      expect(body.top - stage.bottom, 11.0);
    },
  );

  testWidgets(
    'stageAlignment controls where the stage sits in the stacked (compact) '
    'arrangement',
    (tester) async {
      // Content width in compact at 400px = 400 - 22 - 22 (default
      // compactPadding) = 356. _stage is 100 wide, so centered vs
      // centerLeft land at visibly different x positions.
      const contentWidth = 400.0 - 22 - 22;
      const stageWidth = 100.0;

      await pumpAtWidth(
        tester,
        const RitualScreenFrame(
          header: _header,
          body: _body,
          stage: _stage,
          stageAlignment: Alignment.centerLeft,
        ),
        width: 400,
      );
      final centerLeftStage = tester.getRect(
        find.byKey(const ValueKey('stage')),
      );

      expect(
        centerLeftStage.left,
        22.0,
        reason: 'Alignment.centerLeft must put the stage flush against the '
            "column's start edge (just past compactPadding.left), not "
            'centered — a frame that ignores stageAlignment and always '
            'centers would put it at ${22 + (contentWidth - stageWidth) / 2} '
            'instead',
      );
    },
  );

  testWidgets(
    'omitting stageAlignment keeps the stage centered, matching every '
    'existing call site',
    (tester) async {
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(header: _header, body: _body, stage: _stage),
        width: 400,
      );

      const contentWidth = 400.0 - 22 - 22;
      const stageWidth = 100.0;
      final stage = tester.getRect(find.byKey(const ValueKey('stage')));

      expect(stage.left, 22.0 + (contentWidth - stageWidth) / 2);
    },
  );

  testWidgets(
    'the expanded two-pane band always centers the stage in its pane, '
    'regardless of stageAlignment',
    (tester) async {
      // Expanded padding is fromLTRB(32, 28, 32, 24); the stage pane is
      // kRitualStagePaneWidth (420) wide. _stage is 100 wide, so a centered
      // arena and a flush-left arena land at visibly different x positions.
      const paneLeft = 32.0;
      const expectedCenteredLeft =
          paneLeft + (kRitualStagePaneWidth - 100) / 2;

      for (final alignment in const [
        Alignment.center,
        Alignment.centerLeft,
      ]) {
        await pumpAtWidth(
          tester,
          RitualScreenFrame(
            header: _header,
            body: _body,
            stage: _stage,
            stageAlignment: alignment,
          ),
          width: 1400,
        );

        final stage = tester.getRect(find.byKey(const ValueKey('stage')));
        expect(
          stage.left,
          expectedCenteredLeft,
          reason: '_twoPane must center the stage in its fixed-width pane '
              'no matter what stageAlignment ($alignment) says; only the '
              'stacked (compact/medium) arrangement should ever honour it',
        );
      }
    },
  );

  testWidgets('no band overflows', (tester) async {
    for (final width in const [400.0, 600.0, 1023.0, 1024.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(
          header: _header,
          body: _body,
          stage: _stage,
          stageFlexes: true,
        ),
        width: width,
        height: 640,
      );

      expect(tester.takeException(), isNull, reason: 'width $width overflowed');
    }
  });
}
