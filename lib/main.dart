import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/screens/splash_screen.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/theme/system_ui_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintBaselinesEnabled = false;
  // Explicitly declare edge-to-edge instead of relying on the implicit
  // per-SDK default (see lib/theme/system_ui_overlay.dart for details).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: UniverseDecidesApp()));
}

class UniverseRoutes {
  static const home = '/';
  static const quickCoin = '/quick-coin';

  const UniverseRoutes._();
}

Route<void> _buildRoute(RouteSettings settings) {
  if (settings.name == UniverseRoutes.quickCoin) {
    return PageRouteBuilder<void>(
      settings: settings,
      opaque: false,
      barrierColor: Colors.transparent,
      // The quick coin route is pushed straight onto the navigator, so unlike
      // the normal flow it has no Scaffold above it. Without a Material
      // ancestor every Text falls back to MaterialApp's error style, whose
      // double yellow underline looks exactly like a Flutter debug overlay.
      // MaterialType.transparency keeps the see-through background intact.
      pageBuilder: (_, _, _) => const Material(
        type: MaterialType.transparency,
        child: CoinFlipScreen(
          quickMode: true,
          autoStart: true,
          autoClose: true,
        ),
      ),
    );
  }

  return MaterialPageRoute<void>(
    builder: (_) => const SplashScreen(),
    settings: settings,
  );
}

class UniverseDecidesApp extends StatelessWidget {
  const UniverseDecidesApp({
    super.key,
    this.initialRoute = UniverseRoutes.home,
  });

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      color: initialRoute == UniverseRoutes.quickCoin
          ? Colors.transparent
          : AppColors.scaffoldBackground,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          AppSystemUiOverlay(child: child ?? const SizedBox.shrink()),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('en');
      },
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (initialRouteName) => [
        _buildRoute(RouteSettings(name: initialRouteName)),
      ],
      onGenerateRoute: _buildRoute,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.22),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.navigationBackground,
          indicatorColor: colorScheme.primary.withValues(alpha: 0.22),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              color: isSelected
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.snackBarBackground,
          contentTextStyle: TextStyle(color: colorScheme.onSurface),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.18),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

