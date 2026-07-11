# Coin Ritual Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Live progress is mirrored in `docs/progress/2026-07-10-coin-ritual-redesign.md`.

**Goal:** Rebuild the Coin screen to strictly reproduce the Claude Design "Mystic Coin — ritual" prototype, adding a physical toss animation and a drag-and-flick manual launch, while keeping the Random.org result logic untouched (Issues #16 and #17).

**Architecture:** `CoinFlipScreen` becomes a full-bleed custom screen (no `MysticScreenScaffold`) that paints the ritual background, two counter-rotating rune rings, and a 3D coin. A `Ticker`-driven state machine (`idle → rising → landing`, plus `dragging → returning`) computes the coin transform each frame; the **result is always taken from the existing `coinFlipProvider` (Random.org + local fallback)** and the visual only lands on the resolved face. All continuous animation is gated on `MediaQuery.disableAnimations` for reduced-motion support.

**Tech Stack:** Flutter 3.38 SDK only (Material, `Ticker`/`AnimationController`, `Transform`, `GestureDetector`, `CustomPainter`, `HapticFeedback`). Riverpod for state. **No new packages. No physics engine.**

## Global Constraints

- The Claude Design "Mystic Coin", variant `ritual`, is the ONLY visual source of truth (rendered by `Coin Flip Redesign.dc.html` → `dc-import name="Mystic Coin" variant="ritual"`).
- Do NOT modify Random.org integration or its local fallback (`lib/services/random_org_service.dart`, `lib/controllers/coin_flip_controller.dart`).
- Do NOT change state management (Riverpod), add packages, or add a physics engine.
- Do NOT touch unrelated screens, `MysticScreenScaffold`, themes, native Android, or CI.
- Do NOT commit to `master`, do NOT merge, do NOT manually close issues. Work on branch `feat/coin-ritual-redesign`; issues close via PR merge.
- Result values remain exactly `0 = HEADS/CARA`, `1 = TAILS/COROA`; only one launch may run at a time.
- Reduced-motion (`MediaQuery.disableAnimations`) must skip the flight and rune loops.

---

## Prototype → Flutter element map (source of truth)

Ritual variant config: `lift:120, duration:1400, spins:4.6, wobble:0.3, wobbleFreq:9, bounce:false, driftMax:10`.

| Prototype element | Value (verbatim) | Flutter equivalent |
|---|---|---|
| Background | `radial-gradient(70% 55% at 50% 35%, rgba(122,79,255,.28), transparent 72%)` over `linear-gradient(180deg,#090611,#12091E,#090611)` | `Stack`: base `LinearGradient` (top→bottom `0xFF090611`,`0xFF12091E`,`0xFF090611`) + overlay `RadialGradient(center: Alignment(0,-0.3), radius: .9, colors:[0x477A4FFF, transparent])` |
| Eyebrow | `Fraunces` italic, 13px, ls .06em, `rgba(255,255,255,.5)`; text `Selo Ritual` | `Text(l10n.coinEyebrow)` italic, `fontFamily:'serif'`, size 13, `letterSpacing:.78`, color `0x80FFFFFF` |
| Title | 28px, w800, ls -.01em; `Cara ou Coroa` | `Text(l10n.coinTitle)` size 28 w800 ls -0.3 |
| Subtext | 14px, line 1.5, `rgba(255,255,255,.62)`, max-width 290; ritual `sub` | `Text(l10n.coinRitualSubtitle)` size 14 height 1.5 color `0x9EFFFFFF`, `ConstrainedBox(maxWidth:290)` |
| Rune ring A | 260px, `1px dashed rgba(139,123,255,.35)`, spin 22s | `RotationTransition(_runeA 22s)` + `_RuneRingPainter(dashed, 0x598B7BFF, 260)` |
| Rune ring B | 222px, `1px dotted rgba(249,180,76,.3)`, spin-rev 16s | `RotationTransition(Reverse _runeB 16s)` + `_RuneRingPainter(dotted, 0x4DF9B44C, 222)` |
| Coin | 168px circle, `transformStyle preserve-3d` | 168 `SizedBox`, `Transform`(perspective 0.002 + rotateX/rotateY) |
| Front face (CARA) | `linear-gradient(135deg,#FCE38A,#F9B44C)`, border `3px rgba(255,255,255,.28)`, shadow `0 18px 30px rgba(0,0,0,.45)` + inset highlight; dark dot 34px `rgba(0,0,0,.62)`; label `CARA` 15px w800 `rgba(0,0,0,.7)` ls1.5 | `_CoinFace(front)` `LinearGradient` topLeft→bottomRight `coinFrontStart/End`, `Border.all(0x47FFFFFF,3)`, `BoxShadow(0x73000000, blur30, y18)` + top white inner highlight overlay; dot `Container(34, 0x9E000000)`; `Text(l10n.coinHeads)` |
| Back face (COROA) | `linear-gradient(135deg,#E3D7FF,#8B7BFF)`; crescent = black dot + `#8B7BFF` dot offset `left:9`; label `COROA` | `_CoinFace(back)` `coinBackStart/End`; crescent `Stack`(circle `0x9E000000` + circle `0xFF8B7BFF` at left 9); `Text(l10n.coinTails)` |
| Drop shadow | 148×32 ellipse `radial rgba(0,0,0,.55)`, `translate(x*.6,96) scale(shadowScale)`, opacity `shadowOpacity`, blur2 | positioned `Container` ellipse `RadialGradient([0x8C000000, transparent])`, `Transform` translate/scale, `ImageFiltered` blur2 |
| Charge glow (drag, ritual) | 190px ring `2px rgba(249,180,76,.55)`, opacity `.25+dragMag*.6`, glow | `_CoinFace` overlay ring `Border.all(0x8CF9B44C,2)` + `BoxShadow` scaled by drag magnitude |
| Impact ring (t>0.6) | 130px `1.5px rgba(139,123,255,.6)`, `scale .4→1 opacity .8→0` .5s | `_impact` controller drives scale/opacity ring `0x998B7BFF` |
| Flash / shake | white overlay `mc-flash .32s`; scene `mc-shake .25s` | `_impact` white overlay opacity + small `Transform` translateX |
| Result block | label 34px w800 ls.02em; caption 13px `rgba(255,255,255,.55)` `O universo decidiu — não o processador.` | `Text(resultLabel)` 34 w800; `Text(l10n.coinResultCaption)` 13 `0x8CFFFFFF` |
| Hint | 13.5px `rgba(255,255,255,.5)`; idle `Toque no botão…`, drag `Solte para lançar…` | `Text(l10n.coinHint / coinHintDrag)` 13.5 `0x80FFFFFF` |
| Button | 100%/max320, h54, radius18, gradient `135deg #FCE38A→#F9B44C`, text `#1a1030` 16 w800, shadow `0 10px 24px -8px rgba(249,180,76,.55)`, disabled opacity .55; `Lançar a moeda` | `_GradientButton` 54h radius18 `LinearGradient` gold, `Color(0xFF1A1030)`, `BoxShadow(0x8CF9B44C, blur24, y10, spread-8)`, `Text(l10n.coinButton)` |
| Helper | 12px `rgba(255,255,255,.4)`; `ou arraste e solte a moeda para lançar` | `Text(l10n.coinDragHelper)` 12 `0x66FFFFFF` |

Interaction physics (verbatim): auto → `spins=floor(4.6+rand*1.2)`, `spinDir=±1`, `totalRotation=spinDir*(spins*360 + (result==1?180:0))`; drag rubber-band clamp `max=100`; release `speed<0.28` → return (260ms), else throw with `boost=min(1.4, speed/1.2)`. **In this port the `result` comes from `coinFlipProvider`, not `Math.random`.** Landing decelerates onto the face matching that result.

---

## File Structure

- **Modify** `lib/screens/coin_flip_screen.dart` — full rewrite: ritual screen + `_CoinArena` (ticker state machine, drag/flick), `_CoinFace`, `_RuneRingPainter`, `_GradientButton`. Single file (matches repo's one-screen-per-file convention).
- **Modify** `lib/l10n/app_en.arb`, `lib/l10n/app_pt.arb` — replace coin copy with prototype strings.
- **Regenerate** `lib/l10n/generated/*` via `flutter gen-l10n`.
- **Modify** `test/widget_test.dart` — add `disableAnimations` in `setUp` (keeps `pumpAndSettle` valid now that the coin arena is always mounted via `IndexedStack`); update pt button expectation to `Lançar a moeda`.

No other files change.

---

### Task 1: Prototype copy in localizations

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_pt.arb`
- Regenerate: `lib/l10n/generated/app_localizations*.dart`

**Interfaces:**
- Produces getters on `AppLocalizations`: `coinEyebrow`, `coinTitle`, `coinRitualSubtitle`, `coinHeads`, `coinTails`, `coinResultCaption`, `coinHint`, `coinHintDrag`, `coinDragHelper`, `coinButton`. Removes `coinSubtitle`, `coinPrompt`, `coinTapPrompt`, `coinResolved`.

- [ ] **Step 1: Replace the coin block in `app_en.arb`** (keys above; EN values: `Ritual Seal` / `Heads or Tails` / `A mystic seal lights up to confirm: the result comes from pure chance.` / `HEADS` / `TAILS` / `The universe decided — not the processor.` / `Tap the button or drag the coin to flip` / `Release to flip — pull further for more force` / `or drag and flick the coin to throw it` / `Flip a coin`).
- [ ] **Step 2: Replace the coin block in `app_pt.arb`** (PT values: `Selo Ritual` / `Cara ou Coroa` / `Um selo místico se acende para confirmar: o resultado vem do acaso puro.` / `CARA` / `COROA` / `O universo decidiu — não o processador.` / `Toque no botão ou arraste a moeda para lançar` / `Solte para lançar — puxe mais para mais força` / `ou arraste e solte a moeda para lançar` / `Lançar a moeda`).
- [ ] **Step 3: Regenerate** — Run: `flutter gen-l10n`. Expected: new getters present in `lib/l10n/generated/app_localizations.dart`.
- [ ] **Step 4: Commit** — `git add lib/l10n && git commit -m "feat(coin): prototype copy for ritual redesign"`.

---

### Task 2: Ritual screen shell (background, header, rune rings, button, helper)

**Files:**
- Modify: `lib/screens/coin_flip_screen.dart`
- Test: `test/widget_test.dart` (existing "coin screen uses the random service")

**Interfaces:**
- Produces `_RuneRingPainter({required Color color, required double strokeWidth, required double dashLength, required double gapLength, required bool dotted})` and `_GradientButton({required String label, VoidCallback? onPressed})`.
- Consumes `_runeA`/`_runeB` `AnimationController`s (22s / 16s) started only when `!MediaQuery.disableAnimations`.

- [ ] **Step 1:** Rewrite the screen scaffold: `DecoratedBox` ritual background (base `LinearGradient` + overlay `RadialGradient`), `SafeArea` already provided by `MainScreen`; `Column` with header (`coinEyebrow` italic serif, `coinTitle`, `coinRitualSubtitle`), `Expanded` coin arena placeholder, result/hint block, `_GradientButton(coinButton)`, helper `coinDragHelper`. Use exact sizes/colors from the element map.
- [ ] **Step 2:** Add `_RuneRingPainter` (uses `Path.computeMetrics()` to stroke dashes/dots) and place two `RotationTransition`-wrapped `CustomPaint`s (260 dashed purple, 222 dotted amber) centered behind the arena. Start `_runeA.repeat()` / `_runeB.repeat()` only when `!disableAnimations`.
- [ ] **Step 3:** Run existing coin test — Run: `flutter test test/widget_test.dart -p vm --plain-name "coin screen uses the random service"`. Expected: after `setUp` adds `disableAnimations` (Task 4) it PASSES; before that it may hang, so temporarily assert build via `flutter analyze` only. Expected `flutter analyze`: no errors.
- [ ] **Step 4: Commit** — `git commit -am "feat(coin): ritual screen shell and rune rings"`.

---

### Task 3: 3D coin, toss physics, and drag-flick launch

**Files:**
- Modify: `lib/screens/coin_flip_screen.dart`

**Interfaces:**
- Produces `_CoinArena` (`ConsumerStatefulWidget` with `TickerProviderStateMixin`) exposing `launchAuto()` (called by button + quick-access trigger) and internal pan handlers.
- Produces `_CoinFace({required bool front, required String heads, required String tails})`.
- Consumes `coinFlipProvider` for the authoritative result and `isLoading`.

- [ ] **Step 1:** Implement `_CoinFace` for front (CARA: dark dot + label) and back (COROA: crescent + label) with gradients, border, drop shadow, and inset highlight from the element map.
- [ ] **Step 2:** Implement the state machine with a single `Ticker`: `idle`, `rising` (arc up + constant-velocity spin while awaiting the result), `landing` (decelerate onto the result face, `arcHeight`/`easeOutCubic`/`easeInOutQuad`, no bounce), `dragging`, `returning`. Compute per-frame `x,y,rotX,rotY,lift,scale,shadow` into a `ValueNotifier<double> _clock`; the coin `AnimatedBuilder` reads it (no per-frame `setState`).
- [ ] **Step 3:** `launchAuto()`: guard `phase==idle && !isLoading`; pick `spinDir`, `spins`, `driftX`, `omega`; enter `rising`; `await ref.read(coinFlipProvider.notifier).flip()`; read `state.result`; when result ready and min spin elapsed → `landing` onto `result==1?180:0` (mod 360, continuing spin direction). Fire impact (`_impact.forward` + `HapticFeedback.mediumImpact`) at ~90% of landing. On complete → `idle`, reveal result.
- [ ] **Step 4:** Drag via `GestureDetector.onPanStart/Update/End`: rubber-band clamp (`max=100`), sample recent points for velocity; on end `speed<0.28` → `returning` (260ms spring), else `launchAuto()`-style throw with `boost` scaling spins/lift/drift. `HapticFeedback.lightImpact` on a committed flick. Block all input while `phase!=idle`.
- [ ] **Step 5:** Wire `_impact` controller into the coin `AnimatedBuilder` for flash (white overlay `.32s`), impact ring (`scale .4→1`, `opacity .8→0`), shake (translateX), and the drag charge glow (amber ring scaled by drag magnitude).
- [ ] **Step 6: Analyze** — Run: `flutter analyze`. Expected: no errors. **Commit** — `git commit -am "feat(coin): 3D toss physics and drag-flick launch"`.

---

### Task 4: Reduced motion, tests, and full verification

**Files:**
- Modify: `lib/screens/coin_flip_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes `MediaQuery.of(context).disableAnimations`.

- [ ] **Step 1:** Add reduced-motion path: when `disableAnimations`, `launchAuto()` skips the ticker/flight, `await flip()`, and reveals the result via a ≤200ms `AnimatedSwitcher`; rune loops are not started; pan-throw is disabled (coin still tappable = launch). Ambient controllers `.stop()` when `disableAnimations`.
- [ ] **Step 2:** In `test/widget_test.dart` add a `setUp`/`tearDown` that sets `TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true)` and clears it (keeps `pumpAndSettle` finite since the coin arena is always mounted via `IndexedStack`).
- [ ] **Step 3:** Update the pt-locale test expectation `find.text('Jogar uma moeda')` → `find.text('Lançar a moeda')`. Keep the en test `Flip a coin` and the `TAILS` assertion.
- [ ] **Step 4: Run full suite** — Run: `flutter test`. Expected: all tests PASS.
- [ ] **Step 5: Analyze + format** — Run: `flutter analyze` (no issues) and `dart format .` (no unexpected diffs beyond touched files).
- [ ] **Step 6: Visual verification** — build/run the coin screen (or `flutter run`/screenshot) to confirm it matches the prototype: eyebrow/title/subtext, rune rings, gold/purple coin, toss arc, drag-flick, result caption, gold button, helper. Fix deviations against the element map.
- [ ] **Step 7: Commit + open PR** — `git commit -am "feat(coin): reduced motion + tests"`; push branch; open PR referencing `Closes #16` and `Closes #17` (do not merge, do not close issues manually).

---

## Self-Review

- **Spec coverage:** Issue #16 (visual polish, clearer copy/use-case) → Tasks 1–3 (ritual visuals, eyebrow/subtext/caption copy). Issue #17 (physical toss + gesture launch, single launch, reduced motion, controller-owned result) → Task 3 (physics, drag-flick, single-flight guard) + Task 4 (reduced motion). Prototype fidelity → element map + Tasks 2–3.
- **No physics engine / no packages:** SDK `Ticker`/`Transform`/`GestureDetector`/`CustomPainter`/`HapticFeedback` only. ✔
- **Result integrity:** result always from `coinFlipProvider`; animation lands on it, never decides it. ✔
- **Type consistency:** `launchAuto()`, `_CoinFace`, `_RuneRingPainter`, `_GradientButton`, `_clock`, `_impact`, `_runeA/_runeB` used consistently across tasks. ✔
- **Tests stay green:** `disableAnimations` in `setUp` keeps `pumpAndSettle` finite; pt copy expectation updated. ✔
