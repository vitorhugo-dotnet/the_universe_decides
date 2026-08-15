# Web build and GitHub Pages deploy

The browser build of The Universe Decides is published to GitHub Pages by
`.github/workflows/deploy-web.yml`. The public address is the custom domain:

```text
https://coin.hugojava.dev/
```

Until that domain is registered in Pages settings, GitHub serves the same build
from the project path `https://vitorhugo-dotnet.github.io/the_universe_decides/`
instead. That fallback is not advertised, but it must still work, because it is
what answers whenever the custom domain is pending or removed.

## One-time repository setup

1. Open **Settings → Pages → Build and deployment**.
2. Set **Source** to **GitHub Actions**.
3. Register `coin.hugojava.dev` as the custom domain on the same page and wait
   for GitHub to validate it, then enable HTTPS enforcement once the
   certificate is provisioned.

Step 3 is what makes the public URL answer. The Cloudflare `CNAME` from
`coin.hugojava.dev` to `vitorhugo-dotnet.github.io` is necessary but not
sufficient on its own: without the Pages-side registration GitHub serves no
certificate for the hostname, and the domain fails TLS verification.

## The base href is read, not hardcoded

A Flutter Web bundle only works under the path its `<base href>` names.
`web/index.html` keeps the `$FLUTTER_BASE_HREF` placeholder that
`flutter build web --base-href` substitutes, and the workflow resolves that
argument from `actions/configure-pages`, which reports the path Pages actually
publishes to: `/` for the custom domain, `/the_universe_decides/` for the
project site.

This matters because the failure mode is total rather than partial. With a root
base href while Pages is still serving the project path, the browser requests
`https://vitorhugo-dotnet.github.io/flutter_bootstrap.js` instead of
`https://vitorhugo-dotnet.github.io/the_universe_decides/flutter_bootstrap.js`,
gets a 404, never boots the engine, never fires `flutter-first-frame`, and never
removes the placeholder in `web/index.html`. The page shows the loading orb
forever with no visible error.

Reading the path instead of pinning it keeps that window survivable, and means
the deploy needs no code change on the day the domain goes live — or if it is
ever moved or dropped.

The workflow verifies that the built `index.html` is copied to `404.html`, that
the resolved base href is present in it, and that the two files are
byte-identical for client-side route fallback.

## Building locally

Pass the path you intend to serve from, and serve from exactly that path. For
the custom domain, that is the root:

```bash
flutter build web --release --base-href "/"
python3 -m http.server --directory build/web 8080   # then open /
```

To reproduce the project-path fallback instead, build with the project path and
serve it from a matching subdirectory:

```bash
flutter build web --release --base-href "/the_universe_decides/"
mkdir -p /tmp/site && cp -r build/web /tmp/site/the_universe_decides
python3 -m http.server --directory /tmp/site 8080
# then open http://localhost:8080/the_universe_decides/
```

Mismatching the two is exactly the bug described above, and it reproduces
locally: the page keeps the loading orb and the console shows a 404 for
`flutter_bootstrap.js`.

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

`--wasm` is not an either/or switch: `flutter build web --release --wasm`
emits `main.dart.wasm` *and* `main.dart.js` into the same `build/web`, and
`flutter_bootstrap.js` picks between them per browser at load time — a
browser without WasmGC silently takes the `dart2js`/CanvasKit path instead.
Both paths therefore ship in the one artifact the workflow publishes; the
tables below measure both from that single build.

Measured with Flutter 3.47.0 on this repository, `--release` with
`--base-href "/"`.

### Transferred payload (gzip, what a first visit downloads)

| File | JS fallback path | WebAssembly path |
| --- | ---: | ---: |
| App code | `main.dart.js` 936 KiB | `main.dart.wasm` 1012 KiB + `main.dart.mjs` 8 KiB |
| Renderer loader | `canvaskit.js` 27 KiB | `skwasm.js` 17 KiB |
| Renderer binary | `canvaskit.wasm` 2848 KiB | `skwasm.wasm` 1501 KiB |
| **Total** | **3811 KiB** | **2539 KiB** |

A WasmGC browser (current Chrome, Edge, Firefox) downloads only the
WebAssembly path's rows; the JS-fallback rows stay unfetched. A browser
without WasmGC downloads only the JS-fallback rows instead.

### Published artifact

| | Size |
| --- | ---: |
| `build/web` on disk | 44.1 MiB |

This is the single build now published: it contains both compiled outputs, so
there is no separate "standard artifact" size to compare it against anymore.

### Compatibility findings

- `flutter build web` already reports **"Wasm dry run succeeded"** for this
  app, so every dependency is compatible. `webview_flutter` is not on the web
  compilation path at all.
- `flutter build web --release --wasm --base-href "/"` completes, and both
  `main.dart.wasm` and `main.dart.js` are present in `build/web` afterwards.
- Verified in headless Chromium (which supports WasmGC, so it takes the
  WebAssembly path): the build boots, `flutter-first-frame` fires, the
  `#loading` placeholder is removed, and the dice bridge round-trip
  (`rollStarted` → physics animation in the `<iframe>` → `rollCompleted`)
  completes under `dart:js_interop`, producing a real result. No request
  404s.
- Chromium selects `skwasm.wasm`, the **single-threaded** variant. The
  multi-threaded `skwasm_heavy` build needs cross-origin isolation via
  `Cross-Origin-Opener-Policy` and `Cross-Origin-Embedder-Policy` headers.
  **GitHub Pages cannot set response headers**, so the fastest skwasm path
  stays unavailable on this host regardless of how the app is built.
- Cross-origin isolation would also change how the dice `<iframe>` is
  embedded, so `skwasm_heavy` is not a free upgrade even once a host that can
  set those headers is available.

### Decision

Ship `--wasm`. The measured download saving (3811 KiB → 2539 KiB gzipped,
about a third smaller) is real and reaches every WasmGC-capable visitor
automatically, with no loss of compatibility: the JS fallback keeps shipping
in the same artifact for browsers without WasmGC, so nobody regresses. The
published artifact is correspondingly larger on disk than a single-renderer
build would be (44.1 MiB, since it now carries both compiled outputs in one
bundle), which GitHub Pages storage absorbs without issue.

What this does *not* unlock: GitHub Pages sets no response headers, so
`Cross-Origin-Opener-Policy` / `Cross-Origin-Embedder-Policy` are absent and
the browser keeps selecting the single-threaded `skwasm.wasm` rather than
`skwasm_heavy`. The multi-threaded renderer remains unavailable on this host
regardless of the `--wasm` switch.

### Before enabling `skwasm_heavy`

Unlocking the multi-threaded renderer needs a host that can set
`Cross-Origin-Opener-Policy: same-origin` and
`Cross-Origin-Embedder-Policy: require-corp`, which GitHub Pages cannot do.
Revisit only if the app moves to a host that can, and only after also
confirming:

1. First-frame and time-to-interactive on real hardware, cable and mobile.
2. Animation smoothness for the wheel, the coin and the dice physics.
3. Chrome, Edge, Firefox, Safari desktop and Safari on iOS under real
   cross-origin isolation.
4. That cross-origin isolation does not break the dice `<iframe>` embedding,
   which is same-origin today but would need `Cross-Origin-Embedder-Policy`
   compliance from every embedded resource.
