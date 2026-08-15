import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/screens/main_screen.dart';
import 'package:theuniversedecides/widgets/ritual_bottom_nav.dart';
import 'package:theuniversedecides/widgets/ritual_nav_rail.dart';

import '../support/fake_webview_platform.dart';
import '../support/layout_harness.dart';

Future<void> _pumpShell(WidgetTester tester, double width) async {
  await pumpAtWidth(
    tester,
    const ProviderScope(child: MainScreen()),
    width: width,
  );
  await tester.pump();
}

void main() {
  setUpAll(FakeWebViewPlatform.register);

  testWidgets('narrow windows keep the bottom bar', (tester) async {
    await _pumpShell(tester, 400);

    expect(find.byType(RitualBottomNav), findsOneWidget);
    expect(find.byType(RitualNavRail), findsNothing);
  });

  testWidgets('medium windows keep the bottom bar', (tester) async {
    await _pumpShell(tester, 800);

    expect(find.byType(RitualBottomNav), findsOneWidget);
    expect(find.byType(RitualNavRail), findsNothing);
  });

  testWidgets('wide windows swap the bar for the rail', (tester) async {
    await _pumpShell(tester, 1400);

    expect(find.byType(RitualNavRail), findsOneWidget);
    expect(find.byType(RitualBottomNav), findsNothing);
  });

  testWidgets('the rail selects a tab', (tester) async {
    await _pumpShell(tester, 1400);

    await tester.tap(find.descendant(
      of: find.byType(RitualNavRail),
      matching: find.text('Cards'),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
