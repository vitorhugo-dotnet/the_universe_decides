import 'package:flutter/material.dart';

import 'package:theuniversedecides/screens/main_screen.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/coin_orb_mark.dart';

/// First screen Flutter shows once it takes over from the native launch
/// image: plays the coin-orb entrance (drop, flip, wobble to a stop) before
/// handing off to [MainScreen]. Renders [MainScreen] directly, with no
/// choreography or extra frame, when the platform requests reduced motion.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _started = false;
  bool _navigated = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    // Always constructed, even when reduced motion means it's never
    // forwarded: dispose() must find a real controller either way, and a
    // lazily-initialized (`late final ... = AnimationController(...)`)
    // field would otherwise construct itself inside dispose() the first
    // time it's touched there, against an already-deactivated context.
    _controller = AnimationController(
      vsync: this,
      duration: coinOrbEntranceDuration,
    )..addStatusListener(_onStatusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;

    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!_reduceMotion) {
      _controller.forward();
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goHome();
    }
  }

  void _goHome() {
    if (_navigated || !mounted) {
      return;
    }
    _navigated = true;

    Navigator.of(context).pushReplacement<void, void>(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: '/'),
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, _) =>
            FadeTransition(opacity: animation, child: const MainScreen()),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reduced motion skips the choreography entirely: render the home
    // screen in the same frame instead of animating in and navigating,
    // rather than merely shortening the animation.
    if (_reduceMotion) {
      return const MainScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final seconds =
                _controller.value *
                coinOrbEntranceDuration.inMilliseconds /
                1000;
            return CoinOrbMark(seconds: seconds, size: 220);
          },
        ),
      ),
    );
  }
}
