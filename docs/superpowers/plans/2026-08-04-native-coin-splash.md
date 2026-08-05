# Native Cosmic Coin Splash Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a native Android and iOS splash screen that transitions seamlessly into the dark Flutter interface using a centered purple coin mark.

**Architecture:** A transparent, safely padded PNG asset is the single visual source. `flutter_native_splash.yaml` declares the `#090611` background and image for Android, iOS, and Android 12+; its generator produces platform launch resources. Flutter's existing first-frame lifecycle removes the splash without new Dart initialization code.

**Tech Stack:** Flutter, Dart, `flutter_native_splash`, Android XML resources/themes, iOS asset catalog/storyboard.

## Global Constraints

- Use `#090611`, exactly matching `AppColors.scaffoldBackground`.
- The mark is a purple coin with a duality symbol and restrained static purple glow; it contains no text.
- Do not add a timer, native animation, remote load, or route change.
- Configure the dedicated `android_12` section explicitly and preserve enough transparent image padding for Android 12 masking.
- Preserve the build number `100142`; bump only the semantic version name to `2.6.0`.
- Replace, rather than append to, `CHANGELOG.xml`, retaining all existing supported locale blocks.
- Do not alter `.superpowers/brainstorm/`; it is local brainstorming state, not application source.

---

### Task 1: Create the purple coin splash source asset

**Files:**
- Create: `assets/splash/cosmic_coin_splash.png`
- Verify: `assets/splash/cosmic_coin_splash.png`

**Interfaces:**
- Consumes: visual decision from `docs/superpowers/specs/2026-08-04-native-coin-splash-design.md`.
- Produces: a square transparent PNG used as `image` and `android_12.image` by `flutter_native_splash.yaml`.

- [ ] **Step 1: Create the source illustration**

Create a square PNG with a transparent outer region, a centrally aligned purple coin, a simple light duality glyph, and a soft static purple glow. Keep all visible artwork well inside the central safe region so Android 12 can mask it without clipping.

- [ ] **Step 2: Verify the asset geometry and transparency**

Run: inspect the PNG dimensions and alpha channel using the available image tooling.

Expected: the canvas is square; no text is present; visible artwork is centered with substantial transparent padding.

- [ ] **Step 3: Commit the source asset**

```powershell
git add -- assets/splash/cosmic_coin_splash.png
git commit -m "feat: add cosmic coin splash asset"
```

### Task 2: Configure and generate native splash resources

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Create: `flutter_native_splash.yaml`
- Modify: generated Android launch resources beneath `android/app/src/main/res/`
- Modify: generated iOS launch resources beneath `ios/Runner/`

**Interfaces:**
- Consumes: `assets/splash/cosmic_coin_splash.png` from Task 1.
- Produces: generated native launch screens for Android (including Android 12+) and iOS.

- [ ] **Step 1: Add the generator dependency**

Add `flutter_native_splash` as a development dependency at its current stable compatible version, then resolve packages:

```powershell
flutter pub get
```

Expected: `pubspec.lock` resolves the package without changing unrelated dependency constraints.

- [ ] **Step 2: Add the canonical splash configuration**

Create `flutter_native_splash.yaml` with these values:

```yaml
flutter_native_splash:
  color: "#090611"
  image: assets/splash/cosmic_coin_splash.png
  android: true
  ios: true
  android_12:
    color: "#090611"
    image: assets/splash/cosmic_coin_splash.png
```

- [ ] **Step 3: Generate platform resources**

Run:

```powershell
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

Expected: Android themes/drawables and iOS launch assets/storyboard use the cosmic background and coin image; no manual alternative implementation is added.

- [ ] **Step 4: Inspect generated outputs**

Check the Android launch theme and Android 12 splash values, then the iOS launch storyboard/assets.

Expected: all launch backgrounds resolve to `#090611`; launch images resolve to generated coin assets; the previous white background is absent from the default launch path.

- [ ] **Step 5: Commit configuration and generated resources**

```powershell
git add -- pubspec.yaml pubspec.lock flutter_native_splash.yaml android ios
git commit -m "feat: configure native cosmic splash"
```

### Task 3: Record the user-visible release update

**Files:**
- Modify: `pubspec.yaml`
- Modify: `CHANGELOG.xml`

**Interfaces:**
- Consumes: generated native splash from Task 2.
- Produces: semantic version `2.6.0+100142` and Google Play-ready localized release notes.

- [ ] **Step 1: Set the semantic version**

Change the `pubspec.yaml` version line exactly to:

```yaml
version: 2.6.0+100142
```

- [ ] **Step 2: Replace localized release notes**

Replace all prior `CHANGELOG.xml` content with one localized bullet in each existing locale block describing the new native cosmic splash with the purple coin and dark background. Keep exactly these locale tags: `en-US`, `pt-BR`, `es-ES`, `de`, `fr-FR`, `hi`, `it`, `tr`, and `uk`.

- [ ] **Step 3: Validate changelog structure**

Run a targeted XML parse/structure check and confirm the nine locale blocks occur exactly once.

Expected: no old release notes remain and every supported release-note language has the new feature text.

- [ ] **Step 4: Commit the release metadata**

```powershell
git add -- pubspec.yaml CHANGELOG.xml
git commit -m "feat: document cosmic splash release"
```

### Task 4: Validate generated feature behavior

**Files:**
- Verify: `flutter_native_splash.yaml`
- Verify: `android/app/src/main/res/`
- Verify: `ios/Runner/`
- Verify: `pubspec.yaml`
- Verify: `CHANGELOG.xml`

**Interfaces:**
- Consumes: completed Tasks 1–3.
- Produces: evidence that static and Flutter validation passes without a delayed app startup.

- [ ] **Step 1: Run static analysis**

Run:

```powershell
flutter analyze
```

Expected: exit code 0.

- [ ] **Step 2: Run the focused startup-route regression test**

Run:

```powershell
flutter test test/quick_coin_route_test.dart
```

Expected: exit code 0, confirming that the existing primary and Quick Settings startup routes remain intact without adding startup logic.

- [ ] **Step 3: Review the final diff**

Run:

```powershell
git diff HEAD~3..HEAD --check
git status --short
```

Expected: no whitespace errors; only intended splash, dependency, version, changelog, and generated platform files are tracked; `.superpowers/brainstorm/` remains untracked and excluded.

- [ ] **Step 4: Perform manual platform checks when available**

Launch on Android 12+, a supported pre-12 Android device/emulator, and iOS simulator/device. Check cold and warm starts in both device themes.

Expected: the coin is centered and uncut, no white/other-color flash occurs before Flutter renders, and no perceptible artificial delay exists.
