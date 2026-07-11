# Progress — Full App Redesign (Claude Design) — Issues #16 & #17

Plan: [`docs/plan/2026-07-10-coin-ritual-redesign.md`](../plan/2026-07-10-coin-ritual-redesign.md)
Branch: `feat/coin-ritual-redesign`

## Task 1 — Coin copy
- [x] EN/PT coin keys + regenerate + commit

## Task 2 — Ritual tokens + shared widgets
- [x] Ritual color tokens in `AppColors`
- [x] `RitualBackground` + `RuneRingPainter`/`RuneRing` (shell/coin variants, reduced-motion gated)
- [x] `RitualHeader`, `RitualButton`
- [x] analyze clean

## Task 3 — Shell + custom bottom nav
- [x] `RitualBottomNav` (6 geometric icons)
- [x] `MainScreen` shell (background + scrollable IndexedStack + nav)
- [x] analyze clean

## Task 4 — Coin screen (Mystic Coin ritual) [#16/#17]
- [x] `_CoinFace` front/back
- [x] Ticker state machine + impact/glow/haptics
- [x] `_launchAuto()` result from controller, lands on face
- [x] Drag rubber-band + flick throw + weak-flick return
- [x] Reduced-motion path
- [x] Screen composition
- [x] analyze clean (commit pending with screens batch)

## Task 5 — Dice screen restyle
- [ ] Redesigned chrome, sides [4,6,20,100], keep tumble + provider
- [ ] analyze + commit

## Task 6 — Cards screen restyle
- [ ] 3D flip mystic card, keep provider
- [ ] analyze + commit

## Task 7 — Lists screen restyle
- [ ] Input + choose + selected badge + rows + empty
- [ ] analyze + commit

## Task 8 — Tarot screen restyle
- [ ] RitualHeader + button, align copy, keep flip + provider
- [ ] analyze + commit

## Task 9 — About screen + randomness sheet
- [ ] About layout (GitHub data + shortcuts + randomness card)
- [ ] `how_randomness_sheet.dart`
- [ ] analyze + commit

## Task 10 — l10n, tests, verification
- [ ] All new keys + remove unused + regenerate
- [ ] Update `widget_test.dart` (disableAnimations, labels, copy)
- [ ] `flutter test` pass + analyze + format
- [ ] Visual verification vs prototype
- [ ] Commit + open PR (no merge, no manual close)
```
