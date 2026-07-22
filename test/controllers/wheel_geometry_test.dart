import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/controllers/wheel_geometry.dart';

void main() {
  group('wheelSegmentAngle', () {
    test('splits the full circle evenly', () {
      expect(wheelSegmentAngle(4), closeTo(math.pi / 2, 1e-9));
      expect(wheelSegmentAngle(1), closeTo(2 * math.pi, 1e-9));
    });

    test('returns 0 for a non-positive count', () {
      expect(wheelSegmentAngle(0), 0);
      expect(wheelSegmentAngle(-3), 0);
    });
  });

  group('normalizeAngle', () {
    test('wraps positive angles above 2π', () {
      expect(normalizeAngle(2 * math.pi + 1), closeTo(1, 1e-9));
    });

    test('wraps negative angles into range', () {
      expect(normalizeAngle(-math.pi / 2), closeTo(3 * math.pi / 2, 1e-9));
    });

    test('leaves an in-range angle untouched', () {
      expect(normalizeAngle(1.2), closeTo(1.2, 1e-9));
    });
  });

  group('wheel drag geometry', () {
    test('calculates pointer angles around the wheel center', () {
      expect(
        wheelPointerPositionAngle(
          position: const math.Point(10, 0),
          center: const math.Point(0, 0),
        ),
        closeTo(0, 1e-9),
      );
      expect(
        wheelPointerPositionAngle(
          position: const math.Point(0, 10),
          center: const math.Point(0, 0),
        ),
        closeTo(math.pi / 2, 1e-9),
      );
    });

    test('keeps angular deltas continuous across the -pi/pi boundary', () {
      expect(
        shortestAngularDelta(math.pi - 0.1, -math.pi + 0.1),
        closeTo(0.2, 1e-9),
      );
      expect(
        shortestAngularDelta(-math.pi + 0.1, math.pi - 0.1),
        closeTo(-0.2, 1e-9),
      );
    });

    test('converts tangential release velocity to angular velocity', () {
      expect(
        wheelAngularVelocity(
          positionFromCenter: const math.Point(100, 0),
          pixelsPerSecond: const math.Point(0, 500),
        ),
        closeTo(5, 1e-9),
      );
      expect(
        wheelAngularVelocity(
          positionFromCenter: const math.Point(100, 0),
          pixelsPerSecond: const math.Point(0, -500),
        ),
        closeTo(-5, 1e-9),
      );
    });
  });

  group('computeWheelFlickProfile', () {
    test('rejects a release that is too slow', () {
      expect(computeWheelFlickProfile(angularVelocity: 0.4), isNull);
    });

    test('preserves direction and scales visual momentum', () {
      final slow = computeWheelFlickProfile(angularVelocity: 2)!;
      final fast = computeWheelFlickProfile(angularVelocity: -12)!;

      expect(slow.direction, 1);
      expect(fast.direction, -1);
      expect(fast.extraSpins, greaterThan(slow.extraSpins));
      expect(fast.duration, greaterThan(slow.duration));
    });

    test('caps extreme flicks to bounded animation values', () {
      final profile = computeWheelFlickProfile(angularVelocity: 1000)!;

      expect(profile.extraSpins, lessThanOrEqualTo(wheelMaxFlickSpins));
      expect(profile.duration, lessThanOrEqualTo(wheelMaxFlickDuration));
    });
  });

  group('computeWheelTargetRotation', () {
    test('lands exactly on the pointer for the winning segment center', () {
      const itemCount = 5;
      for (var winner = 0; winner < itemCount; winner++) {
        final rotation = computeWheelTargetRotation(
          winnerIndex: winner,
          itemCount: itemCount,
          currentRotation: 0,
        );

        final segment = wheelSegmentAngle(itemCount);
        final segmentCenter = segment * winner + segment / 2;
        final landedAngle = normalizeAngle(segmentCenter + rotation);

        expect(landedAngle, closeTo(wheelPointerAngle, 1e-6));
      }
    });

    test('always spins forward from the current rotation', () {
      // currentRotation already sits very close to the desired angle, which
      // would previously risk a ~0 or negative delta.
      final rotation = computeWheelTargetRotation(
        winnerIndex: 2,
        itemCount: 8,
        currentRotation: 40.0,
        extraSpins: 0,
      );

      expect(rotation, greaterThan(40.0));
    });

    test('adds the requested number of extra full revolutions', () {
      final withExtra = computeWheelTargetRotation(
        winnerIndex: 1,
        itemCount: 4,
        currentRotation: 0,
        extraSpins: 6,
      );
      final withoutExtra = computeWheelTargetRotation(
        winnerIndex: 1,
        itemCount: 4,
        currentRotation: 0,
        extraSpins: 0,
      );

      final turns = (withExtra - withoutExtra) / (2 * math.pi);
      expect(turns, closeTo(6, 1e-9));
    });

    test('is deterministic for the same inputs', () {
      final a = computeWheelTargetRotation(
        winnerIndex: 3,
        itemCount: 6,
        currentRotation: 12.3,
      );
      final b = computeWheelTargetRotation(
        winnerIndex: 3,
        itemCount: 6,
        currentRotation: 12.3,
      );
      expect(a, b);
    });

    test('lands on the winner while spinning counter-clockwise', () {
      const itemCount = 5;
      final rotation = computeWheelTargetRotation(
        winnerIndex: 3,
        itemCount: itemCount,
        currentRotation: 2.4,
        extraSpins: 3,
        direction: -1,
      );
      final segment = wheelSegmentAngle(itemCount);
      final segmentCenter = segment * 3 + segment / 2;

      expect(rotation, lessThan(2.4));
      expect(
        normalizeAngle(segmentCenter + rotation),
        closeTo(wheelPointerAngle, 1e-6),
      );
    });
  });

  group('isValidWheelSelection', () {
    test('rejects fewer than two items', () {
      expect(isValidWheelSelection([]), isFalse);
      expect(isValidWheelSelection(['solo']), isFalse);
    });

    test('rejects blank-only entries', () {
      expect(isValidWheelSelection(['a', '   ']), isFalse);
    });

    test('accepts two or more non-blank items', () {
      expect(isValidWheelSelection(['a', 'b']), isTrue);
      expect(isValidWheelSelection(['a', 'b', 'c']), isTrue);
    });
  });

  group('wheelLabelFontSize', () {
    test('shrinks as the item count grows', () {
      final six = wheelLabelFontSize(6);
      final ten = wheelLabelFontSize(10);
      final sixteen = wheelLabelFontSize(16);
      final thirty = wheelLabelFontSize(30);

      expect(six, greaterThanOrEqualTo(ten));
      expect(ten, greaterThanOrEqualTo(sixteen));
      expect(sixteen, greaterThanOrEqualTo(thirty));
      expect(thirty, greaterThanOrEqualTo(8));
    });
  });

  group('wheelShouldShowLabels', () {
    test('shows labels within the labeled-segment limit', () {
      expect(wheelShouldShowLabels(2), isTrue);
      expect(wheelShouldShowLabels(wheelMaxLabeledSegments), isTrue);
    });

    test('hides labels beyond the limit and for empty wheels', () {
      expect(wheelShouldShowLabels(wheelMaxLabeledSegments + 1), isFalse);
      expect(wheelShouldShowLabels(0), isFalse);
    });
  });
}
