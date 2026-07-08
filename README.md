# The Universe Decides 🌌

The Universe Decides is a Flutter decision app with a dark mystical Material 3 interface. It uses Random.org whenever possible and silently falls back to local randomness when the network is unavailable.

## Included in this app

- Coin flip screen with animated tosses
- RPG dice roller with configurable quantities and polyhedral sides
- Card draw screen with a full 52-card deck
- Custom list picker with highlighted winners
- Consistent app naming for Android and iOS
- Unique application identifier: `com.hugo.theuniversedecides`
- Release signing support through `android/key.properties`
- Custom launcher icons for Android and iOS

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

On every push to `master`, the workflow publishes:

- `the-universe-decides-v<version>+<versionCode>.apk`
- `the-universe-decides-v<version>+<versionCode>.aab`

The repository also includes Google Play deployment workflows:

- `.github/workflows/android-play-deploy.yml`: builds and uploads a signed AAB to Google Play.
- `.github/workflows/play-deploy-after-ci.yml`: triggers Play deploy after successful `CI/CD` runs on `master`.

Supported Play targets:

- `internal`: Google Play internal testing.
- `closed`: Google Play closed testing through the `alpha` track.

See [`docs/google-play-cicd.md`](docs/google-play-cicd.md) for setup details, required secrets, and track behavior.

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

The repository now includes branded launcher icons. If you want to regenerate them later, use the same source artwork with either:

- [App Icon Forge](https://www.appicon.co/)
- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
