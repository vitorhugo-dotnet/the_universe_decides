import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the two directions of the cross-platform split.
///
/// `dart:io` and Android-only plugins do not compile for the browser, and
/// `dart:js_interop` / `package:web` do not compile for Android or iOS. Either
/// mistake only surfaces at build time on the platform that was not touched,
/// which is exactly the kind of break that reaches the Play Store or the
/// GitHub Pages deploy unnoticed.
void main() {
  late List<File> libraryFiles;

  setUpAll(() {
    libraryFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
  });

  test('no shared library pulls dart:io into the web build', () {
    final offenders = libraryFiles
        .where((file) => file.readAsStringSync().contains("import 'dart:io'"))
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'dart:io is unavailable in the browser. Use kIsWeb and '
          'defaultTargetPlatform, or a conditional import, instead.',
    );
  });

  test('browser-only libraries stay off the mobile compilation path', () {
    const webOnlyImports = [
      "import 'dart:js_interop'",
      "import 'dart:js_interop_unsafe'",
      "import 'dart:ui_web'",
      "import 'package:web/web.dart'",
    ];

    final offenders = libraryFiles
        .where((file) => !file.path.endsWith('dice_renderer_web.dart'))
        .where(
          (file) => webOnlyImports.any(file.readAsStringSync().contains),
        )
        .map((file) => file.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'These libraries do not compile for Android or iOS. They belong '
          'behind the conditional import in lib/dice/dice_web_view.dart.',
    );
  });

  test('the dice host is selected by a conditional import', () {
    final diceWebView = File(
      'lib/dice/dice_web_view.dart',
    ).readAsStringSync();

    expect(
      diceWebView,
      contains(
        "import 'dice_renderer_native.dart'\n"
        "    if (dart.library.js_interop) 'dice_renderer_web.dart';",
      ),
    );
    expect(
      diceWebView,
      isNot(contains('package:webview_flutter')),
      reason:
          'webview_flutter has no web implementation, so it must stay inside '
          'the native renderer.',
    );
  });

  test('both dice hosts expose the same entry point', () {
    for (final path in [
      'lib/dice/dice_renderer_native.dart',
      'lib/dice/dice_renderer_web.dart',
    ]) {
      expect(
        File(path).readAsStringSync(),
        contains('Widget buildDiceRenderer(DiceWebViewController controller)'),
        reason: '$path must satisfy the conditional import contract',
      );
    }
  });
}
