import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main.dart explicitly disables debug paint baselines on startup', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains("import 'package:flutter/rendering.dart';"));
    expect(mainSource, contains('debugPaintBaselinesEnabled = false;'));

    final ensureIndex = mainSource.indexOf(
      'WidgetsFlutterBinding.ensureInitialized();',
    );
    final baselineIndex = mainSource.indexOf(
      'debugPaintBaselinesEnabled = false;',
    );
    expect(ensureIndex, greaterThanOrEqualTo(0));
    expect(
      baselineIndex,
      greaterThan(ensureIndex),
      reason:
          'debugPaintBaselinesEnabled must be reset right after '
          'WidgetsFlutterBinding.ensureInitialized() so QuickCoinActivity '
          "never inherits a stale debug-paint flag from a previous run.",
    );
  });

  test('no application source enables a Flutter debug paint flag', () {
    const debugPaintFlags = [
      'debugPaintSizeEnabled',
      'debugPaintBaselinesEnabled',
      'debugPaintPointersEnabled',
      'debugPaintLayerBordersEnabled',
      'debugRepaintRainbowEnabled',
    ];

    final dartFiles = Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>().where(
      (file) => file.path.endsWith('.dart'),
    );

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      for (final flag in debugPaintFlags) {
        expect(
          source,
          isNot(contains('$flag = true')),
          reason: '${file.path} must not enable $flag',
        );
      }
    }
  });
}
