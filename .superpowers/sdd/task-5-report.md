## Task 5: Dice ritual screen

### Delivered

- Replaced the old Material card and native tumbling grid with the supplied
  RPG Dice ritual hierarchy: ritual heading, compact quantity/sides selectors,
  gold roll action, central animation region, light result tiles, expression,
  and total.
- Embedded one transparent `DiceWebView` in the animation region. The screen
  dispatches only the `DiceRollRequest` produced by the controller, completes
  the matching bridge request, pauses/resumes with app lifecycle changes, and
  converts an uncompleted animation into a bounded 12-second timeout.
- Kept the Quick Settings d20 trigger, disabled every dice control while a
  fetch or animation is active, and surface animation failures both inline and
  in a snackbar while retaining the fetched values.

### Test-driven development

`test/dice_roll_screen_test.dart` was introduced before the screen refactor.
The initial focused run failed because the screen did not yet expose the WebView
test seam required to render the animation region without a platform view.
The final tests cover controls being disabled while fetching and animating, and
the fetched result/total being retained after an animation failure.

### Verification

```text
flutter test test/dice_roll_screen_test.dart
00:01 +2: All tests passed!

flutter analyze lib/screens/dice_roll_screen.dart test/dice_roll_screen_test.dart
No issues found!
```

`dart format` was clean and `git diff --check` completed without whitespace
errors.
