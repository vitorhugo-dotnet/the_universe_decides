# Google Play CI/CD

This repository publishes the Android Flutter app to Google Play testing tracks through `.github/workflows/android-play-deploy.yml`.

## Workflow behavior

- `push` to `master` runs the `CI/CD` workflow.
- `pull_request` to `master` runs analyze, tests, and Android build validation.
- Successful `push` runs on `master` publish the APK and AAB to this repository's GitHub Releases.
- After a successful `CI/CD` run on `master`, `.github/workflows/play-deploy-after-ci.yml` triggers Google Play deploys for:
  - `internal`: Google Play internal testing.
  - `closed`: Google Play closed testing through the `alpha` track.
- `push` with a tag matching `v*` uploads a signed Android App Bundle to Google Play internal testing.
- `workflow_dispatch` lets you manually choose either `internal` or `closed`.
- The workflow builds `build/app/outputs/bundle/release/app-release.aab` with `flutter build appbundle --release`.
- The Android `versionCode` is overridden with `github.run_number`, keeping Play uploads unique across CI runs.
- Metadata, images, screenshots, and changelogs are intentionally skipped. The workflow uploads only the binary.

## Google Play tracks

| Workflow target | Google Play track value | Play Console area |
| --- | --- | --- |
| `internal` | `internal` | Internal testing |
| `closed` | `alpha` | Closed testing |

If your Play Console closed testing track uses a custom track name instead of `alpha`, update `CLOSED_TESTING_PLAY_TRACK` in `.github/workflows/android-play-deploy.yml`.

## Required GitHub Actions secrets

Create these repository secrets under `Settings > Secrets and variables > Actions`:

| Secret | Purpose |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded Android upload keystore. |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password. |
| `ANDROID_KEY_ALIAS` | Upload key alias. |
| `ANDROID_KEY_PASSWORD` | Upload key password. |
| `PLAY_SERVICE_ACCOUNT_JSON` | Raw Google Play service account JSON credentials. |

## Keystore Base64 helper

PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\upload-keystore.jks")) | Set-Clipboard
```

Git Bash / Linux / macOS:

```sh
base64 -w 0 android/upload-keystore.jks
```

## Google Play setup checklist

1. Enable Play App Signing for the app.
2. Use the same upload key represented by `ANDROID_KEYSTORE_BASE64`.
3. Enable the Google Play Android Developer API in Google Cloud.
4. Create a service account JSON key.
5. Link/grant that service account access in Play Console with release permissions for this app.
6. Add the JSON content as `PLAY_SERVICE_ACCOUNT_JSON` in GitHub Actions secrets.
7. Ensure the package name is `com.hugo.theuniversedecides`.
8. Create/configure the internal testing track and tester list in Play Console.
9. Create/configure the closed testing track and tester list in Play Console.

## Safety notes

- Do not commit `android/key.properties`, `.jks`, or `.keystore` files.
- The default CI workflow can still build without signing secrets because `android/app/build.gradle.kts` falls back to the debug signing config when `android/key.properties` is missing.
- The Play deploy workflow fails early if any required secret is missing.
- Keep production deploy separate from testing deploys. Production should be a separate PR/workflow with explicit review.
