// Customised copy of the default Flutter bootstrap.
//
// The only change from the generated default is `canvasKitBaseUrl`: CanvasKit
// is otherwise pulled from `www.gstatic.com`, and a blocked or unreachable CDN
// leaves the app stuck on the loading screen forever. Serving it from the same
// custom-domain hostname root as the rest of the bundle keeps the deploy fully
// static and self-contained, and makes it a third-party-request-free page.
//
// The relative URL resolves against the root `--base-href "/"` used by the
// deploy workflow for `https://coin.hugojava.dev/`.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  }
});
