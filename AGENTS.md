# AGENTS.md

Repository-wide instructions for coding agents working on **The Universe Decides**.

## CI trigger policy

The Flutter `CI/CD` workflow must run only when a change can affect analysis, tests, or the Android build.

Current build-relevant paths:

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

Do not make documentation-only changes trigger Flutter CI. This includes changes limited to `README.md`, `docs/**`, `CHANGELOG.md`, agent instructions, or unrelated YAML files.

When adding a new file or directory that becomes an input to `flutter analyze`, `flutter test`, code generation, or the Android build, update the `paths` filters in `.github/workflows/build-signed-apk.yml` and document the new input in `README.md`.

## Release and F-Droid procedure

F-Droid does not publish arbitrary commits from `master`. The upstream metadata checks Git tags matching:

```text
v<major>.<minor>.<patch>+<versionCode>
```

For a new application release:

1. Update `version:` in `pubspec.yaml` and add release notes to `CHANGELOG.md`.
2. Merge or push the build-relevant release change to `master`.
3. Wait for the `CI/CD` workflow to pass.
4. The workflow assigns the Android version code and creates the matching GitHub release tag automatically. Do not create a duplicate manual tag when CI succeeds.
5. F-Droid detects that tag during its update cycle and builds the `fdroid` flavor from source. It does not consume the APK attached to the GitHub Release.
6. Check the upstream F-Droid build status after the next update cycle.

A documentation-only commit must not create a release tag or request a new F-Droid version.

## Changelog

Follow the localization and Google Play release-note requirements in `.claude/CLAUDE.md`. Keep `CHANGELOG.md` as the single source of truth for release notes.
