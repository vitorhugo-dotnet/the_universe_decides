import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/results_history_screen.dart';

void main() {
  testWidgets('shows the empty state when there is no history', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await _pumpHistoryScreen(tester);

    expect(find.text('Your recent results will appear here.'), findsOneWidget);
  });

  testWidgets('renders entries newest first with modality and result', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'results_history_entries_v1': jsonEncode([
        {
          'id': '2',
          'modality': 'dice',
          'resultLabel': 'd20: 14',
          'timestamp': DateTime(2026, 1, 2, 10).toIso8601String(),
        },
        {
          'id': '1',
          'modality': 'coin',
          'resultLabel': 'HEADS',
          'timestamp': DateTime(2026, 1, 1, 9).toIso8601String(),
        },
      ]),
    });

    await _pumpHistoryScreen(tester);

    expect(find.text('d20: 14'), findsOneWidget);
    expect(find.text('HEADS'), findsOneWidget);

    // Newest entry (dice) appears before the older one (coin) in the list.
    final dicePosition = tester.getTopLeft(find.text('d20: 14')).dy;
    final coinPosition = tester.getTopLeft(find.text('HEADS')).dy;
    expect(dicePosition, lessThan(coinPosition));
  });

  testWidgets('clearing the history requires confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({
      'results_history_entries_v1': jsonEncode([
        {
          'id': '1',
          'modality': 'coin',
          'resultLabel': 'HEADS',
          'timestamp': DateTime(2026, 1, 1, 9).toIso8601String(),
        },
      ]),
    });

    await _pumpHistoryScreen(tester);
    expect(find.text('HEADS'), findsOneWidget);

    await tester.tap(find.byKey(const Key('history-clear-button')));
    await tester.pumpAndSettle();

    // A confirmation dialog appears; cancelling keeps the history intact.
    expect(find.text('Clear history?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('HEADS'), findsOneWidget);

    // Confirming actually clears it.
    await tester.tap(find.byKey(const Key('history-clear-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('history-clear-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('HEADS'), findsNothing);
    expect(find.text('Your recent results will appear here.'), findsOneWidget);
  });
}

Future<void> _pumpHistoryScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResultsHistoryScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
