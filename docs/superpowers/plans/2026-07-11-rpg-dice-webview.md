# RPG Dice WebView Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the static dice animation with prototype-matched, transparent, offline Three.js/Cannon.js dice whose outcomes are chosen by Flutter.

**Architecture:** Flutter owns request generation, loading, outcome persistence, UI, and timeout recovery. A reusable WebView bridge owns the local renderer and exchanges correlated JSON messages; adapted prototype JavaScript provides physics and settling.

**Tech Stack:** Flutter, Riverpod, `webview_flutter`, local HTML/JavaScript, Three.js, Cannon.js, Flutter tests.

## Global Constraints

- Use the supplied ZIP as visual source of truth and do not alter other screens.
- Bundle JavaScript locally; Flutter remains the only random-result authority.
- Preserve transparent WebView/WebGL rendering and valid random results on animation failure.
- Test first, then run the requested Flutter validation commands.

---

### Task 1: Define bridge and roll-state domain

**Files:**
- Create: `lib/dice/dice_roll_request.dart`
- Create: `lib/dice/dice_bridge_message.dart`
- Test: `test/dice/dice_roll_request_test.dart`
- Test: `test/dice/dice_bridge_message_test.dart`

**Interfaces:**
- Produces `DiceRollRequest.toJson()` with `requestId`, `notation`, and `results`.
- Produces `DiceBridgeMessage.parse(String)` returning a validated message or `null`.

- [ ] Write failing tests for JSON request serialization, valid `rollCompleted`, malformed JSON, unknown event types, and missing request IDs.
- [ ] Run `flutter test test/dice/dice_roll_request_test.dart test/dice/dice_bridge_message_test.dart`; expect failures because the domain files do not exist.
- [ ] Implement immutable request/message classes with typed event enums and strict JSON validation.
- [ ] Re-run the focused tests; expect all assertions to pass.
- [ ] Commit the domain contract and tests.

### Task 2: Add the focused transparent WebView component

**Files:**
- Create: `lib/dice/dice_web_view.dart`
- Modify: `pubspec.yaml`
- Create: `assets/dice/index.html`
- Create: `assets/dice/bridge.js`
- Create: `assets/dice/LICENSE`
- Test: `test/dice/dice_web_view_test.dart`

**Interfaces:**
- `DiceWebView` receives bridge messages and exposes a controller capable of `roll`, `pause`, and `resume`.

- [ ] Write failing tests for ignored invalid/stale bridge messages and a no-op roll before ready.
- [ ] Run the focused test; expect it to fail before bridge dispatch exists.
- [ ] Add `webview_flutter`, asset registration, transparent controller configuration, channel parsing, disabled interaction/navigation, and one-time local asset initialization.
- [ ] Add transparent HTML/CSS and a minimal bridge that validates roll input and emits JSON events.
- [ ] Re-run focused tests and commit.

### Task 3: Bundle and adapt the prototype physics engine

**Files:**
- Create: `assets/dice/dice.js`
- Create: `assets/dice/libs/three.min.js`
- Create: `assets/dice/libs/cannon.min.js`
- Create: `assets/dice/libs/teal.js`
- Modify: `assets/dice/index.html`
- Modify: `assets/dice/bridge.js`

- [ ] Copy the prototype MIT-attributed engine and libraries into local assets without CDN substitutions.
- [ ] Remove visible desk geometry, retain invisible Cannon floor/barriers, and force alpha renderer/transparent clearing.
- [ ] Adapt purple/gold/lavender visual settings and force supplied faces after the physical throw.
- [ ] Stop frames after settling and handle resize, pause, resume, and one active request.
- [ ] Inspect local assets for external URLs and commit.

### Task 4: Refactor controller for resilient roll orchestration

**Files:**
- Modify: `lib/controllers/dice_roll_controller.dart`
- Test: `test/controllers/dice_roll_controller_test.dart`

**Interfaces:**
- State adds `isFetching`, `isRolling`, `activeRequestId`, `animationError`, and `total`; `isBusy` is true while either operation is active.
- `startRoll()` gets values once; completion, failure, and timeout methods preserve values and clear only the active rolling lock.

- [ ] Write failing controller tests for single active request, total calculation, stale completion rejection, timeout release, and animation failure retaining values.
- [ ] Run the controller test; expect failures due to missing transitions.
- [ ] Implement explicit request generation and transitions using the existing RandomOrg service provider.
- [ ] Re-run controller tests and commit.

### Task 5: Rebuild only the dice screen to the prototype

**Files:**
- Modify: `lib/screens/dice_roll_screen.dart`
- Modify: `lib/theme/app_colors.dart` only if a shared prototype color token is absent
- Test: `test/dice_roll_screen_test.dart`

**Interfaces:**
- The screen embeds one `DiceWebView` in the prototype animation region and sends only controller-created requests.

- [ ] Write failing widget tests for disabled controls while fetching/rolling and result display after completion/failure.
- [ ] Run the widget test; expect failure because the old Material-card layout remains.
- [ ] Replace the old card/tumbling grid with the prototype hierarchy and styling while retaining native accessible Flutter controls and results.
- [ ] Connect lifecycle visibility, bridge callbacks, fallback snackbar, and bounded animation timeout.
- [ ] Re-run widget tests and commit.

### Task 6: Format and verify

**Files:**
- Modify only files changed by Tasks 1–5.

- [ ] Run `flutter pub get`.
- [ ] Run `dart format .`.
- [ ] Run `flutter analyze`; resolve every feature-introduced error.
- [ ] Run `flutter test`; resolve every feature-introduced failure.
- [ ] Inspect `git diff --check` and changed files, then commit the verified integration.
