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
