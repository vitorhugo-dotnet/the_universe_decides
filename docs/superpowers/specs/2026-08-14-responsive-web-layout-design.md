# Responsive web layout design

## Goal

Make the browser build adapt to the window it is given, so that a desktop
visitor sees a layout composed for a wide screen instead of a phone column
centred in empty space.

The app already centres the browser shell at `maxWidth: 560`
(`lib/screens/main_screen.dart`), so a desktop window is not stretched. The
problem is what happens inside that column: every screen is composed for a
hand-held portrait aspect, with fixed type sizes and fixed block heights. In a
1510x700 window the result reads as a phone emulator — a tall narrow strip with
unused space on both sides and a cramped vertical rhythm.

## Layout is chosen by width, not by platform

Three bands, selected from the window width:

| Band | Width | Layout |
| --- | --- | --- |
| `compact` | < 600 | Today's layout unchanged: bottom nav, single column, full bleed |
| `medium` | 600-1023 | Bottom nav, single centred column up to 720, larger spacing and type |
| `expanded` | >= 1024 | Vertical navigation rail, content in two panes |

`1024` is where the rail and the two-pane split begin. The rail occupies about
88 logical pixels, leaving 936; two panes of roughly 440 with a 48 gutter need
928. Below that the two panes squeeze both sides and a single column reads
better.

Driving this from width rather than `kIsWeb` matters. The `compact` band covers
every phone, so Android phones render exactly as they do today, while Android
tablets and foldables gain the wide layout at no extra cost. The `kIsWeb` branch
in `main_screen.dart` is replaced by band selection.

The capture goldens are unaffected: `test/_capture_test.dart` renders at
820x1740 physical with `devicePixelRatio` 2, which is 410x870 logical, inside
`compact`.

## The frame and its slots

A single frame widget owns every arrangement decision. Screens declare content,
not arrangement, through three slots:

- `header` — the `RitualHeader`.
- `stage` — optional. The visual object of the ritual.
- `body` — result, controls, and buttons.

In `compact` and `medium` the frame stacks the slots in today's order. In
`expanded` it places `stage` in the left pane, centred and vertically stable,
and `header` followed by `body` in the right pane, which scrolls independently.

Concentrating the rule in one widget is the point of the design. The failure it
prevents is six screens each growing their own notion of "wide", which is how
responsive layouts drift apart as features are added.

### Slot mapping

| Screen | `stage` | Notes |
| --- | --- | --- |
| Coin | 300x300 arena | Direct fit; `Expanded(Center(...))` becomes the stage slot |
| Cards | 210x296 card | Direct fit |
| Tarot | 2/3 aspect card | Absorbs the existing `LayoutBuilder` |
| Dice | `DiceWebView` | Count and side pickers move to `body` |
| Lists | Wheel or result | See below |
| About | none | Exception; see below |

### Lists has two modes and only one of them has a stage

In wheel mode the spinning wheel is the stage. In classic mode there is no
visual object at all — only the text field, the item list and the pick button.
Leaving the left pane empty looks broken, and collapsing to a single column when
the mode changes makes the page skeleton jump, which reads as navigating
somewhere else.

In `expanded` classic mode the left pane shows the drawn result, in the position
the wheel would occupy. The skeleton stays fixed across the toggle, and classic
mode gains the reveal moment it currently lacks on a wide screen.

### About has no stage

About is a content and settings page, not a ritual. Forcing it into two panes
would widen its measure and hurt reading. Because `stage` is optional, the frame
renders it in `expanded` as a single centred column capped at 640, which keeps
the measure inside a comfortable reading range.

## Navigation

In `expanded` the `RitualBottomNav` is replaced by a vertical rail carrying the
same six items, the same geometric outline icons, the same gold-on-active
treatment and the same blurred translucent surface. Only the orientation
changes.

The long-press that opens the Entropy Drift minigame stays on the same item and
keeps working.

## Three widgets that constrain the design

- **Dice.** `DiceWebView` is an `<iframe>` inside an `HtmlElementView`
  (`lib/dice/dice_renderer_web.dart`). It currently lives in a fixed
  `SizedBox(height: 320)` wrapping a 280x280 surface. The stage slot must give
  it a stable box with a fixed aspect: resizing the iframe while the physics
  animation runs is where this breaks.
- **Lists wheel.** `list_picker_wheel_view.dart` paints on a canvas with radius
  maths derived from the available width. It receives the stage radius; the
  maths is not touched.
- **Tarot.** The card already runs `AspectRatio(2/3)` with a `LayoutBuilder`
  whose local `isCompact` is derived from height. That local flag reads the
  frame's band instead, so two disagreeing notions of "compact" cannot coexist.

## Testing

Widget tests mount each screen at three widths — 400, 800 and 1400 — and assert:

- at 400 the bottom nav is present and the rail is absent;
- at 1400 the rail is present and the bottom nav is absent;
- no overflow is reported at any of the three widths;
- About never renders two panes;
- toggling the Lists mode in `expanded` does not change the page skeleton.

Existing analysis, tests and the capture goldens continue to run unchanged.

## Versioning

This is a user-visible `feat`, so the semantic version name takes a `MINOR`
increment, which resets the patch component to `0` and preserves the build
number after `+` exactly. From the `2.6.x` line currently on `master` that
lands on `2.7.0`. `CHANGELOG.xml` is rewritten for this change across all nine
supported locales.

## Out of scope

- WebAssembly. Measured separately in `docs/web-github-pages.md`; the decision
  to ship the standard build is unchanged and independent of layout.
- Any change to the randomness pipeline, the RANDOM.ORG fallback, or the results
  history.
- Desktop-only features. This design rearranges what exists; it adds no screen
  and no capability.
