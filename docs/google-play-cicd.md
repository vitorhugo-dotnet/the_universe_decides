# Google Play CI/CD

This repository publishes the Android Flutter app to the Google Play open-testing `beta` track through `.github/workflows/android-play-deploy.yml`.

## Workflow behavior

- Pull requests to `master` run analyze, tests, and Android flavor builds without publishing.
- Pushes to `master` run the same validation when a CI-relevant path changes.
- A release is created only when the push changes application inputs under `lib/**`, `android/**`, `assets/**`, `pubspec.yaml`, `pubspec.lock`, or `l10n.yaml`.
- Changes limited to tests, analysis configuration, documentation, or workflow files do not publish a GitHub Release, F-Droid tag, or Google Play build.
- `.github/workflows/build-signed-apk.yml` resolves one version name and build number for the entire release.
- After validation succeeds, the workflow writes the resolved version back to `pubspec.yaml`, commits it to `master`, and creates the release tag on that exact commit.
- `.github/workflows/android-play-deploy.yml` is a reusable workflow called by `CI/CD` after the GitHub Release is published. It also supports manual `workflow_dispatch` execution.
- The Play workflow checks out the persisted release commit and verifies that `pubspec.yaml` matches the supplied `versionName+versionCode` before building.
- The signed AAB is built with explicit `--build-name` and `--build-number` arguments and uploaded to the `beta` track.
- Metadata, images, screenshots, and Google Play changelogs are intentionally skipped. The workflow uploads only the binary; Play Store "What's new" text remains sourced from `CHANGELOG.md`.

## Version calculation

The semantic version name is manually controlled in `pubspec.yaml`:

```yaml
version: 2.6.0+100129
```

Before a semantic release, update only `2.6.0`. The CI/CD workflow calculates the build number after `+` using the greatest safe next value from:

1. `100000 + GITHUB_RUN_NUMBER`;
2. the current `pubspec.yaml` build number plus one;
3. the latest stable release tag build number plus one.

This keeps the Android `versionCode` monotonic even if the workflow run counter or the persisted file falls behind. The same base build number is used by GitHub Release, Google Play, and the F-Droid release tag. F-Droid derives ABI-specific codes from that base through its upstream `VercodeOperation` metadata.

## Persisted version commit

The release workflow commits the calculated version to `pubspec.yaml` only after analyze, tests, and Android builds pass. The commit is pushed using the repository `GITHUB_TOKEN`, which prevents the write-back from recursively starting another push workflow.

The release tag is created on the persisted version commit, not on the original source commit. The reusable Play workflow receives that exact commit SHA and refuses to deploy when the checked-out `pubspec.yaml` version differs from the supplied release version.

## GitHub Release changelog

`CHANGELOG.md` at the repository root has one `## Unreleased` section with a subsection per locale the app supports. The release job extracts everything between `## Unreleased` and the next `## ` heading, or the end of the file, and uses it as the GitHub Release description.

When that section is empty, the workflow falls back to a short pointer to `CHANGELOG.md`.

The workflow currently does not rotate `## Unreleased` into a dated/versioned heading. After a release, a maintainer should rename it to the released tag and create a new empty `## Unreleased` section.

## Google Play track

| Workflow | Google Play track | Play Console area |
| --- | --- | --- |
| `android-play-deploy.yml` | `beta` | Open testing |

Production deployment remains intentionally separate and requires an explicit future workflow/review process.

## Manual deployment

`android-play-deploy.yml` can be manually dispatched with:

- `version_name`: semantic version name, such as `2.6.0`;
- `version_code`: persisted Android build number, such as `100130`;
- `source_ref`: branch, tag, or commit containing exactly `version: 2.6.0+100130` in `pubspec.yaml`.

The workflow fails before building when the source reference does not contain the expected persisted version.

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
5. Link the service account in Play Console and grant release permissions for this app.
6. Add the JSON content as `PLAY_SERVICE_ACCOUNT_JSON` in GitHub Actions secrets.
7. Ensure the package name is `com.hugo.theuniversedecides`.
8. Configure the open-testing `beta` track.

## Safety notes

- Do not commit `android/key.properties`, `.jks`, or `.keystore` files.
- The default CI workflow can build without signing secrets because `android/app/build.gradle.kts` falls back to the debug signing config when `android/key.properties` is missing.
- The Play deployment workflow fails early if any required secret is missing.
- Keep production deployment separate from testing deployment.
