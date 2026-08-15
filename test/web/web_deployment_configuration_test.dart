import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The web bundle is published to GitHub Pages, under the project path until
/// the custom domain is registered and at the hostname root afterwards. Every
/// assertion here protects a detail that turns the published page into a blank
/// screen, or into the loading placeholder forever, when it silently regresses.
void main() {
  test('index.html keeps the base href placeholder', () {
    final index = File('web/index.html').readAsStringSync();

    expect(
      index,
      contains(r'<base href="$FLUTTER_BASE_HREF">'),
      reason:
          'Removing the placeholder makes --base-href a no-op and every asset '
          '404s on whichever host does not happen to match the literal.',
    );
    expect(index, contains('<title>The Universe Decides</title>'));
    expect(index, contains('<link rel="manifest" href="manifest.json">'));
    expect(index, contains('<script src="flutter_bootstrap.js" async></script>'));
  });

  test('index.html paints the app background before the first frame', () {
    final index = File('web/index.html').readAsStringSync();

    expect(index, contains('#090611'));
    expect(index, contains("id=\"loading\""));
    expect(
      index,
      contains("window.addEventListener('flutter-first-frame'"),
      reason: 'The placeholder must be removed once Flutter paints.',
    );
    expect(
      index,
      contains('prefers-reduced-motion'),
      reason: 'The loading animation must honour the accessibility setting.',
    );
  });

  test('the bootstrap override keeps every generated placeholder', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();

    for (final placeholder in const [
      '{{flutter_js}}',
      '{{flutter_build_config}}',
      '{{flutter_service_worker_version}}',
    ]) {
      expect(
        bootstrap,
        contains(placeholder),
        reason: 'flutter build web substitutes $placeholder at build time',
      );
    }

    expect(
      bootstrap,
      contains('canvasKitBaseUrl: "canvaskit/"'),
      reason:
          'CanvasKit is served from the deploy itself; falling back to the '
          'gstatic CDN leaves the app stuck on the loading screen whenever '
          'that host is unreachable.',
    );
  });

  test('the manifest describes the app and every icon exists', () {
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, dynamic>;

    expect(manifest['name'], 'The Universe Decides');
    expect(manifest['background_color'], '#090611');
    expect(manifest['theme_color'], '#090611');

    final icons = (manifest['icons'] as List).cast<Map<String, dynamic>>();
    expect(icons, hasLength(4));
    for (final icon in icons) {
      expect(
        File('web/${icon['src']}').existsSync(),
        isTrue,
        reason: 'web/${icon['src']} is referenced by the manifest',
      );
    }

    expect(File('web/favicon.png').existsSync(), isTrue);
  });

  test('the deploy workflow validates before it publishes', () {
    final workflow = File(
      '.github/workflows/deploy-web.yml',
    ).readAsStringSync();

    expect(workflow, contains('flutter analyze'));
    expect(workflow, contains('flutter test'));
    expect(
      workflow,
      contains('actions/configure-pages@v5'),
      reason:
          'A hardcoded base href is wrong on whichever host the site is not '
          'currently served from, and every asset 404s there. The published '
          'path must be read from the live Pages configuration instead.',
    );
    expect(
      workflow,
      contains(r'--base-href "${{ steps.base.outputs.href }}"'),
      reason: 'The build must consume the resolved base href, not a literal.',
    );
    expect(
      workflow,
      isNot(contains(r'--base-href "/"')),
      reason:
          'Pinning the root base href is what left the project-path deploy '
          'stuck on the loading placeholder.',
    );
    expect(
      workflow,
      contains(r'''
          flutter build web \
            --release \
            --wasm \
            --base-href "${{ steps.base.outputs.href }}"'''),
      reason:
          'The browser build ships WebAssembly. Dropping the flag from the '
          'build invocation silently returns every visitor to the larger '
          'JavaScript-only payload — an explanatory comment mentioning '
          '"--wasm" is not enough to keep this passing, and must not be.',
    );
    expect(workflow, contains("cp build/web/index.html build/web/404.html"));
    expect(
      workflow,
      contains(r'grep -Fq "<base href=\"$BASE_HREF\">" build/web/index.html'),
      reason: 'The artifact check must assert the resolved base href.',
    );
    expect(workflow, contains('cmp --silent build/web/index.html build/web/404.html'));
    expect(workflow, contains('actions/upload-pages-artifact@v3'));
    expect(workflow, contains('actions/deploy-pages@v4'));
    expect(
      workflow,
      contains('needs: build'),
      reason: 'A failed analyze, test or build must never reach Pages.',
    );
    expect(
      workflow,
      contains('cancel-in-progress: true'),
      reason: 'Superseded deploys must be cancelled, not queued.',
    );
    expect(
      workflow,
      isNot(contains('android/**')),
      reason:
          'Android-only changes must not redeploy the site, and the Android '
          'release pipeline must stay independent of this workflow.',
    );
  });

  test('the deploy workflow is callable and skips validation only when the '
      'caller already ran it', () {
    final workflow = File(
      '.github/workflows/deploy-web.yml',
    ).readAsStringSync();

    expect(
      workflow,
      contains('workflow_call:'),
      reason: 'CI/CD publishes the site once analyze and tests have passed.',
    );
    expect(
      workflow,
      contains('workflow_dispatch:'),
      reason:
          'Republishing the current master head must not require a code '
          'change.',
    );
    expect(
      workflow,
      contains(r'if: ${{ !inputs.validated }}'),
      reason:
          'A direct dispatch has no caller to vouch for the commit, so it '
          'must analyze and test before it publishes. Dropping the guard '
          'instead of the steps would let a dispatch replace a working site '
          'with an unvalidated build.',
    );
  });

  test('CI/CD publishes the commit it validated', () {
    final ci = File(
      '.github/workflows/build-signed-apk.yml',
    ).readAsStringSync();

    expect(
      ci,
      contains('"web/**"'),
      reason:
          'test/web/ reads web/index.html, web/manifest.json and '
          'web/flutter_bootstrap.js, so web/ is an input to flutter test. A '
          'browser-only change must reach the pipeline that validates and '
          'publishes it, or the site never picks the change up.',
    );
    expect(
      ci,
      contains('uses: ./.github/workflows/deploy-web.yml'),
      reason: 'The site is published by the pipeline that ran the tests.',
    );
    expect(
      ci,
      contains('needs: [analyze, test]'),
      reason: 'A commit failing analyze or test must never reach Pages.',
    );
    expect(
      ci,
      contains('validated: true'),
      reason:
          'Only a caller that gated the deploy behind analyze and test may '
          'tell the deploy workflow to skip its own validation.',
    );
  });

  test('a browser-only change never builds Android and never releases', () {
    final ci = File(
      '.github/workflows/build-signed-apk.yml',
    ).readAsStringSync();

    expect(
      ci,
      contains(r"if: needs.version.outputs.android_relevant == 'true'"),
      reason:
          'web/ reaching the pipeline is what lets the site deploy, but it is '
          'not an input to the Android build. Without this gate every '
          'browser-only change spends CI minutes on the Play APK, the Play '
          'AAB and the F-Droid APK.',
    );
    expect(
      ci,
      contains(r'android_relevant: ${{ steps.version.outputs.android_relevant }}'),
      reason: 'The gate needs the value the version job resolved.',
    );
  });

  test('a failing web deploy cannot block the Android release chain', () {
    final ci = File(
      '.github/workflows/build-signed-apk.yml',
    ).readAsStringSync();

    final dependents = ci
        .split('\n')
        .where((line) => line.trimLeft().startsWith('needs:'))
        .where((line) => line.contains('deploy-web'))
        .toList();

    expect(
      dependents,
      isEmpty,
      reason:
          'Nothing may depend on the web deploy. A GitHub Pages outage must '
          'still leave the Play APK, the Play AAB, the F-Droid APK, the '
          'GitHub Release and the Play deployment free to run, so these are '
          'the jobs that must never wait on it: $dependents',
    );
  });
}
