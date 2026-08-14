import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// One UI ignores the shade collapse that `startActivityAndCollapse` asks for,
/// so the tile hands the launch to System UI instead. These assertions pin that
/// wiring; this repo has no instrumented Android harness, so Android coverage
/// reads the source as a string (see `play_games_configuration_test.dart`).
void main() {
  String readTileService() {
    return File(
      'android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java',
    ).readAsStringSync();
  }

  test('the tile lets the system launch the coin on Android 14 and newer', () {
    final tileService = readTileService();

    expect(tileService, contains('public void onStartListening()'));
    expect(tileService, contains('Build.VERSION_CODES.UPSIDE_DOWN_CAKE'));
    expect(
      tileService,
      contains('tile.setActivityLaunchForClick(buildCoinPendingIntent())'),
    );
    expect(tileService, contains('tile.updateTile()'));
  });

  test('the launch intent still targets QuickCoinActivity', () {
    final tileService = readTileService();

    expect(tileService, contains('new Intent(this, QuickCoinActivity.class)'));
    expect(tileService, contains('QuickAccessContract.ACTION_COIN'));
    expect(tileService, contains('PendingIntent.FLAG_IMMUTABLE'));
  });

  test('onClick keeps a collapse path for releases before Android 14', () {
    final tileService = readTileService();

    expect(tileService, contains('startActivityAndCollapse(buildCoinIntent())'));
    expect(
      tileService,
      contains('startActivityAndCollapse(buildCoinPendingIntent())'),
      reason:
          'startActivityAndCollapse(Intent) throws on API 34+, so a skin that '
          'still delivers onClick there needs the PendingIntent overload.',
    );
  });

  test('the tile still asks for no unlock and no new permission', () {
    final tileService = readTileService();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(tileService, isNot(contains('unlockAndRun')));
    expect(tileService, isNot(contains('turnScreenOn')));
    expect(
      'uses-permission'.allMatches(manifest).length,
      1,
      reason: 'Only the existing INTERNET permission should be declared.',
    );
  });
}
