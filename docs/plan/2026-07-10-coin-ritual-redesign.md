# Full App Redesign Implementation Plan (Claude Design)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement task-by-task. Steps use checkbox (`- [ ]`) syntax. Live progress is mirrored in `docs/progress/2026-07-10-coin-ritual-redesign.md`.

**Goal:** Redesign the entire app to strictly reproduce the Claude Design "The Universe Decides" prototype — a unified dark ritual shell (background + rotating runes + custom bottom nav), redesigned Coin/Dice/Cards/Lists/Tarot/About screens, and a "real randomness" explainer bottom sheet — while keeping Random.org logic, Riverpod, and all controllers intact. Fulfills Issues #16 and #17 (coin) inside the larger redesign the user requested.

**Architecture:** Introduce a shared **ritual shell** owned by `MainScreen`: a full-bleed background gradient + faint top rune rings + a custom 6-tab bottom nav with geometric icons; screens render only their content (scrollable) into it, dropping `MysticScreenScaffold`. A shared `RitualHeader` (Fraunces-italic eyebrow + bold title + subtext) and `RitualButton` (gold gradient) unify the screens. The Coin screen is the full "Mystic Coin — ritual" composition with a `Ticker`-driven 3D toss + drag/flick launch, where **the result always comes from `coinFlipProvider`** and the animation only lands on it. All continuous animation is gated on `MediaQuery.disableAnimations`.

**Tech Stack:** Flutter 3.38 SDK only. Riverpod. No new packages, no physics engine.

## Global Constraints (still binding from the original brief)

- The Claude Design "The Universe Decides" prototype (`The Universe Decides.dc.html`) + "Mystic Coin" variant `ritual` (`Mystic Coin.dc.html`) are the ONLY visual source of truth.
- Do NOT modify Random.org integration/fallback (`random_org_service.dart`) or the controllers' result logic.
- Keep Riverpod. No new packages. No physics engine.
- Branch `feat/coin-ritual-redesign`. Do NOT commit to `master`, do NOT merge, do NOT manually close issues (PR closes #16 and #17).
- Reduced motion (`MediaQuery.disableAnimations`) must skip flights and rune loops.

## Forced deviations (documented, unavoidable)

- **Dice 3D physics:** prototype uses `cannon.js`/`three.js` — a physics engine, forbidden. Keep the existing tumble-then-settle animation and roll logic; only restyle the surrounding chrome (header, quantity/sides selectors, button, results) to match.
- **Dice options:** match the prototype's visible set — counts 1–5, sides d4/d6/d20/d100 (drops d8/d10/d12 from the old chip row).
- **Nav labels:** adopt the prototype's shorter labels (Moeda/Dados/Cartas/Lista/Tarot/Sobre; EN Coin/Dice/Cards/Lists/Tarot/About). Tests updated accordingly.
- **About:** keep the live GitHub-driven avatar/name/bio (existing service), laid out per the prototype, plus the new "real randomness" explainer + bottom sheet.

---

## Prototype color tokens (Flutter)

`bg base` `linear-gradient(180deg,#090611,#12091E,#090611)`; `bg glow` `radial rgba(122,79,255,.28)=0x477A4FFF`; gold `#FCE38A=0xFFFCE38A`→`#F9B44C=0xFFF9B44C`; gold text `#1a1030=0xFF1A1030`; purple accent `#7A4FFF=0xFF7A4FFF`, `#8B7BFF=0xFF8B7BFF`; rune purple `0x598B7BFF`, rune amber `0x4DF9B44C`; text `.5=0x80FFFFFF`, `.62=0x9EFFFFFF`, `.55=0x8CFFFFFF`, `.4=0x66FFFFFF`; card back `#241a3d/#3E216E/#1a1030`; list result `#3E2D73→#7A4FFF` (existing `listResultGradient*`); tarot faces existing.

Add tokens to `AppColors`: `ritualGlow=0x477A4FFF`, `gold1=0xFFFCE38A`, `gold2=0xFFF9B44C`, `goldText=0xFF1A1030`, `runePurple=0x598B7BFF`, `runeAmber=0x4DF9B44C`, `runePurpleFaint=0x298B7BFF`, `runeAmberFaint=0x24F9B44C`.

---

## File Structure

- **Create** `lib/widgets/ritual_background.dart` — full-bleed background gradient + optional faint top rune rings (shell) or centered ritual runes (coin). Houses `_RuneRingPainter` (dashed/dotted circle via `Path.computeMetrics`).
- **Create** `lib/widgets/ritual_header.dart` — `RitualHeader({eyebrow, title, subtitle?})`.
- **Create** `lib/widgets/ritual_button.dart` — `RitualButton({label, onPressed, height})` gold gradient.
- **Create** `lib/widgets/ritual_bottom_nav.dart` — `RitualBottomNav` custom geometric 6-tab nav.
- **Create** `lib/widgets/how_randomness_sheet.dart` — `showHowRandomnessSheet(context)` modal bottom sheet.
- **Modify** `lib/screens/main_screen.dart` — shell: `RitualBackground` + `RitualBottomNav` + scrollable `IndexedStack`.
- **Rewrite** `lib/screens/coin_flip_screen.dart` — Mystic Coin ritual (physics, drag/flick, `_CoinFace`).
- **Restyle** `dice_roll_screen.dart`, `card_draw_screen.dart`, `list_picker_screen.dart`, `tarot_draw_screen.dart`, `about_me_screen.dart` — drop `MysticScreenScaffold`, use `RitualHeader`/`RitualButton`, match prototype.
- **Delete** `lib/widgets/mystic_screen_scaffold.dart` (fully replaced).
- **Modify** `lib/theme/app_colors.dart` — add ritual tokens.
- **Modify** `lib/l10n/app_en.arb`, `app_pt.arb` + regenerate — all new copy.
- **Modify** `test/widget_test.dart` — `disableAnimations` in `setUp`, updated labels/copy.

---

## Prototype copy → l10n keys (PT verbatim from prototype; EN translated)

Coin (done, Task 1): `coinEyebrow/coinTitle/coinRitualSubtitle/coinHeads/coinTails/coinResultCaption/coinHint/coinHintDrag/coinDragHelper/coinButton`.

Nav: `navCoin=Moeda/Coin, navDice=Dados/Dice, navCards=Cartas/Cards, navLists=Lista/Lists, navTarot=Tarot/Tarot, navAboutMe=Sobre/About`.

Dice: `diceEyebrow=Ritual dos Dados/RPG Dice Ritual`, `diceTitle=Dados RPG/RPG Dice`, `diceCountLabel=QUANTIDADE/QUANTITY`, `diceSidesLabel=LADOS/SIDES`, reuse `diceRollButton/diceTotal`, `diceResultsLine` uses join(" + ").

Cards: `cardEyebrow=Ritual das Cartas/Card Ritual`, `cardTitle=Baralho Completo/Full Deck`, `cardSubtitle=52 cartas. Um destino por toque./52 cards. One fate per tap.`, `cardButton=Sacar carta/Draw a card`.

Lists: `listEyebrow=Ritual da Escolha/Choice Ritual`, `listTitle=Sorteio de Lista/List Draw`, `listSubtitle=Adicione opções e deixe o acaso decidir./Add options and let chance decide.`, `listInputHint=Nova opção…/New option…`, `listChooseButton=Deixar o universo escolher/Let the universe choose`, `listChosenByUniverse` (reuse) `ESCOLHIDO PELO UNIVERSO/CHOSEN BY THE UNIVERSE`, `listEmptyTwo=Adicione ao menos duas opções para começar./Add at least two options to begin.`

Tarot: `tarotEyebrow=Ritual do Tarot/Tarot Ritual`, `tarotTitle=Leitura do Tarot/Tarot Reading`, `tarotSubtitleShort=Uma carta, revelada pelo acaso puro./One card, revealed by pure chance.`, `tarotButton=Revelar carta/Reveal card`, `tarotWaiting=A carta aguarda/The card awaits`, `tarotTapReveal=Toque em revelar/Tap to reveal`, reuse `tarotMajorArcana/tarotMinorArcana/tarotDeckPosition`.

About: `aboutEyebrow=O Oráculo/The Oracle`, keep `navAboutMe` as title, `aboutBioFallback=Criador de The Universe Decides — um app de decisões movido a aleatoriedade real./Creator of The Universe Decides — a decision app powered by real randomness.`, `aboutShortcutsTitle=Atalhos rápidos/Quick shortcuts`, reuse `aboutAddCoinButton/aboutAddDiceButton`, `aboutRandomnessCardTitle=Como funciona o acaso real?/How does real randomness work?`, `aboutRandomnessCardSubtitle=Por que o app não usa números pseudoaleatórios/Why the app avoids pseudo-random numbers`.

Randomness sheet: `randomnessSheetEyebrow=O que há por trás do acaso/What lies behind chance`, `randomnessSheetTitle=Acaso real vs. pseudoaleatório/Real chance vs. pseudo-random`, `randomnessCard1Title/Body`, `randomnessCard2Title/Body`, `randomnessCard3Title/Body` (bodies verbatim PT from prototype; EN translated), `randomnessSheetButton=Entendi/Got it`.

Remove now-unused: `coinSubtitle, coinPrompt, coinTapPrompt, coinResolved` (done), `diceSubtitle, diceCount, diceSides, diceEmptyState, diceResults, cardDrawSubtitle, cardDrawPrompt, cardDrawTapPrompt, cardDrawResolved, listSubtitle, listAddOptionLabel, listAddButton, listEmptyState, tarotSubtitle, tarotPrompt, tarotTapPrompt, aboutSubtitle` — only if no longer referenced after restyle (verify per screen).

---

## Tasks

### Task 1 — Coin copy (DONE)
- [x] EN/PT coin keys, regenerate, commit.

### Task 2 — Ritual tokens + shared widgets
- [ ] Add ritual color tokens to `AppColors`.
- [ ] `RitualBackground` (+ `_RuneRingPainter`): base gradient + glow; `variant: shell` (faint top runes 280/230, 30s/22s) and `variant: coin` (centered runes 260/222, 22s/16s). Loops gated on `disableAnimations`.
- [ ] `RitualHeader`, `RitualButton`.
- [ ] `flutter analyze` clean; commit.

### Task 3 — Shell + custom bottom nav
- [ ] `RitualBottomNav`: 6 geometric icons + labels, gold active / white40 inactive, blurred bar.
- [ ] `MainScreen`: `RitualBackground(shell)` behind scrollable `IndexedStack`; keep quick-access + fallback-snackbar wiring.
- [ ] `flutter analyze`; commit.

### Task 4 — Coin screen (Mystic Coin ritual) — Issues #16/#17
- [ ] `_CoinFace` front (CARA: dark dot + label) / back (COROA: crescent + label): gradients, 3px border, drop shadow, inner highlight.
- [ ] `_CoinArena` ticker state machine: `idle/rising/landing/dragging/returning`; per-frame transform via `ValueNotifier` clock; `_impact` controller (flash/ring/shake), charge glow, `HapticFeedback`.
- [ ] `launchAuto()` — guard single-flight; `await coinFlipProvider.flip()`; land on `result` face; reveal at landing.
- [ ] Drag rubber-band (max 100) + flick velocity throw (`speed<0.28`→return 260ms; else boost) ; block input while busy.
- [ ] Reduced-motion path (quick reveal, no ticker, tap-to-flip); rune loops off.
- [ ] Screen composition: `RitualBackground(coin)` + header (`coinEyebrow/coinTitle/coinRitualSubtitle`) + arena + result/hint + `RitualButton(coinButton)` + helper (`coinDragHelper`).
- [ ] `flutter analyze`; commit.

### Task 5 — Dice screen restyle
- [ ] `RitualHeader(diceEyebrow/diceTitle)`, `QUANTIDADE` row (1–5 pill buttons), `LADOS` row (d4/d6/d20/d100 pills), `RitualButton(diceRollButton)`, results line + `Total`. Keep tumble animation + `diceRollProvider`; set sides list `[4,6,20,100]`.
- [ ] `flutter analyze`; commit.

### Task 6 — Cards screen restyle
- [ ] `RitualHeader(cardEyebrow/cardTitle/cardSubtitle)`; 3D flip card (mystic back `#241a3d/#3E216E/#1a1030` + amber dashed emblem; front playing card) via `AnimatedSwitcher` rotateY flip keyed on draw; `RitualButton(cardButton)`. Keep `cardDrawProvider`.
- [ ] `flutter analyze`; commit.

### Task 7 — Lists screen restyle
- [ ] `RitualHeader(listEyebrow/listTitle/listSubtitle)`; input (`listInputHint`) + gold `+` button; `RitualButton(listChooseButton)`; selected badge gradient (`listChosenByUniverse`); item rows (index dot, label, `×`); empty `listEmptyTwo`. Keep `listPickerProvider`.
- [ ] `flutter analyze`; commit.

### Task 8 — Tarot screen restyle
- [ ] `RitualHeader(tarotEyebrow/tarotTitle/tarotSubtitleShort)`; keep existing 3D flip + `_TarotCardFace` (already matches prototype closely — align copy: waiting `tarotWaiting`, `tarotTapReveal`); `RitualButton(tarotButton)`. Keep `tarotDrawProvider`.
- [ ] `flutter analyze`; commit.

### Task 9 — About screen + randomness sheet
- [ ] `RitualHeader(aboutEyebrow/navAboutMe)`; avatar+name+handle (GitHub), bio (fallback `aboutBioFallback`), github link chip, `aboutShortcutsTitle` + two gold-outline shortcut buttons, randomness card button → `showHowRandomnessSheet`.
- [ ] `how_randomness_sheet.dart`: eyebrow/title + 3 cards + `Entendi` button, matching prototype styles.
- [ ] `flutter analyze`; commit.

### Task 10 — l10n, tests, verification
- [ ] Add all new keys to `app_en.arb`/`app_pt.arb`; remove verified-unused; `flutter gen-l10n`.
- [ ] `test/widget_test.dart`: `setUp` sets `disableAnimations`; update nav labels (`Lista/Tarot/Sobre`, `Sobre`), coin pt button `Lançar a moeda`, dice/card/tarot button texts, any changed copy; keep behavior assertions (requests, results).
- [ ] `flutter test` all pass; `flutter analyze` clean; `dart format .`.
- [ ] Visual verification vs prototype (build/screenshot each tab + sheet).
- [ ] Commit; push; open PR (`Closes #16`, `Closes #17`) — no merge, no manual close.

---

## Self-Review

- **Spec coverage:** shell/background/runes/nav (T2–T3), coin #16/#17 (T4), dice/cards/lists/tarot/about (T5–T9), randomness sheet (T9), copy+tests (T10). ✔
- **Constraints:** no packages/engine; Random.org + controllers untouched; reduced motion; branch/PR discipline. ✔
- **Deviations documented:** dice physics/options, nav labels, About data source. ✔
- **Type consistency:** `RitualBackground(variant)`, `RitualHeader`, `RitualButton`, `RitualBottomNav`, `launchAuto()`, `_CoinFace`, `showHowRandomnessSheet` used consistently. ✔
