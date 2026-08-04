# Wheel Drag Physics Design

## Goal

Let users rotate the List Draw wheel directly with a circular drag and launch
a spin by releasing a sufficiently strong flick, while preserving button and
tap-to-spin behavior.

## Interaction

- A drag rotates the dial by the signed angular delta between consecutive
  pointer positions around the wheel center.
- Releasing after a meaningful angular movement starts the existing draw flow.
- The recent angular velocity influences how many visual turns and how long the
  wheel takes to settle. Direction is preserved for clockwise and
  counter-clockwise flicks.
- A short tap remains a tap-to-spin. A weak or accidental drag only repositions
  the wheel and does not request randomness.
- Gestures are ignored while a draw is loading or an animation is running.
- With reduced motion enabled, dragging may reposition the wheel, but the draw
  settles immediately when released.

## Architecture

Pure geometry helpers calculate pointer angles, shortest signed angular deltas,
and a bounded flick profile. `ListPickerWheelView` owns gesture state and feeds
the profile into the existing visual spin. `ListPickerController.spinWheel()`
remains the only draw entrypoint, so Random.org/local fallback still determines
the winner before the dial settles exactly on that segment.

## Validation

Unit tests cover angular wrap-around and bounded flick profiles. Widget tests
cover drag-following, flick-triggered draws, accidental-drag rejection,
re-trigger blocking, and reduced motion. The full Flutter analyzer and test
suite must pass in CI.
