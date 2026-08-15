import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';

/// Pumps [child] inside a [MaterialApp] whose window is exactly [width] by
/// [height] logical pixels, so band-dependent layout can be asserted without
/// depending on the default test surface size.
///
/// The localization delegates are not optional: every screen reads
/// `AppLocalizations.of(context)!`, which is null under a bare [MaterialApp]
/// and takes the screen down before any layout can be asserted. The delegate
/// list mirrors `test/list_picker_screen_test.dart`.
///
/// The [Scaffold] is likewise required: the six screens are composed as
/// children of `MainScreen`'s scaffold and do not provide their own, so their
/// ink and text need one here.
Future<void> pumpAtWidth(
  WidgetTester tester,
  Widget child, {
  required double width,
  double height = 900,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}
