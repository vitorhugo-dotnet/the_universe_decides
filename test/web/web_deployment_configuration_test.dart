import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The web bundle is published to the custom domain at the hostname root.
/// Every assertion here protects a detail that turns the published page into
/// a blank screen when it silently regresses.
void main() {
  test('index.html keeps the root-deployment base href placeholder', () {
    final index = File('web/index.html').readAsStringSync();

    expect(
      index,
      contains(r'<base href="$FLUTTER_BASE_HREF">'),
      reason:
          'Removing the placeholder makes --base-href a no-op and every asset '
          '404s under the custom-domain root.',
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
      contains(r'--base-href "/"'),
    );
    expect(workflow, contains("cp build/web/index.html build/web/404.html"));
    expect(workflow, contains("grep -Fq '<base href=\"/\">' build/web/index.html"));
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

  test('the Android pipeline is not triggered by browser-only changes', () {
    final androidWorkflow = File(
      '.github/workflows/build-signed-apk.yml',
    ).readAsStringSync();

    expect(
      androidWorkflow,
      isNot(contains('"web/**"')),
      reason:
          'web/ is not an input to analyze, tests or the Android build, so it '
          'must not spend CI minutes or create a release.',
    );
  });
}
