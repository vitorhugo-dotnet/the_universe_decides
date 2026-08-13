# GitHub Pages custom domain and fallback design

## Goal

Serve the Flutter Web application from `https://coin.hugojava.dev/` and make direct navigation or refresh on an application route load the app instead of GitHub Pages' default 404 page.

## Deployment design

The GitHub Actions web build uses `flutter build web --release --base-href "/"`, because the custom domain serves this project at its hostname root.

After a successful Flutter build, the workflow copies `build/web/index.html` to `build/web/404.html` before uploading the Pages artifact. GitHub Pages serves that identical application shell for unknown paths, preserving the requested browser URL while Flutter initializes and resolves the route.

The deployment remains fully static. No Nginx, server process, Worker, redirect script, or additional hosting layer is introduced.

## Domain configuration

Cloudflare has a DNS-only CNAME from `coin.hugojava.dev` to `vitorhugo-dotnet.github.io`.

GitHub Pages must additionally register `coin.hugojava.dev` as the repository custom domain. This can only be finalized once Pages is enabled for the repository. HTTPS enforcement is enabled after GitHub provisions the certificate.

## Verification

The workflow verifies before upload that:

- `build/web/index.html` exists;
- `build/web/404.html` exists;
- both files are byte-identical;
- the generated index uses the root base URL.

Existing Flutter analysis and tests continue to run before the release build.
