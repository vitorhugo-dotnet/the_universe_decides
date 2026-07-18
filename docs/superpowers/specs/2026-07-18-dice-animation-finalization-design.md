# Dice Animation Finalization Design

## Goal

Make every dice roll finish within a bounded duration without changing the
values returned by the randomness service, while keeping every face legible.

## Design

The web renderer owns the forced visual completion. Each bridge request keeps a
single completion path and a maximum-duration timer. If physics has not called
back before that timer expires, the bridge stops the current renderer loop,
uses the already supplied roll results to settle the dice faces, and emits the
same `rollCompleted` event used by a natural completion. A request may complete
only once.

Flutter keeps a separate safety timer. On expiry it asks the bridge to finalize
the matching request instead of setting an animation error. The timer is
cancelled whenever the request completes, the screen is disposed, or a newer
request supersedes it. Stale events and finalization requests are ignored.

The renderer material uses lower specular/shininess values so highlights do not
cover labels. The labels for `6` and `9` retain an orientation indicator, but
draw `--` instead of the current dot.

## Constraints

- Do not change the random-number service or recalculate any roll result.
- Preserve the existing dice, coin, and other-mode behavior.
- Complete timeout rolls normally, without user-facing error copy.
- Do not add dependencies.

## Verification

- Dart unit tests cover bridge finalization requests and stale completion
  handling.
- Asset tests assert that the renderer contains the bounded-completion API,
  lower-reflection material values, and the `--` orientation indicator.
- Focused widget tests cover a timeout completing the active request without an
  error and releasing the controls.
