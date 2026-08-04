import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Play flavor maps the Play Games application ID resource', () {
    final manifest = File(
      'android/app/src/play/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('com.google.android.gms.games.APP_ID'));
    expect(manifest, contains('@string/game_services_project_id'));
    expect(
      manifest,
      contains('com.google.android.gms.games.SUPPRESS_GAME_PROFILE_CREATION'),
    );
  });

  test('shared manifest excludes Play Games metadata', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, isNot(contains('com.google.android.gms.games.APP_ID')));
    expect(
      manifest,
      isNot(
        contains('com.google.android.gms.games.SUPPRESS_GAME_PROFILE_CREATION'),
      ),
    );
  });

  test('Android manifest classifies the primary app as productivity', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:appCategory="productivity"'));
    expect(manifest, isNot(contains('android:appCategory="game"')));
    expect(manifest, isNot(contains('android:isGame="true"')));
  });

  test('Play Games application ID resource is isolated to Play flavor', () {
    final resources = File(
      'android/app/src/play/res/values/games-ids.xml',
    ).readAsStringSync();

    expect(resources, contains('name="game_services_project_id"'));
    expect(resources, contains('translatable="false">595881887646</string>'));
    expect(
      File('android/app/src/main/res/values/games-ids.xml').existsSync(),
      isFalse,
    );
  });

  test('coin quick tile opens the translucent quick coin activity', () {
    final tileService = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickActionTileService.java',
    ).readAsStringSync();
    final quickActivity = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java',
    ).readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(tileService, contains('getLaunchActivityClass()'));
    expect(tileService, contains('new Intent(this, getLaunchActivityClass())'));
    expect(
      quickActivity,
      contains('QuickCoinActivity extends FlutterActivity'),
    );
    expect(quickActivity, contains('getInitialRoute()'));
    expect(quickActivity, contains('/quick-coin'));
    expect(quickActivity, contains('BackgroundMode.transparent'));
    expect(quickActivity, contains('RenderMode.texture'));
    expect(manifest, contains('android:name=".QuickCoinActivity"'));
    expect(manifest, contains('android:theme="@style/QuickCoinTheme"'));
    expect(manifest, isNot(contains('SYSTEM_ALERT_WINDOW')));
    expect(manifest, isNot(contains('TYPE_APPLICATION_OVERLAY')));
  });
}
