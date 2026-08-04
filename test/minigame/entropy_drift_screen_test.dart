import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theuniversedecides/minigame/entropy_drift_screen.dart';

void main() {
  testWidgets('entropy drift screen mounts, accepts a drag, and shows controls', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: EntropyDriftScreen()),
      ),
    );
    await tester.pump();
    // A few simulation frames — the game runs on a continuous ticker, so we
    // must not use pumpAndSettle (it would never settle).
    await tester.pump(const Duration(milliseconds: 300));

    await tester.dragFrom(const Offset(200, 400), const Offset(20, -20));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(EntropyDriftScreen), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Dispose the screen so its ticker stops before the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
