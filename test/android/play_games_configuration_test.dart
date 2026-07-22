import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android manifest maps the Play Games application ID resource', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('com.google.android.gms.games.APP_ID'));
    expect(manifest, contains('@string/game_services_project_id'));
    expect(
      manifest,
      contains('com.google.android.gms.games.SUPPRESS_GAME_PROFILE_CREATION'),
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

  test('Play Games application ID resource contains the project ID', () {
    final resources = File(
      'android/app/src/main/res/values/games-ids.xml',
    ).readAsStringSync();

    expect(resources, contains('name="game_services_project_id"'));
    expect(resources, contains('translatable="false">595881887646</string>'));
  });
}
