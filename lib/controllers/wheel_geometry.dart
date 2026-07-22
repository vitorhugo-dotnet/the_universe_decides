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

/// Computes the absolute rotation (radians, typically several full turns)
/// the wheel must animate to so [winnerIndex]'s segment center lands under
/// the fixed pointer ([wheelPointerAngle]).
///
/// Always continues forward from [currentRotation] (never spins backward,
/// mirroring the coin flip's `_nextCongruent` approach) and layers on
/// [extraSpins] full revolutions so short hops still feel like a spin.
///
/// The winner is decided entirely by the caller (via the randomness
/// service) *before* this is invoked — this function is a one-way, visual
/// mapping only, it never influences which index "wins".
double computeWheelTargetRotation({
  required int winnerIndex,
  required int itemCount,
  required double currentRotation,
  int extraSpins = wheelDefaultExtraSpins,
}) {
  assert(itemCount > 0, 'itemCount must be positive');
  assert(
    winnerIndex >= 0 && winnerIndex < itemCount,
    'winnerIndex out of range',
  );

  final segment = wheelSegmentAngle(itemCount);
  final segmentCenter = segment * winnerIndex + segment / 2;
  final desiredMod = normalizeAngle(wheelPointerAngle - segmentCenter);
  final currentMod = normalizeAngle(currentRotation);

  var delta = desiredMod - currentMod;
  if (delta <= 0) {
    delta += 2 * math.pi;
  }

  return currentRotation + delta + extraSpins * 2 * math.pi;
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
