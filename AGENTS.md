# AGENTS.md

Repository-wide instructions for coding agents working on **The Universe Decides**.

## CI trigger policy

The Flutter `CI/CD` workflow must run only when a change can affect analysis, tests, or the Android build.

Current CI-relevant paths:

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

Do not make documentation-only changes trigger Flutter CI. This includes changes limited to `README.md`, `docs/**`, `CHANGELOG.xml`, agent instructions, or unrelated YAML files.

When adding a new file or directory that becomes an input to `flutter analyze`, `flutter test`, code generation, or the Android build, update the `paths` filters in `.github/workflows/build-signed-apk.yml` and document the new input in `README.md`.

CI execution does not always mean release publication. Changes limited to tests, analysis configuration, or workflow files must run validation without creating a GitHub/F-Droid/Google Play release.

## Release versioning

Keep the semantic version name in `pubspec.yaml` under manual control:

```yaml
version: <major>.<minor>.<patch>+<buildNumber>
```

For a new semantic release, change only `<major>.<minor>.<patch>`. Do not manually increment `<buildNumber>`.

The `CI/CD` workflow is the single source of the Android build number. It chooses a value greater than the current `pubspec.yaml` build number and the latest stable release tag, while retaining the `100000 + GITHUB_RUN_NUMBER` baseline.

After analyze, tests, and Android builds pass for an application change on `master`, CI must:

1. persist the resolved version in `pubspec.yaml`;
2. commit it to `master` using `GITHUB_TOKEN`;
3. create the release tag on that exact version commit;
4. publish GitHub Release artifacts;
5. call `.github/workflows/android-play-deploy.yml` with the same version name, build number, and release commit.

The automatic version commit must use `GITHUB_TOKEN` so it does not recursively trigger another workflow run.

## Release and F-Droid procedure

F-Droid does not publish arbitrary commits from `master`. The upstream metadata checks stable Git tags matching:

```text
v<major>.<minor>.<patch>+<versionCode>
```

For a new application release:

1. Update the semantic version name in `pubspec.yaml` when required and add release notes to `CHANGELOG.xml`.
2. Merge or push the application change to `master`.
3. Wait for the `CI/CD` workflow to pass.
4. The workflow assigns and persists the Android build number, then creates the matching GitHub release tag automatically. Do not create a duplicate manual tag.
5. F-Droid detects that tag during its update cycle and builds the `fdroid` flavor from source. It does not consume the APK attached to the GitHub Release.
6. Check the upstream F-Droid build status after the next update cycle.

Documentation, tests, analysis configuration, and workflow-only commits must not create a release tag or request a new F-Droid version.

Keep `fdroid/com.hugo.theuniversedecides.yml` synchronized with the accepted metadata in `fdroid/fdroiddata` whenever upstream metadata changes.

## Changelog

Follow the localization and Google Play release-note requirements in `.claude/CLAUDE.md`. Keep `CHANGELOG.xml` as the single source of truth for release notes.

For every user-visible `feat`, `fix`, or `refactor`, replace the entire previous content of `CHANGELOG.xml` with notes for the new change. Never append the new notes to older release notes. The file must remain directly copyable into the Google Play Console production release notes field.

When publishing a GitHub Release, convert the locale blocks from `CHANGELOG.xml` to Markdown headings and preserve the localized bullet text. Do not maintain a second hand-written changelog.
