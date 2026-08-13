# GitHub Pages Custom Domain Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the Flutter Web application at `coin.hugojava.dev` with root-relative assets and a GitHub Pages SPA fallback.

**Architecture:** Keep GitHub Pages as the only static host. The workflow builds for the custom-domain root, duplicates the generated application shell as `404.html`, verifies the artifact, and then deploys it.

**Tech Stack:** Flutter 3.44.7, GitHub Actions, GitHub Pages, Bash, Cloudflare DNS

## Global Constraints

- Do not introduce Nginx, Cloudflare Workers, redirects, or another hosting layer.
- Keep the existing analyze and Flutter test gates unchanged.
- Keep Cloudflare DNS as a DNS-only CNAME to `vitorhugo-dotnet.github.io`.
- Configure `coin.hugojava.dev` as the repository's GitHub Pages custom domain once Pages is enabled.

---

### Task 1: Build and verify the custom-domain Pages artifact

**Files:**
- Modify: `.github/workflows/deploy-web.yml`

**Interfaces:**
- Consumes: Flutter's generated `build/web/index.html`
- Produces: root-based `build/web/index.html` and byte-identical `build/web/404.html`

- [ ] **Step 1: Establish the failing artifact assertions**

Run the current build and then execute:

```bash
test -f build/web/404.html
grep -F '<base href="/">' build/web/index.html
cmp --silent build/web/index.html build/web/404.html
```

Expected before the workflow change: FAIL because `404.html` is absent and the generated base href points to `/the_universe_decides/`.

- [ ] **Step 2: Build for the custom-domain root**

Replace the existing build command with:

```yaml
      - name: Build web
        run: |
          flutter build web \
            --release \
            --base-href "/"
```

- [ ] **Step 3: Add the fallback and artifact verification**

Insert immediately after the build step:

```yaml
      - name: Add SPA fallback and verify artifact
        shell: bash
        run: |
          test -f build/web/index.html
          cp build/web/index.html build/web/404.html
          test -f build/web/404.html
          grep -F '<base href="/">' build/web/index.html
          cmp --silent build/web/index.html build/web/404.html
```

- [ ] **Step 4: Validate the updated workflow**

Run:

```bash
flutter analyze
flutter test
flutter build web --release --base-href "/"
cp build/web/index.html build/web/404.html
grep -F '<base href="/">' build/web/index.html
cmp --silent build/web/index.html build/web/404.html
```

Expected: analysis and tests pass; build succeeds; both artifact checks exit with status 0.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/deploy-web.yml
git commit -m "fix(web): support custom domain and route fallback"
```

### Task 2: Register and verify the GitHub Pages domain

**Files:**
- No repository file changes.

**Interfaces:**
- Consumes: Cloudflare CNAME `coin.hugojava.dev -> vitorhugo-dotnet.github.io`
- Produces: GitHub Pages custom domain `coin.hugojava.dev`

- [ ] **Step 1: Enable GitHub Actions as the Pages source**

After PR #67 is merged, configure GitHub Pages to use GitHub Actions. The repository currently reports `has_pages: false`, so this cannot be finalized before Pages is enabled.

- [ ] **Step 2: Register the custom domain**

Set the repository Pages `cname` field to `coin.hugojava.dev`.

- [ ] **Step 3: Verify DNS and HTTPS**

Confirm GitHub reports the custom domain without a DNS error. Wait for certificate provisioning, enable HTTPS enforcement, and verify `https://coin.hugojava.dev/` and a direct application route both load the Flutter shell.
