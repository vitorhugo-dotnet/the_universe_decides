import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The system status/navigation bar style used across the whole app.
///
/// The app always renders on a single dark background (see [AppColors]), so
/// one overlay style covers every screen.
///
/// Deliberately does **not** set [SystemUiOverlayStyle.statusBarColor] /
/// [SystemUiOverlayStyle.systemNavigationBarColor]: once an app targets
/// Android SDK 35+ (this app targets the Flutter-default SDK 36), the OS
/// forces [SystemUiMode.edgeToEdge] and silently ignores those two fields —
/// setting them is a no-op and the pre-edge-to-edge idiom of painting a solid
/// color behind the bars (the old `Window.setStatusBarColor` /
/// `setNavigationBarColor` approach) is exactly the deprecated behavior
/// Android 15/16 flags. Instead, only the properties that still do something
/// under edge-to-edge are set:
///   * icon brightness, so status/navigation bar icons stay legible over the
///     app's dark background on every OEM skin;
///   * [systemNavigationBarContrastEnforced] = false, so Android doesn't draw
///     its own translucent scrim behind the navigation bar on top of the
///     app's own custom-drawn bottom navigation bar background.
const SystemUiOverlayStyle appSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

/// Pins [appSystemUiOverlayStyle] for the subtree below it.
///
/// This is placed at the root of the app (via `MaterialApp.builder`) instead
/// of only calling [SystemChrome.setSystemUIOverlayStyle] once at startup.
/// [AnnotatedRegion] re-asserts the style on every frame the region paints,
/// so it self-heals if the OS (or a route change) resets the system bar
/// appearance — a call in `main()` alone would not recover from that.
class AppSystemUiOverlay extends StatelessWidget {
  const AppSystemUiOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: appSystemUiOverlayStyle,
      child: child,
    );
  }
}
