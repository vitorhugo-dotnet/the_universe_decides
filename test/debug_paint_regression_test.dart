import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/main.dart';

void main() {
  testWidgets('no debug paint flag is enabled while the app is running', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UniverseDecidesApp(initialRoute: UniverseRoutes.quickCoin),
      ),
    );
    await tester.pump();

    expect(debugPaintSizeEnabled, isFalse);
    expect(debugPaintBaselinesEnabled, isFalse);
    expect(debugPaintPointersEnabled, isFalse);
    expect(debugPaintLayerBordersEnabled, isFalse);
    expect(debugRepaintRainbowEnabled, isFalse);
  });

  testWidgets('every route keeps a Material ancestor above its text', (
    tester,
  ) async {
    for (final route in [UniverseRoutes.home, UniverseRoutes.quickCoin]) {
      await tester.pumpWidget(
        ProviderScope(child: UniverseDecidesApp(initialRoute: route)),
      );
      await tester.pump();

      final texts = find.byType(Text);
      if (texts.evaluate().isEmpty) {
        continue;
      }

      expect(
        find.ancestor(of: texts.first, matching: find.byType(Material)),
        findsWidgets,
        reason:
            'route $route renders text without a Material ancestor, so it '
            'inherits the MaterialApp error style and its double yellow '
            'underline, which is easily mistaken for a debug paint overlay.',
      );
    }
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
