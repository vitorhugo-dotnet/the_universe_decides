import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/services/window_focus_service.dart';

/// The Quick Settings tile asks the system to collapse the notification panel
/// before the quick coin shows up, and One UI ignores that. These tests pin the
/// app-side guarantee: an automatic flip waits until the window really owns the
/// screen, so the coin is never spent behind the panel.
///
/// The focus has to come from `Activity.hasWindowFocus()`. An earlier version
/// read [AppLifecycleState] instead and shipped broken: Flutter only leaves
/// `resumed` on a focus *change*, and a window launched behind the panel never
/// held the focus, so no change was ever reported and every flip started
/// immediately. A fake service stands in for the native channel here.
void main() {
  Widget buildApp(Widget home) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  Future<_RecordingRandomOrgService> pumpQuickCoin(
    WidgetTester tester,
    WindowFocusService focus,
  ) async {
    final service = _RecordingRandomOrgService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          windowFocusServiceProvider.overrideWithValue(focus),
        ],
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

  testWidgets('the flip waits while the panel holds the window focus', (
    tester,
  ) async {
    final focus = _FakeWindowFocusService();

    final service = await pumpQuickCoin(tester, focus);
    focus.emit(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      service.fetchCallCount,
      0,
      reason: 'The coin must not flip behind the notification panel.',
    );

    focus.emit(true);
    await tester.pump();
    await tester.pump();

    expect(
      service.fetchCallCount,
      1,
      reason: 'The coin flips as soon as the window owns the screen.',
    );

    focus.close();
  });

  testWidgets('an unfocused window that never reports a change still waits', (
    tester,
  ) async {
    // The regression that shipped: no focus event at all, because the window
    // never had focus to lose. Silence must read as "wait", not as "go".
    final focus = _FakeWindowFocusService();

    final service = await pumpQuickCoin(tester, focus);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(service.fetchCallCount, 0);

    focus.emit(true);
    await tester.pump();
    await tester.pump();

    expect(service.fetchCallCount, 1);

    focus.close();
  });

  testWidgets('the flip runs anyway when the focus never arrives', (
    tester,
  ) async {
    final focus = _FakeWindowFocusService();

    final service = await pumpQuickCoin(tester, focus);
    focus.emit(false);
    await tester.pump();

    expect(service.fetchCallCount, 0);

    await tester.pump(const Duration(seconds: 4));

    expect(
      service.fetchCallCount,
      1,
      reason: 'A skin that never releases the focus must not strand the coin.',
    );

    focus.close();
  });

  testWidgets('a focused window flips immediately', (tester) async {
    final focus = _FakeWindowFocusService();

    final service = await pumpQuickCoin(tester, focus);
    focus.emit(true);
    await tester.pump();
    await tester.pump();

    expect(service.fetchCallCount, 1);

    focus.close();
  });
}

class _FakeWindowFocusService implements WindowFocusService {
  final _controller = StreamController<bool>.broadcast();

  void emit(bool hasFocus) => _controller.add(hasFocus);

  void close() => unawaited(_controller.close());

  @override
  Stream<bool> get focusChanges => _controller.stream;
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
