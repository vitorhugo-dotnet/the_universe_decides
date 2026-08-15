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
