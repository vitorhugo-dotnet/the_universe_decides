import 'dart:math' as math;

/// Pure geometry/validation helpers for the List Draw "spinning wheel" mode.
///
/// The wheel itself never decides a winner — [computeWheelTargetRotation]
/// only maps a winner index that has *already* been produced by
/// [RandomOrgService] (same service/rule used by the classic List Draw mode)
/// onto a rotation angle for the animation to land on. Keeping this pure and
/// dependency-free makes it trivial to unit test without pumping widgets.

/// Canvas angle (radians) of the fixed pointer at the top of the wheel.
/// Flutter canvas angles increase clockwise from the 3 o'clock position, so
/// "up" is 3π/2 (equivalently -π/2 mod 2π).
const double wheelPointerAngle = 3 * math.pi / 2;

/// Default number of full extra revolutions added purely for visual flair.
const int wheelDefaultExtraSpins = 4;

/// Smallest release speed that counts as an intentional wheel flick.
const double wheelMinFlickVelocity = 0.8;

/// Upper bounds keep even extreme pointer velocities comfortable to watch.
const int wheelMaxFlickSpins = 7;
const Duration wheelMaxFlickDuration = Duration(milliseconds: 3800);

/// The painted disc radius and a central dead zone where angular motion is
/// too unstable to infer from a finger position.
const double wheelDialRadius = 120;
const double wheelDragDeadZoneRadius = 28;

/// Above this many items, individual segment labels become unreadable no
/// matter how small the font gets, so labels are hidden and the always
/// visible item list below the wheel remains the source of full text.
const int wheelMaxLabeledSegments = 24;

/// Angular width (radians) of a single segment for a wheel with [itemCount]
/// items. Returns 0 for a non-positive count.
double wheelSegmentAngle(int itemCount) {
  if (itemCount <= 0) return 0;
  return (2 * math.pi) / itemCount;
}

/// Normalizes [angle] into the range `[0, 2π)`.
double normalizeAngle(double angle) {
  const twoPi = 2 * math.pi;
  var normalized = angle % twoPi;
  if (normalized < 0) {
    normalized += twoPi;
  }
  return normalized;
}

/// Angle of [position] around [center], increasing clockwise in Flutter's
/// screen coordinate system.
double wheelPointerPositionAngle({
  required math.Point<num> position,
  required math.Point<num> center,
}) {
  return math.atan2(
    (position.y - center.y).toDouble(),
    (position.x - center.x).toDouble(),
  );
}

/// Smallest signed turn from [from] to [to], in the range `[-pi, pi]`.
double shortestAngularDelta(double from, double to) {
  var delta = normalizeAngle(to - from);
  if (delta > math.pi) {
    delta -= 2 * math.pi;
  }
  return delta;
}

/// Converts a linear release velocity into radians per second around the
/// wheel center using the 2D cross product `r × v / |r|²`.
double wheelAngularVelocity({
  required math.Point<num> positionFromCenter,
  required math.Point<num> pixelsPerSecond,
}) {
  final x = positionFromCenter.x.toDouble();
  final y = positionFromCenter.y.toDouble();
  final radiusSquared = x * x + y * y;
  if (radiusSquared == 0) return 0;

  final vx = pixelsPerSecond.x.toDouble();
  final vy = pixelsPerSecond.y.toDouble();
  return (x * vy - y * vx) / radiusSquared;
}

/// Whether a pointer sample is inside the visible wheel but far enough from
/// its axis for stable angular gesture calculations.
bool isWheelDragPositionValid({
  required math.Point<num> position,
  required math.Point<num> center,
  double outerRadius = wheelDialRadius,
  double innerRadius = wheelDragDeadZoneRadius,
}) {
  final dx = (position.x - center.x).toDouble();
  final dy = (position.y - center.y).toDouble();
  final distanceSquared = dx * dx + dy * dy;
  return distanceSquared <= outerRadius * outerRadius &&
      distanceSquared >= innerRadius * innerRadius;
}

class WheelFlickProfile {
  const WheelFlickProfile({
    required this.direction,
    required this.extraSpins,
    required this.duration,
  });

  final int direction;
  final int extraSpins;
  final Duration duration;
}

/// Maps release speed to bounded visual momentum. Returns `null` for a weak
/// release so accidental drags never trigger a draw.
WheelFlickProfile? computeWheelFlickProfile({
  required double angularVelocity,
}) {
  final speed = angularVelocity.abs();
  if (speed < wheelMinFlickVelocity) return null;

  final momentum = (speed / 12).clamp(0.0, 1.0);
  final extraSpins = 2 + (momentum * (wheelMaxFlickSpins - 2)).round();
  final durationMs = 2200 + (momentum * 1600).round();
  return WheelFlickProfile(
    direction: angularVelocity.isNegative ? -1 : 1,
    extraSpins: extraSpins,
    duration: Duration(milliseconds: durationMs),
  );
}

/// Computes the absolute rotation (radians, typically several full turns)
/// the wheel must animate to so [winnerIndex]'s segment center lands under
/// the fixed pointer ([wheelPointerAngle]).
///
/// Continues from [currentRotation] in the requested [direction] (`1` for
/// clockwise, `-1` for counter-clockwise) and layers on [extraSpins] full
/// revolutions so short hops still feel like a spin.
///
/// The winner is decided entirely by the caller (via the randomness
/// service) *before* this is invoked — this function is a one-way, visual
/// mapping only, it never influences which index "wins".
double computeWheelTargetRotation({
  required int winnerIndex,
  required int itemCount,
  required double currentRotation,
  int extraSpins = wheelDefaultExtraSpins,
  int direction = 1,
}) {
  assert(itemCount > 0, 'itemCount must be positive');
  assert(
    winnerIndex >= 0 && winnerIndex < itemCount,
    'winnerIndex out of range',
  );
  assert(direction == 1 || direction == -1, 'direction must be 1 or -1');

  final segment = wheelSegmentAngle(itemCount);
  final segmentCenter = segment * winnerIndex + segment / 2;
  final desiredMod = normalizeAngle(wheelPointerAngle - segmentCenter);
  final currentMod = normalizeAngle(currentRotation);

  var delta = desiredMod - currentMod;
  if (direction > 0) {
    if (delta <= 0) delta += 2 * math.pi;
  } else {
    if (delta >= 0) delta -= 2 * math.pi;
  }

  return currentRotation + delta + direction * extraSpins * 2 * math.pi;
}

/// True when [items] has at least two non-blank entries — the minimum
/// needed to spin the wheel (mirrors the classic mode's own minimum).
bool isValidWheelSelection(List<String> items) {
  return items.length >= 2 && items.every((item) => item.trim().isNotEmpty);
}

/// Legible font size (logical pixels) for a wheel segment label, scaling
/// down as the item count grows so labels don't overflow their slice.
double wheelLabelFontSize(int itemCount) {
  if (itemCount <= 6) return 14;
  if (itemCount <= 10) return 12;
  if (itemCount <= 16) return 10.5;
  return 9;
}

/// Whether segment labels should be drawn at all for [itemCount] items. See
/// [wheelMaxLabeledSegments].
bool wheelShouldShowLabels(int itemCount) =>
    itemCount > 0 && itemCount <= wheelMaxLabeledSegments;
