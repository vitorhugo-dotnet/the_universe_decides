# AGENTS.md

Repository-wide instructions for coding agents working on **The Universe Decides**.

## CI trigger policy

The Flutter `CI/CD` workflow must run only when a change can affect analysis, tests, the Android build, or the published web build.

Current CI-relevant paths:

- `.github/workflows/build-signed-apk.yml`
- `.github/workflows/deploy-web.yml`
- `lib/**`
- `test/**`
- `integration_test/**`
- `android/**`
- `web/**`
- `assets/**`
- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `l10n.yaml`

Do not make documentation-only changes trigger Flutter CI. This includes changes limited to `README.md`, `docs/**`, `CHANGELOG.xml`, agent instructions, or unrelated YAML files.

When adding a new file or directory that becomes an input to `flutter analyze`, `flutter test`, code generation, or the Android build, update the `paths` filters in `.github/workflows/build-signed-apk.yml` and document the new input in `README.md`.

CI execution does not always mean release publication. Changes limited to tests, analysis configuration, or workflow files must run validation without creating a GitHub/F-Droid/Google Play release.

## Web deploy trigger policy

`.github/workflows/deploy-web.yml` publishes the Flutter Web build to GitHub Pages. It carries no trigger of its own beyond `workflow_dispatch`: `CI/CD` owns the schedule and calls it through `workflow_call`, so the site is always published from a commit that `flutter analyze` and `flutter test` already passed on. Keep these properties:

- The `deploy-web` job in `CI/CD` needs `analyze` and `test`, and it runs only for a push to `master`. Never let it publish ahead of validation.
- Nothing may `needs:` the `deploy-web` job. A GitHub Pages outage must leave the Play APK, the Play AAB, the F-Droid APK, the GitHub Release and the Play deployment free to run. The web deploy fails the run without blocking a release.
- `web/**` is a `CI/CD` input because `test/web/` asserts on `web/index.html`, `web/manifest.json` and `web/flutter_bootstrap.js`, and because the site is published from this pipeline. It is not an Android input, so the `version` job resolves `android_relevant` and `build-android` is gated on it: a change confined to `web/**` and `.github/workflows/deploy-web.yml` never builds an APK and never creates a release tag.
- `android_relevant` answers "did anything outside the browser bundle change", not "did an Android path change". Keep it that way, so a path nobody classified keeps the Android builds running instead of silently skipping them.
- Do not add `android/**` to the web workflow, and do not give it a `push` trigger. Two entry points would publish the same commit twice.
- A direct `workflow_dispatch` has no caller to vouch for the commit, so it runs analyze and tests itself. Only a caller that already ran both may pass `validated: true`.
- Documentation-only changes must not redeploy the site.
- The web workflow reads its Flutter version from the `FLUTTER_VERSION` declaration in `build-signed-apk.yml`. That declaration stays the single source of truth, because the F-Droid metadata parses the same line.
- The deploy job depends on the build job, so a failing build must never replace the published site.

Shared Dart code must compile for Android, iOS, and the browser. Never import `dart:io` from `lib/**`; use `kIsWeb` with `defaultTargetPlatform`, or a conditional import, and keep `dart:js_interop`, `dart:ui_web`, and `package:web` behind the conditional import in `lib/dice/dice_web_view.dart`. `test/web/web_compilation_path_test.dart` enforces both directions.

## Release versioning

Keep the semantic version name in `pubspec.yaml` under manual control:

```yaml
version: <major>.<minor>.<patch>+<buildNumber>
```

Before finishing any application `feat`, `fix`, or `refactor`, increment the semantic version name exactly once according to Semantic Versioning:

- `MAJOR`: incompatible or breaking application changes.
- `MINOR`: backward-compatible features or new user-facing capabilities.
- `PATCH`: backward-compatible fixes, refactors, performance improvements, or internal application changes.

When a change fits more than one category, use the highest applicable level. Reset the lower components normally: `MAJOR` resets `MINOR` and `PATCH` to `0`; `MINOR` resets `PATCH` to `0`.

Change only `<major>.<minor>.<patch>`. Preserve `<buildNumber>` exactly as it is and never increment it manually. For example:

```text
1.4.2+100037 -> 1.5.0+100037  # feature
1.4.2+100037 -> 1.4.3+100037  # fix/refactor
1.4.2+100037 -> 2.0.0+100037  # breaking change
```

Do not increment the semantic version for documentation-only, test-only, CI/workflow-only, changelog-only, or agent-instruction-only changes that do not modify the application.

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

1. Increment the semantic version name in `pubspec.yaml` according to the rules above and add release notes to `CHANGELOG.xml`.
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
