import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// The native launch screen must paint nothing but the app background color.
/// Any image handed to Android is drawn while the process starts, so it
/// flashes ahead of the Flutter splash (lib/screens/splash_screen.dart)
/// instead of being replaced by it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

  test('the legacy cosmic coin splash image is gone', () {
    expect(File('assets/splash/cosmic_coin_splash.png').existsSync(), isFalse);
    expect(
      File('flutter_native_splash.yaml').readAsStringSync(),
      isNot(contains('cosmic_coin_splash')),
    );

    for (final density in densities) {
      expect(
        File('android/app/src/main/res/drawable-$density/splash.png')
            .existsSync(),
        isFalse,
        reason: 'drawable-$density/splash.png must not be regenerated.',
      );
    }
  });

  test('launch backgrounds draw the background color and nothing else', () {
    for (final path in const [
      'android/app/src/main/res/drawable/launch_background.xml',
      'android/app/src/main/res/drawable-v21/launch_background.xml',
    ]) {
      final launchBackground = File(path).readAsStringSync();

      expect(launchBackground, contains('@drawable/background'));
      expect(
        launchBackground,
        isNot(contains('@drawable/splash')),
        reason: '$path must not layer an image over the background.',
      );
    }
  });

  test('the Android 12+ splash icon is declared and fully transparent', () async {
    for (final path in const [
      'android/app/src/main/res/values-v31/styles.xml',
      'android/app/src/main/res/values-night-v31/styles.xml',
    ]) {
      // Declared explicitly: Android falls back to the launcher icon when no
      // animated icon is set, which would flash just like the old coin did.
      expect(
        File(path).readAsStringSync(),
        contains(
          '<item name="android:windowSplashScreenAnimatedIcon">'
          '@drawable/android12splash</item>',
        ),
        reason: '$path must point the system splash at a blank icon.',
      );
    }

    for (final density in densities) {
      for (final variant in const ['drawable', 'drawable-night']) {
        final path =
            'android/app/src/main/res/$variant-$density/android12splash.png';
        final codec = await ui.instantiateImageCodec(
          File(path).readAsBytesSync(),
        );
        final frame = await codec.getNextFrame();
        final pixels = await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );

        expect(pixels, isNotNull, reason: 'Could not decode $path.');
        final opaque = <int>[];
        for (var offset = 3; offset < pixels!.lengthInBytes; offset += 4) {
          if (pixels.getUint8(offset) != 0) {
            opaque.add(offset ~/ 4);
          }
        }
        expect(
          opaque,
          isEmpty,
          reason: '$path must be fully transparent, '
              'found ${opaque.length} visible pixels.',
        );
      }
    }
  });
}
