import 'package:flutter/material.dart';

import 'package:theuniversedecides/theme/app_colors.dart';

/// Full-bleed dark background from the Claude Design "The Universe Decides"
/// prototype: a vertical base gradient with a soft purple radial glow on top.
class RitualBackground extends StatelessWidget {
  const RitualBackground({
    super.key,
    required this.child,
    this.glowAlignment = const Alignment(0, -0.84),
    this.glowRadius = 1.1,
  });

  final Widget child;
  final Alignment glowAlignment;
  final double glowRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.scaffoldBackground,
            AppColors.backgroundGradientMiddle,
            AppColors.scaffoldBackground,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: glowAlignment,
            radius: glowRadius,
            colors: const [AppColors.ritualGlow, Colors.transparent],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// A slowly rotating dashed or dotted rune ring. Rotation is disabled when the
/// platform requests reduced motion.
class RuneRing extends StatefulWidget {
  const RuneRing({
    super.key,
    required this.diameter,
    required this.color,
    required this.periodSeconds,
    this.reverse = false,
    this.dotted = false,
    this.strokeWidth = 1,
  });

  final double diameter;
  final Color color;
  final int periodSeconds;
  final bool reverse;
  final bool dotted;
  final double strokeWidth;

  @override
  State<RuneRing> createState() => _RuneRingState();
}

class _RuneRingState extends State<RuneRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.periodSeconds),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = RuneRingPainter(
      color: widget.color,
      strokeWidth: widget.strokeWidth,
      dotted: widget.dotted,
    );

    return IgnorePointer(
      child: RotationTransition(
        turns: widget.reverse
            ? Tween<double>(begin: 1, end: 0).animate(_controller)
            : _controller,
        child: CustomPaint(
          size: Size.square(widget.diameter),
          painter: painter,
        ),
      ),
    );
  }
}

/// Paints a dashed (or dotted) circle stroke using path metrics — the SDK has
/// no dashed-border primitive.
class RuneRingPainter extends CustomPainter {
  const RuneRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dotted,
  });

  final Color color;
  final double strokeWidth;
  final bool dotted;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = dotted ? StrokeCap.round : StrokeCap.butt;

    // Dotted rings read as tiny round dots; dashed rings as short segments.
    final dashLength = dotted ? 0.1 : 6.0;
    final gapLength = dotted ? 7.0 : 7.0;

    final rect = Offset.zero & size;
    final path = Path()
      ..addOval(rect.deflate(strokeWidth / 2 + 0.5));

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(RuneRingPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dotted != oldDelegate.dotted;
}

/// Convenience: a centered pair of counter-rotating rune rings, used behind the
/// coin. Sizes/speeds match the ritual variant of the Mystic Coin prototype.
class CoinRuneRings extends StatelessWidget {
  const CoinRuneRings({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          RuneRing(
            diameter: 260,
            color: AppColors.runePurple,
            periodSeconds: 22,
          ),
          RuneRing(
            diameter: 222,
            color: AppColors.runeAmber,
            periodSeconds: 16,
            reverse: true,
            dotted: true,
          ),
        ],
      ),
    );
  }
}

/// Faint rune rings for the app shell, anchored near the top of the screen.
class ShellRuneRings extends StatelessWidget {
  const ShellRuneRings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: -66,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              RuneRing(
                diameter: 280,
                color: AppColors.runePurpleFaint,
                periodSeconds: 30,
              ),
              RuneRing(
                diameter: 230,
                color: AppColors.runeAmberFaint,
                periodSeconds: 22,
                reverse: true,
                dotted: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
