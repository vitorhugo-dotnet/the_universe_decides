import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/main.dart';

/// Collects the resolved text style of every paragraph currently rendered.
List<TextStyle> _renderedTextStyles(WidgetTester tester) {
  final styles = <TextStyle>[];

  void visit(RenderObject node) {
    if (node is RenderParagraph) {
      final style = node.text.style;
      if (style != null) {
        styles.add(style);
      }
      node.text.visitChildren((span) {
        if (span is TextSpan && span.style != null) {
          styles.add(span.style!);
        }
        return true;
      });
    }
    node.visitChildren(visit);
  }

  visit(tester.binding.rootElement!.renderObject!);
  return styles;
}

void main() {
  testWidgets('quick coin route renders text without underline decoration', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UniverseDecidesApp(initialRoute: UniverseRoutes.quickCoin),
      ),
    );
    await tester.pump();

    final styles = _renderedTextStyles(tester);
    expect(
      styles,
      isNotEmpty,
      reason: 'the quick coin route must render at least one paragraph',
    );

    for (final style in styles) {
      expect(
        style.decoration ?? TextDecoration.none,
        TextDecoration.none,
        reason:
            'Text painted outside a Material ancestor inherits the '
            'MaterialApp error style, which draws a double yellow underline '
            'that looks like a debug overlay.',
      );
    }
  });

  testWidgets('quick coin route provides a Material ancestor for its text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UniverseDecidesApp(initialRoute: UniverseRoutes.quickCoin),
      ),
    );
    await tester.pump();

    final textFinder = find.byType(Text).first;
    expect(
      find.ancestor(of: textFinder, matching: find.byType(Material)),
      findsWidgets,
      reason:
          'without a Material ancestor the default text style falls back to '
          'the MaterialApp error style.',
    );
  });
}
