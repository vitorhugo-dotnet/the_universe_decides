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
- [x] Redesigned chrome, sides [4,6,20,100], keep tumble + provider

## Task 6 — Cards screen restyle
- [x] 3D flip mystic card, keep provider

## Task 7 — Lists screen restyle
- [x] Input + choose (gated ≥2) + selected badge + rows + empty

## Task 8 — Tarot screen restyle
- [x] RitualHeader + button, aligned copy, keep flip + provider

## Task 9 — About screen + randomness sheet
- [x] About layout (GitHub data + shortcuts + randomness card)
- [x] `how_randomness_sheet.dart`

## Task 10 — l10n, tests, verification
- [x] All new keys + removed unused + regenerated
- [x] Update `widget_test.dart` (disableAnimations, labels, copy)
- [x] `flutter test` pass (16) + analyze clean + format
- [ ] Visual verification vs prototype
- [ ] Commit + open PR (no merge, no manual close)
