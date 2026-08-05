import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The "Ritual Seal" coin-orb mark used on the app's splash screen.
///
/// Reproduces the entrance choreography (drop in, flip several times,
/// wobble to a stop) from the Claude Design "Splash Screen Animada"
/// prototype's `splash-scenes.jsx` `Splash` scene, plus its continuous
/// glow-pulse and counter-rotating rune rings.
///
/// This widget owns no motion of its own: [seconds] is the elapsed
/// animation time and every value below is a pure function of it, mirroring
/// the prototype's formulas exactly. Callers (see [SplashScreen]) own the
/// `AnimationController` and just feed elapsed time in.
class CoinOrbMark extends StatelessWidget {
  const CoinOrbMark({super.key, required this.seconds, this.size = 300});

  final double seconds;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CoinOrbPainter(seconds),
    );
  }
}

/// Total duration of the coin-orb entrance choreography (drop + flip +
/// wobble-to-a-stop), matching the prototype's "Splash" scene duration.
const Duration coinOrbEntranceDuration = Duration(milliseconds: 1600);

class _CoinOrbPainter extends CustomPainter {
  const _CoinOrbPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 300;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);

    final opacity = _entryOpacity(t);
    if (opacity <= 0) {
      canvas.restore();
      return;
    }

    canvas.saveLayer(
      const Rect.fromLTWH(-150, -150, 300, 300),
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );
    _paintGlow(canvas);
    _paintRings(canvas);
    _paintCoin(canvas);
    canvas.restore();

    canvas.restore();
  }

  void _paintGlow(Canvas canvas) {
    final alpha = (0.35 * _glowPulse(t)).clamp(0.0, 1.0);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF6C463).withValues(alpha: alpha),
          const Color(0x00F6C463),
        ],
      ).createShader(const Rect.fromLTWH(-140, -140, 280, 280));
    canvas.drawCircle(Offset.zero, 140, paint);
  }

  void _paintRings(Canvas canvas) {
    canvas.save();
    canvas.scale(_ringPulse(t));

    canvas.drawCircle(
      Offset.zero,
      130,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x24FFFFFF),
    );

    canvas.save();
    canvas.rotate(_ring1Rotation(t) * math.pi / 180);
    canvas.drawCircle(
      const Offset(0, -130),
      3,
      Paint()..color = const Color(0xFFF6C463),
    );
    canvas.restore();

    canvas.save();
    canvas.rotate(_ring2Rotation(t) * math.pi / 180);
    _drawDottedCircle(
      canvas,
      111,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x4DFFD68C),
    );
    canvas.restore();

    canvas.restore();
  }

  void _paintCoin(Canvas canvas) {
    canvas.save();
    canvas.translate(0, _dropY(t));
    canvas.scale(_dropScale(t));
    canvas.rotate(_rotZ(t) * math.pi / 180);
    canvas.scale(_squishX(t), 1);

    canvas.drawCircle(
      Offset.zero,
      80,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.24, -0.36),
          radius: 0.75,
          colors: [
            Color(0xFFFFF3D6),
            Color(0xFFF6C463),
            Color(0xFFC97E2E),
            Color(0xFF5B3417),
          ],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(const Rect.fromLTWH(-80, -80, 160, 160)),
    );
    canvas.drawCircle(
      Offset.zero,
      80,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x8CFFE0A0),
    );

    canvas.save();
    canvas.rotate(_glyphRotation(t) * math.pi / 180);
    canvas.drawPath(_glyphPath, Paint()..color = const Color(0x8C3C2008));
    canvas.restore();

    canvas.restore();
  }

  static final Path _glyphPath = Path()
    ..moveTo(0, -26)
    ..quadraticBezierTo(6, -6, 26, 0)
    ..quadraticBezierTo(6, 6, 0, 26)
    ..quadraticBezierTo(-6, 6, -26, 0)
    ..quadraticBezierTo(-6, -6, 0, -26)
    ..close();

  static void _drawDottedCircle(Canvas canvas, double radius, Paint paint) {
    const dashLength = 1.0;
    const gapLength = 6.0;
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: radius));
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
  bool shouldRepaint(covariant _CoinOrbPainter oldDelegate) =>
      oldDelegate.t != t;
}

// ---- Timeline math -- mirrors splash-scenes.jsx's Splash scene exactly. ----

double _easeOutBack(double x) {
  const c1 = 1.70158;
  const c3 = c1 + 1;
  final p = x - 1;
  return 1 + c3 * p * p * p + c1 * p * p;
}

double _easeOutCubic(double x) {
  final p = x - 1;
  return p * p * p + 1;
}

double _easeInQuad(double x) => x * x;

double _easeOutQuad(double x) => x * (2 - x);

/// Popmotion-style keyframe interpolation: maps [t] across [input]
/// keyframes into [output] values, easing each segment with the matching
/// entry of [ease] (pass the same function repeated when the prototype
/// used one easing for every segment).
double _interpolate(
  double t,
  List<double> input,
  List<double> output,
  List<double Function(double)> ease,
) {
  if (t <= input.first) return output.first;
  if (t >= input.last) return output.last;
  for (var i = 0; i < input.length - 1; i++) {
    if (t >= input[i] && t <= input[i + 1]) {
      final span = input[i + 1] - input[i];
      final local = span == 0 ? 0.0 : (t - input[i]) / span;
      final eased = ease[i](local);
      return output[i] + (output[i + 1] - output[i]) * eased;
    }
  }
  return output.last;
}

double _dropScale(double t) =>
    _interpolate(t, [0, 0.192], [0.55, 1], [_easeOutBack]);

double _dropY(double t) => _interpolate(t, [0, 0.192], [-34, 0], [
  _easeOutCubic,
]);

double _entryOpacity(double t) => _interpolate(t, [0, 0.096], [0, 1], [
  _easeOutCubic,
]);

double _theta(double t) => t < 0.192
    ? 0
    : _interpolate(t, [0.192, 0.672, 1.152], [0, 900, 1440], [
        _easeInQuad,
        _easeOutCubic,
      ]);

double _breathing(double t) => 1 - 0.02 * math.sin(t * 3).abs();

double _squishX(double t) {
  final radians = _theta(t) * math.pi / 180;
  return math.max(0.14, math.cos(radians).abs()) * _breathing(t);
}

double _wobbleAmp(double t) =>
    _interpolate(t, [0.192, 1.088, 1.312], [9, 9, 0], [
      _easeOutQuad,
      _easeOutQuad,
    ]);

double _idleRotZ(double t) => math.sin(t * 2) * 1.2;

double _rotZ(double t) {
  final amp = _wobbleAmp(t);
  final mix = 1 - amp / 9;
  return math.sin(t * 16) * amp * 0.5 + _idleRotZ(t) * mix;
}

double _glyphRotation(double t) => t * 50;

double _ringPulse(double t) =>
    _interpolate(t, [1.112, 1.168, 1.376], [1, 1.07, 1], [
      _easeOutQuad,
      _easeOutQuad,
    ]);

double _glowPulse(double t) => 0.85 + 0.15 * math.sin(t * 1.6);

double _ring1Rotation(double t) => (t / 22) * 360;

double _ring2Rotation(double t) => -(t / 16) * 360;
