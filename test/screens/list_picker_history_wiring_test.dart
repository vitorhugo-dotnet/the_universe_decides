import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/list_picker_screen.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/services/results_history_service.dart';

import '../support/fake_webview_platform.dart';

void main() {
  setUp(FakeWebViewPlatform.register);

  testWidgets(
    'picking an item from the list writes a coin-style entry into the results history',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      final container = ProviderContainer(
        overrides: [
          randomOrgServiceProvider.overrideWithValue(
            RandomOrgService(
              client: MockClient((_) async => http.Response('1', 200)),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: ListPickerScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // History starts empty for this decision mode.
      expect(container.read(resultsHistoryProvider), isEmpty);

      await tester.enterText(find.byType(TextField), 'Tea');
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Let the universe choose'));
      await tester.pumpAndSettle();

      final entries = container.read(resultsHistoryProvider);
      expect(entries, hasLength(1));
      expect(entries.single.modality, HistoryModality.list);
      expect(entries.single.resultLabel, 'Coffee');
    },
  );
}
