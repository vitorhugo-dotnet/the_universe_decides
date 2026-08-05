import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QuickCoinActivity is configured to show above the lock screen', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final quickActivity = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java',
    ).readAsStringSync();

    expect(manifest, contains('android:name=".QuickCoinActivity"'));
    expect(manifest, contains('android:showWhenLocked="true"'));
    expect(quickActivity, contains('setShowWhenLocked(true)'));
    expect(
      quickActivity,
      contains('WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED'),
    );
  });

  test('locked-device launch requests no new permission and no unlock', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final tileService = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java',
    ).readAsStringSync();
    final quickActivity = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java',
    ).readAsStringSync();

    expect(manifest, isNot(contains('SYSTEM_ALERT_WINDOW')));
    expect(manifest, isNot(contains('TYPE_APPLICATION_OVERLAY')));
    expect(tileService, isNot(contains('unlockAndRun')));
    expect(tileService, isNot(contains('turnScreenOn')));
    expect(quickActivity, isNot(contains('SYSTEM_ALERT_WINDOW')));
    expect(
      'uses-permission'.allMatches(manifest).length,
      1,
      reason: 'Only the existing INTERNET permission should be declared.',
    );
  });

  test('CoinQuickTileService launches QuickCoinActivity directly', () {
    final tileService = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java',
    ).readAsStringSync();

    expect(tileService, contains('extends TileService'));
    expect(tileService, contains('new Intent(this, QuickCoinActivity.class)'));
    expect(tileService, contains('startActivityAndCollapse'));
    expect(
      File(
        'android/app/src/main/java/com/hugo/theuniversedecides/QuickActionTileService.java',
      ).existsSync(),
      isFalse,
    );
  });

  test('QuickCoinActivity keeps its transparency and lifecycle behavior', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final activityStart = manifest.indexOf(
      '<activity\n            android:name=".QuickCoinActivity"',
    );
    final activityEnd = manifest.indexOf('/>', activityStart) + 2;
    expect(activityStart, greaterThanOrEqualTo(0));
    final activityBlock = manifest.substring(activityStart, activityEnd);

    expect(activityBlock, contains('android:excludeFromRecents="true"'));
    expect(activityBlock, contains('android:noHistory="true"'));
    expect(activityBlock, contains('android:theme="@style/QuickCoinTheme"'));
    expect(activityBlock, contains('android:launchMode="singleTop"'));
  });
}
