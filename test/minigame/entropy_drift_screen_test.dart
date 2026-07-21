import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theuniversedecides/minigame/entropy_drift_screen.dart';

void main() {
  testWidgets('entropy drift screen mounts, accepts a drag, and can be dismissed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: EntropyDriftScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.dragFrom(const Offset(200, 400), const Offset(20, -20));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(EntropyDriftScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });
}
