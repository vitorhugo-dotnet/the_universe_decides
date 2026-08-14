import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

/// The Quick Settings tile asks the system to collapse the notification panel
/// before the quick coin shows up, but OEM skins are free to ignore that. These
/// tests pin the app-side guarantee: an automatic flip waits until the app
/// window owns the screen again, so the coin is never spent behind the panel.
void main() {
  Widget buildApp(Widget home) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  Future<_RecordingRandomOrgService> pumpQuickCoin(WidgetTester tester) async {
    final service = _RecordingRandomOrgService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [randomOrgServiceProvider.overrideWith((ref) => service)],
        child: buildApp(
          const CoinFlipScreen(
            quickMode: true,
            autoStart: true,
            autoClose: false,
          ),
        ),
      ),
    );

    return service;
  }

  testWidgets('the automatic flip waits while a system panel holds the focus', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

    final service = await pumpQuickCoin(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      service.fetchCallCount,
      0,
      reason: 'The coin must not flip behind the notification panel.',
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    expect(
      service.fetchCallCount,
      1,
      reason: 'The coin flips as soon as the panel releases the focus.',
    );
  });

  testWidgets('the automatic flip runs anyway when the focus never comes back', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

    final service = await pumpQuickCoin(tester);
    await tester.pump();

    expect(service.fetchCallCount, 0);

    await tester.pump(const Duration(seconds: 4));

    expect(
      service.fetchCallCount,
      1,
      reason: 'A skin that never restores the focus must not strand the coin.',
    );
  });

  testWidgets('a focused window still flips immediately', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    final service = await pumpQuickCoin(tester);
    await tester.pump();

    expect(service.fetchCallCount, 1);
  });
}

class _RecordingRandomOrgService extends RandomOrgService {
  _RecordingRandomOrgService()
    : super(client: MockClient((_) async => http.Response('', 200)));

  int fetchCallCount = 0;

  @override
  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async {
    fetchCallCount++;
    return const [0];
  }

  @override
  void dispose() {}
}
