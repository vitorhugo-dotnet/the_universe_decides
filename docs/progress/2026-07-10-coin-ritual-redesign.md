# Progress — Coin Ritual Redesign (Issues #16 & #17)

Plan: [`docs/plan/2026-07-10-coin-ritual-redesign.md`](../plan/2026-07-10-coin-ritual-redesign.md)
Branch: `feat/coin-ritual-redesign`

## Task 1 — Prototype copy in localizations
- [x] Replace coin block in `app_en.arb`
- [x] Replace coin block in `app_pt.arb`
- [x] Regenerate `flutter gen-l10n`
- [ ] Commit

## Task 2 — Ritual screen shell (background, header, rune rings, button, helper)
- [ ] Screen scaffold + ritual background + header + result/hint + button + helper
- [ ] `_RuneRingPainter` + two rotating rune rings (gated on reduced motion)
- [ ] `flutter analyze` clean
- [ ] Commit

## Task 3 — 3D coin, toss physics, drag-flick launch
- [ ] `_CoinFace` front (CARA) + back (COROA crescent)
- [ ] Ticker state machine (idle/rising/landing/dragging/returning)
- [ ] `launchAuto()` — result from `coinFlipProvider`, lands on resolved face
- [ ] Drag rubber-band + flick velocity throw + weak-flick return
- [ ] Impact effects (flash/ring/shake) + charge glow + haptics
- [ ] `flutter analyze` clean + commit

## Task 4 — Reduced motion, tests, verification
- [ ] Reduced-motion path (skip flight/rune loops, quick reveal)
- [ ] `setUp` sets `disableAnimations` in `test/widget_test.dart`
- [ ] Update pt button expectation → `Lançar a moeda`
- [ ] `flutter test` all pass
- [ ] `flutter analyze` + `dart format`
- [ ] Visual verification against prototype
- [ ] Commit + open PR (`Closes #16`, `Closes #17`) — no merge, no manual close
