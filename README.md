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
- Access selected actions from Android quick settings (Android only)

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

## Use it

- **Open in your browser:** <https://coin.hugojava.dev/> — no install required
- [Google Play](https://play.google.com/store/apps/details?id=com.hugo.theuniversedecides)
- [F-Droid](https://f-droid.org/packages/com.hugo.theuniversedecides)

The browser build runs the same code as the Android app. Android-only
integrations degrade instead of breaking: Quick Settings shortcuts and Play
Games leaderboards are hidden, and everything else — coin, dice, cards, tarot,
lists, wheel, recent history and the RANDOM.ORG fallback warning — works the
same way. Recent results are stored in the browser, so they survive a reload
but do not sync with the installed app.

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

The repository includes `.github/workflows/build-signed-apk.yml`, named `CI/CD`, to run Flutter analyze, tests, Android release APK/AAB builds, release versioning, and GitHub Release publishing.

The workflow runs only when a pull request or push to `master` changes a CI-relevant path:

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
- `flutter_native_splash.yaml`

Documentation-only changes, including changes limited to `README.md`, `docs/**`, `CHANGELOG.xml`, or unrelated YAML files, do not trigger the Flutter CI/CD workflow. When a new file becomes an input to analysis, tests, or Android builds, add its path to the workflow filter.

Pull requests and CI-only changes run validation and Android flavor builds without publishing. A release is created only when a successful push to `master` changes application inputs under `lib/**`, `android/**`, `assets/**`, `pubspec.yaml`, `pubspec.lock`, or `l10n.yaml`.

## GitHub Pages web deploy

`.github/workflows/deploy-web.yml`, named `Deploy Web`, publishes the Flutter
Web build to <https://coin.hugojava.dev/>, the app's public address. It is
deliberately separate from `CI/CD`: the Android release pipeline owns
versioning, tagging, Play and F-Droid, and must not depend on the browser
build.

The workflow runs on `workflow_dispatch` and on pushes to `master` that change:

- `.github/workflows/deploy-web.yml`
- `lib/**`
- `test/**`
- `web/**`
- `assets/**`
- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `l10n.yaml`

`android/**`, `docs/**`, `README.md` and `CHANGELOG.xml` are intentionally
absent: Android-only and documentation-only changes never redeploy the site.
Conversely `web/**` is not a `CI/CD` input, so browser-only changes never build
an APK or create a release.

It runs `flutter analyze`, `flutter test` and `flutter build web --release`
before uploading `build/web`; the deploy job needs the build job, so a failure
at any step leaves the previously published site untouched. The Flutter version
is read from the `FLUTTER_VERSION` declaration in `build-signed-apk.yml`, which
is the single source of truth shared with F-Droid.

The `--base-href` argument is **not** hardcoded. `actions/configure-pages`
reports the path Pages actually serves — `/` once `coin.hugojava.dev` is
registered, `/the_universe_decides/` while it is not — and the workflow passes
that through. A base href that does not match the serving path makes
`flutter_bootstrap.js` 404, so the engine never boots and the page shows the
loading placeholder forever with no visible error. Reading the path keeps the
fallback usable while DNS or the custom-domain registration is pending, and
needs no code change when the domain goes live.

Three details matter for the deploy and are covered by
`test/web/web_deployment_configuration_test.dart`:

- `web/index.html` must keep the `$FLUTTER_BASE_HREF` placeholder, or
  `--base-href` is a no-op and every asset 404s.
- The workflow must resolve the base href from the Pages configuration rather
  than pinning a literal.
- `web/flutter_bootstrap.js` overrides `canvasKitBaseUrl` so CanvasKit is
  served from the deploy itself instead of `www.gstatic.com`.

Enable the deploy in **Settings → Pages → Build and deployment → Source →
GitHub Actions**, then register and validate the custom domain
`coin.hugojava.dev` in the same settings page and enable HTTPS enforcement once
GitHub provisions the certificate. The public URL only answers after that
registration: the Cloudflare CNAME alone is not enough, and without it Pages
serves the site from the project path instead.

### Release versioning

The semantic version name remains manually controlled in `pubspec.yaml`, for example:

```yaml
version: 2.6.0+100129
```

Before a release, change only the `major.minor.patch` portion when required. The CI/CD workflow automatically calculates the build number after `+` using the greatest safe next value derived from:

- `100000 + GITHUB_RUN_NUMBER`;
- the current build number in `pubspec.yaml` plus one;
- the latest stable release tag build number plus one.

After analyze, tests, and Android builds succeed, the workflow:

1. writes the resolved `versionName+versionCode` back to `pubspec.yaml`;
2. commits that version to `master` using `GITHUB_TOKEN`;
3. creates the GitHub Release and tag on that exact commit;
4. calls the reusable Google Play deployment workflow with the same version name and code.

The automatic version commit does not recursively trigger another workflow run because it is pushed with the repository `GITHUB_TOKEN`.

Each successful release publishes:

- `the-universe-decides-v<version>+<versionCode>-play.apk`
- `the-universe-decides-v<version>+<versionCode>-fdroid.apk`
- `the-universe-decides-v<version>+<versionCode>.aab`

`.github/workflows/android-play-deploy.yml` is both reusable by `CI/CD` and manually dispatchable. It checks out the persisted release commit, verifies that `pubspec.yaml` matches the supplied version, builds a signed Play AAB, and uploads it to the Google Play open-testing `beta` track.

See [`docs/google-play-cicd.md`](docs/google-play-cicd.md) for setup details and required secrets.

## Publishing an update to F-Droid

F-Droid does not publish every commit pushed to `master`. Its metadata watches stable release tags matching `v<major>.<minor>.<patch>+<versionCode>`.

Release procedure:

1. Update the semantic version name before `+` in `pubspec.yaml` when the release requires a new version name, and update `CHANGELOG.xml`.
2. Merge or push the application change to `master`.
3. Wait for the `CI/CD` workflow to pass. It calculates and persists the Android build number, then creates a tag such as `v2.6.0+100130` on the version commit.
4. F-Droid detects the new matching tag during its update cycle and builds the `fdroid` flavor from source. It does not install or redistribute the APK attached to the GitHub Release.
5. Check the upstream F-Droid build status after its next update cycle.

Do not manually increment the build number or create a duplicate release tag. Documentation, tests, analysis configuration, and workflow-only pushes do not create an F-Droid release.

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
