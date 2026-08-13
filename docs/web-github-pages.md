# Web build and GitHub Pages deploy

The browser build of The Universe Decides is published to GitHub Pages by
`.github/workflows/deploy-web.yml`:

```text
https://vitorhugo-dotnet.github.io/the_universe_decides/
```

## One-time repository setup

1. Open **Settings → Pages → Build and deployment**.
2. Set **Source** to **GitHub Actions**.

Nothing else is required. The workflow creates the `github-pages`
environment on its first run, and no branch is used to host the site.

## Building locally

```bash
flutter build web --release --base-href /the_universe_decides/
python3 -m http.server --directory build 8080   # then open /web/
```

The `--base-href` value must match the repository name. GitHub Pages serves
project sites from `/<repository>/`, and `web/index.html` keeps the
`$FLUTTER_BASE_HREF` placeholder that `flutter build` substitutes. Without it
every asset, the manifest and the icons resolve against `/` and 404.

The workflow derives the value from `github.event.repository.name`, so a
repository rename does not silently break the deploy.

## What differs from the Android build

The browser runs the same Dart code. Only host integrations change.

| Area | Android | Browser |
| --- | --- | --- |
| Coin, dice, cards, tarot, lists, wheel | native | identical |
| Recent history | `shared_preferences` | `shared_preferences` on `localStorage` |
| RANDOM.ORG | direct HTTP | direct HTTP, falls back on CORS/network failure |
| Fallback warning | shown | shown, identical wording |
| Quick Settings tile | offered in *About* | section hidden |
| Play Games leaderboard | offered on game over | button hidden |
| Entropy Drift minigame | playable, scores submitted | playable, local high score only |

### The cross-platform split

Two libraries do not exist on every platform, and each break only shows up
when building for the *other* platform:

- `dart:io` does not compile for the browser. `lib/**` must never import it;
  `EntropyDriftPlayGamesService` uses `kIsWeb` with `defaultTargetPlatform`
  instead (`isPlayGamesHost`).
- `dart:js_interop`, `dart:ui_web` and `package:web` do not compile for
  Android or iOS. They stay in `lib/dice/dice_renderer_web.dart`, reached only
  through the conditional import in `lib/dice/dice_web_view.dart`.

`test/web/web_compilation_path_test.dart` fails the build if either rule is
broken.

### The dice renderer

`assets/dice/index.html` is a self-contained three.js/cannon.js renderer that
talks to Dart over `window.DiceBridge` and `window.DiceBridgeChannel`. It is
*not* reimplemented for the browser:

- Android loads it in a `webview_flutter` web view
  (`lib/dice/dice_renderer_native.dart`).
- The browser loads the same asset in a same-origin `<iframe>` inside an
  `HtmlElementView` (`lib/dice/dice_renderer_web.dart`).

Both hosts run the identical bridge script strings, so the roll rules stay in
Dart and the renderer only reveals a result the service already chose. Two
browser-specific details:

- `bridge.js` emits its `ready` event while the document is still parsing,
  before Dart can install `DiceBridgeChannel`. Every script in `index.html` is
  synchronous, so the web host synthesises the hand-off on the iframe's `load`
  event instead.
- The iframe is `pointer-events: none`; Flutter owns every gesture on the
  screen and the frame only draws.

### CanvasKit is served from the deploy

`web/flutter_bootstrap.js` overrides `canvasKitBaseUrl` to `canvaskit/`.
By default Flutter fetches CanvasKit from `www.gstatic.com`, and an
unreachable CDN leaves the app stuck on the loading screen forever rather than
degrading. Serving it from the same origin keeps the deploy self-contained.

One third-party request remains: CanvasKit downloads Roboto from
`fonts.gstatic.com`. That failure is cosmetic rather than fatal on machines
with system fonts, and bundling a font would add weight to the Android
artifact too, so it is left as upstream Flutter behaviour.

### RANDOM.ORG and CORS

`https://www.random.org/integers/` is called directly from the browser. If the
response is blocked by CORS the `http` client throws, `RandomOrgService`
catches it like any other failure, emits `RandomOrgFallbackEvent`, and the
shell shows the same "Random.org is unavailable. Using local randomness."
notice the Android app shows. No proxy or backend was added: the MVP keeps the
fallback transparent, and the two sources stay clearly distinguishable.

## Standard build vs WebAssembly

Measured with Flutter 3.44.7 on this repository, both at `--release` with the
same `--base-href`.

### Transferred payload (gzip, what a first visit downloads)

| File | Standard | `--wasm` |
| --- | ---: | ---: |
| App code | `main.dart.js` 929 KiB | `main.dart.wasm` 1012 KiB + `main.dart.mjs` 8 KiB |
| Renderer loader | `canvaskit.js` 27 KiB | `skwasm.js` 17 KiB |
| Renderer binary | `canvaskit.wasm` 2833 KiB | `skwasm.wasm` 1496 KiB |
| **Total** | **3789 KiB** | **2533 KiB** |

### Published artifact

| | Standard | `--wasm` |
| --- | ---: | ---: |
| `build/web` on disk | 41.9 MiB | 44.7 MiB |

`--wasm` is not an either/or switch: it emits `main.dart.wasm` *and*
`main.dart.js`, and the loader picks per browser. That is why the artifact
grows while the download shrinks.

### Compatibility findings

- `flutter build web` already reports **"Wasm dry run succeeded"** for this
  app, so every dependency is compatible today. `webview_flutter` is not on
  the web compilation path at all.
- `flutter build web --wasm` completes, loads, and the dice bridge round-trip
  (`rollStarted` → animation → `rollCompleted`) works unchanged under
  `dart:js_interop`.
- Chromium selects `skwasm.wasm`, the **single-threaded** variant. The
  multi-threaded `skwasm_heavy` build needs cross-origin isolation via
  `Cross-Origin-Opener-Policy` and `Cross-Origin-Embedder-Policy` headers.
  **GitHub Pages cannot set response headers**, so the fastest skwasm path is
  unavailable on this host regardless of how the app is built.
- Cross-origin isolation would also change how the dice `<iframe>` is
  embedded, so it is not a free upgrade.

### Decision

Ship the standard build for the MVP, as the issue recommends. The download
saving is real but is not the bottleneck for an app with no heavy computation,
and the renderer that would justify the switch is capped at single-threaded on
GitHub Pages.

### Before revisiting

The numbers above are size and compatibility only. A migration decision needs
what a software-rendered CI container cannot measure:

1. First-frame and time-to-interactive on real hardware, cable and mobile.
2. Animation smoothness for the wheel, the coin and the dice physics.
3. Chrome, Edge, Firefox, Safari desktop and Safari on iOS — a WasmGC-less
   browser silently takes the JS fallback, so both paths need testing.
4. Memory use on low-end Android devices in Chrome.
5. Whether a host that can set COOP/COEP (and therefore unlock
   `skwasm_heavy`) is worth moving to.

Switch only if there is a measurable win with no relevant compatibility loss.
