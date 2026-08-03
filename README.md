# The Universe Decides 🌌

> **Can't decide? Let the universe choose.**

The Universe Decides is a decision app for the moments when you want chance to make the final call. Flip a coin, roll RPG dice, draw cards, spin a wheel, or choose from your own list without turning a simple decision into a committee meeting.

Whenever possible, the app obtains results from [RANDOM.ORG](https://www.random.org/), an external service that generates randomness from atmospheric noise. When that service cannot provide a valid result, the app remains usable with local randomness and clearly warns the user that the fallback was used.

## What can it decide?

- Flip a coin with an animated toss
- Roll configurable polyhedral RPG dice
- Draw from a complete 52-card deck
- Draw tarot cards
- Pick an item from a custom list
- Spin a wheel using the items from a custom list
- Review and clear recent results
- Access selected actions from Android quick settings

Common uses include choosing what to eat or watch, settling friendly disagreements, selecting a player or activity, supporting tabletop RPG sessions, and running small transparent draws.

## How randomness works

1. The app requests random integers from RANDOM.ORG.
2. When RANDOM.ORG returns a valid response, that result is used by the decision feature.
3. Local pseudo-randomness is used only when RANDOM.ORG cannot provide a valid response, including situations such as:
   - RANDOM.ORG being unavailable;
   - the device being offline or experiencing a network failure;
   - the request timing out;
   - the IP-based RANDOM.ORG quota or rate limit being reached.
4. Whenever local randomness is used, the app displays a visible fallback warning.

The local fallback keeps decisions available when the external service cannot be reached. It is never presented to the user as a RANDOM.ORG result.

## Built with

- Flutter
- Material 3
- Riverpod
- RANDOM.ORG HTTP integer interface

Application identifier: `com.hugo.theuniversedecides`

## Download

- [Google Play](https://play.google.com/store/apps/details?id=com.hugo.theuniversedecides)
- [F-Droid](https://f-droid.org/packages/com.hugo.theuniversedecides)

## Android release signing

1. Generate a keystore and keep it somewhere safe.
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Fill in the real values and keep both the keystore file and passwords out of source control.

Example:

```properties
storePassword=replace-me
keyPassword=replace-me
keyAlias=upload
storeFile=upload-keystore.jks
```

When `android/key.properties` is present, release builds use that keystore automatically. Otherwise, the project falls back to the debug signing config for local-only release runs.

## GitHub Actions CI/CD

The repository includes `.github/workflows/build-signed-apk.yml`, named `CI/CD`, to run Flutter analyze, tests, Android release APK/AAB builds, and GitHub Release publishing.

The workflow runs only when a pull request or push to `master` changes a build-relevant path:

- `.github/workflows/build-signed-apk.yml`
- `lib/**`
- `test/**`
- `integration_test/**`
- `android/**`
- `assets/**`
- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `l10n.yaml`

Documentation-only changes, including changes limited to `README.md`, `docs/**`, `CHANGELOG.md`, or unrelated YAML files, do not trigger the Flutter CI/CD workflow. When a new file becomes an input to analysis, tests, or Android builds, add its path to the workflow filter.

Pull requests run analyze, tests, and Android flavor builds. GitHub Releases and Google Play deploys run only after a successful build-relevant `push` to `master`.

Each successful release run publishes:

- `the-universe-decides-v<version>+<versionCode>-play.apk`
- `the-universe-decides-v<version>+<versionCode>-fdroid.apk`
- `the-universe-decides-v<version>+<versionCode>.aab`

The repository also includes Google Play deployment workflows:

- `.github/workflows/android-play-deploy.yml`: builds and uploads a signed AAB to the Google Play open-testing `beta` track. It accepts manual dispatches on `master`.
- `.github/workflows/play-deploy-after-ci.yml`: automatically dispatches the Play deployment after a successful `CI/CD` push run on `master`.

See [`docs/google-play-cicd.md`](docs/google-play-cicd.md) for setup details and required secrets.

## Publishing an update to F-Droid

F-Droid does not publish every commit pushed to `master`. Its metadata watches release tags matching `v<major>.<minor>.<patch>+<versionCode>`.

Release procedure:

1. Update the application version in `pubspec.yaml` and update `CHANGELOG.md`.
2. Merge or push the build-relevant release changes to `master`.
3. Wait for the `CI/CD` workflow to pass. It assigns the Android version code and creates a GitHub tag such as `v2.5.1+100118`; no separate manual tag is needed when this workflow succeeds.
4. F-Droid detects the new matching tag during its update cycle and builds the `fdroid` flavor from source. It does not install or redistribute the APK attached to the GitHub Release.
5. Check the upstream F-Droid build status after its next update cycle.

A documentation-only push will not create a release tag and therefore will not request a new F-Droid version.

## Required Android signing secrets

Configure these repository secrets before running Play deploy or signed release workflows:

- `ANDROID_KEYSTORE_BASE64`: base64-encoded contents of your `.jks` or `.keystore` file
- `ANDROID_KEYSTORE_PASSWORD`: keystore password
- `ANDROID_KEY_ALIAS`: key alias inside the keystore
- `ANDROID_KEY_PASSWORD`: key password
- `PLAY_SERVICE_ACCOUNT_JSON`: raw Google Play service account JSON credentials

Example command to prepare the keystore secret value:

```bash
base64 -w 0 android/upload-keystore.jks
```

## Icon workflow

The repository includes branded launcher icons. To regenerate them later, use the same source artwork with either:

- [App Icon Forge](https://www.appicon.co/)
- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
