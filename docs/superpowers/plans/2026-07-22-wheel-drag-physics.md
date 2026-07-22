# Wheel Drag Physics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add circular drag and flick physics to the List Draw wheel without changing winner selection.

**Architecture:** Keep gesture mathematics pure in `wheel_geometry.dart`; keep transient gesture and animation state in `ListPickerWheelView`. Convert a bounded angular release velocity into visual spin duration and revolutions, then land on the winner returned by the existing controller.

**Tech Stack:** Flutter gestures and animations, Dart math, Riverpod, flutter_test.

## Global Constraints

- Preserve tap and button spin behavior.
- Winner selection must continue through `ListPickerController.spinWheel()`.
- Respect `MediaQuery.disableAnimationsOf(context)`.
- Add one short release-note entry under every locale in `CHANGELOG.md`.
- Add no runtime dependencies.

---

### Task 1: Pure angular gesture model

**Files:**
- Modify: `lib/controllers/wheel_geometry.dart`
- Test: `test/controllers/wheel_geometry_test.dart`

**Interfaces:**
- Produces: `wheelPointerPositionAngle`, `shortestAngularDelta`, and `computeWheelFlickProfile`.
- Consumes: pointer offsets and angular velocity in radians per second.

- [ ] **Step 1: Write failing geometry tests** for quarter turns, wrap-around, direction preservation, minimum flick rejection, and bounded duration/turn count.
- [ ] **Step 2: Run `flutter test test/controllers/wheel_geometry_test.dart`** and confirm failures are caused by missing helpers.
- [ ] **Step 3: Implement the minimal pure helpers and immutable `WheelFlickProfile`.**
- [ ] **Step 4: Re-run the focused tests** and confirm they pass.

### Task 2: Interactive wheel gesture

**Files:**
- Modify: `lib/screens/list_picker_wheel_view.dart`
- Test: `test/widgets/list_picker_wheel_view_test.dart`

**Interfaces:**
- Consumes: Task 1 geometry helpers and the existing `spinWheel()` controller API.
- Produces: circular drag-following and release-to-spin behavior.

- [ ] **Step 1: Write failing widget tests** proving a drag rotates the dial, a flick requests one winner, a weak drag does not request one, and reduced motion settles immediately.
- [ ] **Step 2: Run `flutter test test/widgets/list_picker_wheel_view_test.dart`** and confirm expected failures.
- [ ] **Step 3: Add keyed dial gesture handling, angular velocity sampling, and parameterized spin animation.**
- [ ] **Step 4: Re-run focused widget and geometry tests** and confirm they pass.

### Task 3: Release notes and full verification

**Files:**
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: the completed user-facing behavior.
- Produces: localized reusable release notes.

- [ ] **Step 1: Add a concise matching entry** in en, pt, es, de, fr, hi, it, tr, and uk.
- [ ] **Step 2: Run `dart format --output=none --set-exit-if-changed lib test`.**
- [ ] **Step 3: Run `flutter analyze`.**
- [ ] **Step 4: Run `flutter test`.**
- [ ] **Step 5: Review the final diff against the design and `CLAUDE.md`.**
