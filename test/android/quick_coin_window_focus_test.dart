import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `QuickCoinActivity` reports its window focus to Dart so the quick coin can
/// hold the flip until the notification panel is out of the way. This repo has
/// no instrumented Android harness, so the native side is asserted by reading
/// the source as a string (see `play_games_configuration_test.dart`).
void main() {
  String readQuickCoinActivity() {
    return File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java',
    ).readAsStringSync();
  }

  test('the activity answers with the real focus state, not a cached one', () {
    final quickActivity = readQuickCoinActivity();

    expect(quickActivity, contains('public void onWindowFocusChanged('));
    expect(
      quickActivity,
      contains('events.success(hasWindowFocus())'),
      reason:
          'A window launched behind the panel never had focus to lose, so no '
          'change is ever reported. The first event has to read the state '
          'directly or the gate never engages.',
    );
    expect(quickActivity, contains('windowFocusEventSink.success(hasFocus)'));
    expect(quickActivity, contains('windowFocusEventSink = null'));
  });

  test('the focus channel name matches on both sides', () {
    final contract = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickAccessContract.java',
    ).readAsStringSync();
    final service = File(
      'lib/services/window_focus_service.dart',
    ).readAsStringSync();

    const channel = 'theuniversedecides/quick_access/window_focus';
    expect(contract, contains('"$channel"'));
    expect(service, contains("'$channel'"));
    expect(
      readQuickCoinActivity(),
      contains('QuickAccessContract.WINDOW_FOCUS_EVENT_CHANNEL'),
    );
  });

  test('the lock screen behavior is untouched', () {
    final quickActivity = readQuickCoinActivity();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(quickActivity, contains('setShowWhenLocked(true)'));
    expect(
      quickActivity,
      contains('WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED'),
    );
    expect(manifest, contains('android:showWhenLocked="true"'));
    expect(
      'uses-permission'.allMatches(manifest).length,
      1,
      reason: 'Only the existing INTERNET permission should be declared.',
    );
  });
}
