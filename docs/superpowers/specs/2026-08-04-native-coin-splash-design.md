# Native Cosmic Coin Splash Design

## Goal

Replace the default white Flutter launch screens with a native splash that visually continues into The Universe Decides. The splash uses the application background (`#090611`) and a centered, dedicated purple coin mark representing the app's default coin-flip experience.

## Scope

- Add `flutter_native_splash` at a stable version compatible with the current Flutter project.
- Add a dedicated `flutter_native_splash.yaml` configuration file.
- Add a square PNG splash asset with transparency and generous safe padding.
- Generate Android and iOS splash resources from that configuration.
- Set the common and Android 12+ splash backgrounds to `#090611`.
- Update the semantic version name from `2.5.2+100142` to `2.6.0+100142`; retain build number `100142`.
- Replace `CHANGELOG.xml` with localized release notes for this feature.

## Visual Design

The mark is a minimal purple coin with a clear duality symbol, evoking "heads or tails" without relying on text. It is centered on a solid `#090611` field and includes a restrained static purple glow. No animation, wordmark, localized text, constellations, or secondary symbols are included.

The source PNG contains the glow and transparent outer padding. This keeps the generated Android and iOS resources consistent and protects the focal artwork from density scaling and the Android 12 splash icon mask.

## Architecture and Data Flow

`flutter_native_splash.yaml` is the single editable source of native splash settings. It points to the coin PNG and sets `#090611` as the background for the normal Android/iOS splash and the Android 12+ section. Running the package generator produces platform-specific resource files under `android/` and `ios/`.

At launch, the operating system shows the generated native splash. Flutter renders the existing `UniverseDecidesApp` with `AppColors.scaffoldBackground` (`#090611`), and the embedding removes the splash at the first Flutter frame. No Dart initialization, timer, route, or network request is added.

## Platform Behavior

- Android versions below 12 use the generated launch background and centered asset.
- Android 12+ uses the generated `android_12` configuration, which follows the system splash API and may mask the icon within its documented safe area.
- iOS uses generated launch assets and the same solid background with the centered mark.
- Both light and dark device modes receive the same deliberately dark launch design.

## Error Handling

The splash does not add runtime failure paths. If asset generation fails during development or CI, fix the YAML, asset path, or package compatibility and regenerate; do not add a Dart fallback or manual duplicate platform implementation. The existing Flutter first-frame lifecycle remains authoritative for removing the splash.

## Validation

1. Run the splash generator after configuration and asset changes.
2. Run `flutter analyze` and the smallest relevant Flutter test command.
3. Inspect generated Android and iOS launch resources for the intended background and image references.
4. Manually validate cold and warm starts on Android 12+, a supported pre-12 Android version, and iOS when devices/simulators are available. Check light/dark device modes, multiple densities, no white flash, centered uncut artwork, and no perceptible delay.

## Non-Goals

- No video, GIF, Lottie, or native splash animation.
- No artificial minimum splash duration.
- No remote data loading or changes to the initial route.
- No text, tips, or other localized splash content.

## Files Expected to Change

- `pubspec.yaml` and `pubspec.lock`
- `flutter_native_splash.yaml`
- a new splash PNG under `assets/`
- generated Android launch resources and themes under `android/`
- generated iOS launch resources/storyboard assets under `ios/`
- `CHANGELOG.xml`
- this design document
