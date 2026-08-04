import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/theme/system_ui_overlay.dart';

void main() {
  testWidgets('AppSystemUiOverlay renders its child unchanged', (tester) async {
    await tester.pumpWidget(
      const AppSystemUiOverlay(
        child: Text('content', textDirection: TextDirection.ltr),
      ),
    );

    expect(find.text('content'), findsOneWidget);
  });

  testWidgets(
    'AppSystemUiOverlay pins an AnnotatedRegion<SystemUiOverlayStyle>',
    (tester) async {
      await tester.pumpWidget(
        const AppSystemUiOverlay(
          child: Text('content', textDirection: TextDirection.ltr),
        ),
      );

      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );

      expect(region.value, appSystemUiOverlayStyle);
    },
  );

  test(
    'the shared overlay style keeps bars transparent under edge-to-edge',
    () {
      // statusBarColor / systemNavigationBarColor are no-ops once the app
      // targets Android SDK 35+ (edge-to-edge is forced by the OS and those
      // fields are ignored) — setting them would be dead, misleading code, so
      // this test locks in that they stay unset.
      expect(appSystemUiOverlayStyle.statusBarColor, isNull);
      expect(appSystemUiOverlayStyle.systemNavigationBarColor, isNull);
    },
  );

  test('the shared overlay style keeps icons legible on the dark theme', () {
    expect(appSystemUiOverlayStyle.statusBarIconBrightness, Brightness.light);
    expect(
      appSystemUiOverlayStyle.systemNavigationBarIconBrightness,
      Brightness.light,
    );
  });

  test(
    'the shared overlay style disables the navigation bar contrast scrim',
    () {
      expect(
        appSystemUiOverlayStyle.systemNavigationBarContrastEnforced,
        isFalse,
      );
    },
  );
}
