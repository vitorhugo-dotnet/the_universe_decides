import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_breakpoint.dart';

import '../support/layout_harness.dart';

void main() {
  test('width maps to the documented band, boundaries included', () {
    expect(ritualBandForWidth(0), RitualBand.compact);
    expect(ritualBandForWidth(599.99), RitualBand.compact);
    expect(ritualBandForWidth(600), RitualBand.medium);
    expect(ritualBandForWidth(1023.99), RitualBand.medium);
    expect(ritualBandForWidth(1024), RitualBand.expanded);
    expect(ritualBandForWidth(2560), RitualBand.expanded);
  });

  test('band convenience getters agree with the enum', () {
    expect(RitualBand.compact.isCompact, isTrue);
    expect(RitualBand.compact.isExpanded, isFalse);
    expect(RitualBand.medium.isMedium, isTrue);
    expect(RitualBand.expanded.isExpanded, isTrue);
  });

  testWidgets('ritualBandOf reads the window width', (tester) async {
    late RitualBand seen;

    for (final entry in {
      400.0: RitualBand.compact,
      800.0: RitualBand.medium,
      1400.0: RitualBand.expanded,
    }.entries) {
      await pumpAtWidth(
        tester,
        Builder(
          builder: (context) {
            seen = ritualBandOf(context);
            return const SizedBox();
          },
        ),
        width: entry.key,
      );

      expect(seen, entry.value, reason: 'width ${entry.key}');
    }
  });
}
