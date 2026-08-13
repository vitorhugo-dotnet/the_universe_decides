# The "debug overlay" lines under Quick Coin text

## Symptom

`QuickCoinActivity` rendered thin yellow horizontal lines directly under text —
most visibly under the result word (`HEADS` / `TAILS`) and under the decision
sentence below it. The normal in-app coin screen never showed them.

They were reported as Flutter's debug baseline painting (ideographic baseline is
yellow, alphabetic baseline is green). They were not.

## Actual root cause

`MaterialApp` passes `_errorTextStyle` to `WidgetsApp` as the root
`DefaultTextStyle`:

```dart
const TextStyle _errorTextStyle = TextStyle(
  color: Color(0xD0FF0000),
  fontFamily: 'monospace',
  fontSize: 48.0,
  fontWeight: FontWeight.w900,
  decoration: TextDecoration.underline,
  decorationColor: Color(0xFFFFFF00),   // yellow
  decorationStyle: TextDecorationStyle.double,  // two thin lines
);
```

Normally a `Material` widget shadows it: `Material` installs an
`AnimatedDefaultTextStyle` built from `Theme.of(context).textTheme.bodyMedium`,
which carries no decoration. In the normal flow `MainScreen` wraps
`CoinFlipScreen` in a `Scaffold`, and `Scaffold` supplies that `Material`.

The quick coin route did not. `UniverseRoutes.quickCoin` pushed
`CoinFlipScreen` straight into a `PageRouteBuilder`, and the screen's own tree
starts at `GestureDetector` → `SafeArea` → `Padding` → `Column`. No `Scaffold`,
no `Material`, so the error style stayed in effect.

`Text` merges its explicit style *over* the inherited one. The screen's styles
set `color`, `fontSize`, `fontWeight` and `letterSpacing`, so the loud red
48 px monospace was overridden — but nothing set `decoration`, so the double
yellow underline survived the merge and was the only part of the error style
still visible. Two thin yellow lines under text is exactly what a baseline
overlay looks like, which is why it was misdiagnosed.

This also explains every property of the bug report: it appeared only in
`QuickCoinActivity`, it appeared in release builds (the error style is not
debug-only, unlike `debugPaintBaselinesEnabled`, which is compiled out of
release), and re-asserting `debugPaintBaselinesEnabled = false` in `main()`
changed nothing — that flag was already `false`.

## Fix

Wrap the quick coin page in `Material(type: MaterialType.transparency, ...)` in
`lib/main.dart`. `MaterialType.transparency` paints no background, so the
route stays see-through for `BackgroundMode.transparent` in
`QuickCoinActivity`, while still providing the default text style.

Do not fix this with `TextDecoration.none` on individual `TextStyle`s. That
hides one symptom per widget and leaves the next unstyled `Text` on the route
broken again.

## Regression tests

* `test/quick_coin_text_decoration_test.dart` pumps the quick coin route and
  asserts no rendered paragraph carries a text decoration, and that a
  `Material` ancestor exists above the text.
* `test/debug_paint_regression_test.dart` asserts the debug paint flags are
  `false` at runtime and that both routes keep a `Material` ancestor.

## If you ever do see real baseline lines

Real baseline painting comes from tooling, not from app code:

* Flutter Inspector → **Show baselines** (`debugPaintBaselinesEnabled` service
  extension `ext.flutter.debugPaintBaselinesEnabled`).
* VS Code → command palette → **Flutter: Toggle Baseline Painting**.
* Android Studio / IntelliJ → Flutter Inspector toolbar → **Show Baselines**.

These toggle the flag at runtime over the VM service, and they only work on
debug builds. If the lines survive a `--release` build, it is not baseline
painting.
