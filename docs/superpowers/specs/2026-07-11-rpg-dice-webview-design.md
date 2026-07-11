# RPG Dice WebView Design

## Scope

Replace only the legacy Flutter dice screen with the supplied App redesign prototype's full-screen “Ritual dos Dados” composition. The prototype is the visual source of truth. The sole deliberate visual adjustment is that the embedded dice renderer is transparent, so Flutter's cosmic background continues behind it without a seam.

## Architecture

Flutter keeps ownership of dice quantity/type, Random.org plus local fallback, generated results, totals, controls, loading/error states, and result presentation. It does not use JavaScript as a random source.

`DiceRollController` will distinguish random-value fetching from 3D animation progress and guard against a second active roll. Once values are received, they remain valid even if the WebView fails or times out. A small `DiceWebView` widget owns a single initialized local WebView, its controller, the channel, request correlation, resize/lifecycle notifications, and disposal.

The screen will reproduce the prototype's hierarchy: ritual eyebrow, title, quantity controls, dice-type controls, gold action button, the transparent dice animation region, and Flutter-rendered individual results plus total. It will not preserve the old Material card or its faux tumbling grid.

## Bundled Web Engine

`assets/dice/` will package the adapted prototype engine, `index.html`, `bridge.js`, Three.js, Cannon.js, Teal helpers, and the required MIT license/attribution. No CDN requests or external navigation are allowed.

HTML, body, container, and canvas are transparent. Three.js uses an alpha renderer and transparent clear color. Cannon retains invisible floor and collision barriers, while the original visible desk/floor mesh is omitted. The adapted visuals use the prototype purple dice, gold labels, and lavender lighting.

The engine will support the currently exposed d4, d6, d8, d10, d12, d20, and d100 types. It uses real Three.js rendering and Cannon physics for the throw, then settles each die to Flutter's supplied predetermined face; physics is never the source of the outcome.

## Bridge Contract

Flutter calls only:

```js
window.DiceBridge.roll({
  requestId: "unique-id",
  notation: "2d20",
  results: [7, 18]
});
```

JavaScript emits JSON through a single named channel:

```json
{"type":"ready"}
{"type":"rollStarted","requestId":"unique-id"}
{"type":"rollCompleted","requestId":"unique-id","results":[7,18],"total":25}
{"type":"error","requestId":"unique-id","message":"..."}
```

JavaScript validates notation/result ranges, permits one active roll, rejects malformed inputs, and emits structured errors. Flutter ignores malformed messages and messages for stale request IDs. A bounded roll timeout releases the UI while retaining and displaying any valid Flutter-generated result.

## Lifecycle and Accessibility

The WebView has a transparent Flutter background and is constrained to the animation area. It disables scrolling, zooming, selection, context menus, and navigation. The platform view is kept alive across rebuilds. App visibility and widget lifecycle pause/resume rendering; resize updates the renderer without creating a new WebGL context. Flutter controls remain native and accessible.

## Validation

Focused unit/widget tests will cover bridge request serialization and message parsing, invalid/stale messages, loading/rolling state, repeated-roll prevention, totals, timeout behavior, and preserving random results after animation failure. Required validation will run `flutter pub get`, `dart format .`, `flutter analyze`, and `flutter test` after implementation.
