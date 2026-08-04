import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

import 'package:flutter/foundation.dart';

/// A moving cosmic body — a black hole (obstacle) or a probability fragment
/// (collectible) — travelling across the Entropy Drift playfield.
///
/// Each body is rendered as its own small widget, so the game never
/// re-rasterises a full-screen canvas. On some Android GPUs (e.g. the Galaxy
/// M54's Xclipse) a full-surface per-frame repaint hits a Flutter/driver
/// partial-repaint bug and renders black; small per-element repaints do not.
class DriftBody {
  DriftBody({
    required this.id,
    required this.position,
    required this.velocity,
    required this.radius,
  });

  final int id;
  Offset position;
  final Offset velocity;
  final double radius;
}

/// Pure-Dart game logic for Entropy Drift, advanced by [tick]. Holds no Flutter
/// widgets or rendering so it can be unit-tested and driven by a plain [Ticker].
///
/// This replaces the previous Flame `FlameGame` implementation; the constants
/// and behaviour are kept identical.
class EntropyDriftEngine {
  EntropyDriftEngine({
    required this.onObstacleHit,
    required this.onFragmentCollected,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Called once when the star hits a black hole, before the game stops.
  final VoidCallback onObstacleHit;

  /// Called each time a fragment is collected.
  final VoidCallback onFragmentCollected;

  final math.Random _random;

  static const double starRadius = 14;
  static const double obstacleRadius = 22;
  static const double fragmentRadius = 8;

  static const double _difficultyStep = 10;
  static const double _minObstacleInterval = 0.6;
  static const double _minFragmentInterval = 1.0;
  static const double _maxSpeedMultiplier = 2.5;

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<bool> isGameOver = ValueNotifier<bool>(false);

  final List<DriftBody> obstacles = <DriftBody>[];
  final List<DriftBody> fragments = <DriftBody>[];

  Size _size = Size.zero;
  Offset _star = Offset.zero;
  int _nextId = 0;

  double _survivalTime = 0;
  int _fragmentScore = 0;
  int _fragmentsCollected = 0;
  double _obstacleTimer = 1.4;
  double _fragmentTimer = 1.8;
  double _obstacleInterval = 1.6;
  double _fragmentInterval = 2.2;
  double _speedMultiplier = 1;
  double _nextDifficultyBump = _difficultyStep;

  Size get size => _size;
  Offset get star => _star;
  Duration get survivalDuration => Duration(
    microseconds: (_survivalTime * Duration.microsecondsPerSecond).round(),
  );
  int get fragmentsCollected => _fragmentsCollected;

  /// Sets/updates the playfield size. Centres the star the first time a real
  /// size arrives, and re-clamps it on later resizes.
  void setSize(Size value) {
    if (value == _size || value.isEmpty) {
      return;
    }
    final firstLayout = _size == Size.zero;
    _size = value;
    _star = firstLayout
        ? Offset(value.width / 2, value.height / 2)
        : _clampToField(_star);
  }

  /// Moves the star toward [target], clamped to stay fully inside the field.
  void moveStar(Offset target) {
    if (_size == Size.zero) {
      return;
    }
    _star = _clampToField(target);
  }

  Offset _clampToField(Offset p) {
    return Offset(
      p.dx.clamp(starRadius, math.max(starRadius, _size.width - starRadius)),
      p.dy.clamp(starRadius, math.max(starRadius, _size.height - starRadius)),
    );
  }

  /// Advances the simulation by [dt] seconds.
  void tick(double dt) {
    if (isGameOver.value || _size == Size.zero || dt <= 0) {
      return;
    }

    _survivalTime += dt;
    if (_survivalTime >= _nextDifficultyBump) {
      _nextDifficultyBump += _difficultyStep;
      _obstacleInterval = math.max(
        _minObstacleInterval,
        _obstacleInterval * 0.85,
      );
      _fragmentInterval = math.max(
        _minFragmentInterval,
        _fragmentInterval * 0.9,
      );
      _speedMultiplier = math.min(_maxSpeedMultiplier, _speedMultiplier + 0.2);
    }

    _obstacleTimer -= dt;
    if (_obstacleTimer <= 0) {
      _obstacleTimer = _obstacleInterval;
      _spawn(obstacles, baseSpeed: 70, radius: obstacleRadius);
    }
    _fragmentTimer -= dt;
    if (_fragmentTimer <= 0) {
      _fragmentTimer = _fragmentInterval;
      _spawn(fragments, baseSpeed: 50, radius: fragmentRadius);
    }

    _advance(obstacles, dt);
    _advance(fragments, dt);

    for (final obstacle in obstacles) {
      if (_hitsStar(obstacle)) {
        _endRun();
        break;
      }
    }
    if (!isGameOver.value) {
      fragments.removeWhere((fragment) {
        if (_hitsStar(fragment)) {
          _fragmentScore += 5;
          _fragmentsCollected++;
          onFragmentCollected();
          return true;
        }
        return false;
      });
    }

    score.value = (_survivalTime * 2).floor() + _fragmentScore;
  }

  void _advance(List<DriftBody> bodies, double dt) {
    const margin = 80.0;
    bodies.removeWhere((body) {
      body.position += body.velocity * dt;
      final p = body.position;
      return p.dx < -margin ||
          p.dy < -margin ||
          p.dx > _size.width + margin ||
          p.dy > _size.height + margin;
    });
  }

  bool _hitsStar(DriftBody body) =>
      (body.position - _star).distance < body.radius + starRadius;

  void _spawn(
    List<DriftBody> into, {
    required double baseSpeed,
    required double radius,
  }) {
    final spawn = _edgeSpawnPosition();
    final target = Offset(_size.width / 2, _size.height / 2);
    var direction = target - spawn;
    final length = direction.distance;
    if (length > 0) {
      direction = direction / length;
    }
    into.add(
      DriftBody(
        id: _nextId++,
        position: spawn,
        velocity: direction * (baseSpeed * _speedMultiplier),
        radius: radius,
      ),
    );
  }

  Offset _edgeSpawnPosition() {
    switch (_random.nextInt(4)) {
      case 0:
        return Offset(_random.nextDouble() * _size.width, -40);
      case 1:
        return Offset(_size.width + 40, _random.nextDouble() * _size.height);
      case 2:
        return Offset(_random.nextDouble() * _size.width, _size.height + 40);
      default:
        return Offset(-40, _random.nextDouble() * _size.height);
    }
  }

  void _endRun() {
    if (isGameOver.value) {
      return;
    }
    isGameOver.value = true;
    onObstacleHit();
  }

  void restart() {
    obstacles.clear();
    fragments.clear();
    _survivalTime = 0;
    _fragmentScore = 0;
    _fragmentsCollected = 0;
    _obstacleTimer = 1.4;
    _fragmentTimer = 1.8;
    _obstacleInterval = 1.6;
    _fragmentInterval = 2.2;
    _speedMultiplier = 1;
    _nextDifficultyBump = _difficultyStep;
    _star = Offset(_size.width / 2, _size.height / 2);
    score.value = 0;
    isGameOver.value = false;
  }

  void dispose() {
    score.dispose();
    isGameOver.dispose();
  }
}
