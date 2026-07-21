import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'package:theuniversedecides/minigame/components/black_hole_component.dart';
import 'package:theuniversedecides/minigame/components/fragment_component.dart';
import 'package:theuniversedecides/minigame/components/playfield_drag_area.dart';
import 'package:theuniversedecides/minigame/components/player_star_component.dart';

class EntropyDriftGame extends FlameGame with HasCollisionDetection {
  EntropyDriftGame({
    required this.onObstacleHit,
    required this.onFragmentCollected,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Called once when the star collides with a black hole, before the game
  /// pauses. The screen uses this to trigger haptics/sound.
  final VoidCallback onObstacleHit;

  /// Called every time a fragment is collected. The screen uses this to
  /// trigger light haptics.
  final VoidCallback onFragmentCollected;

  final math.Random _random;

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<bool> isGameOver = ValueNotifier<bool>(false);

  static const double _difficultyStep = 10;
  static const double _minObstacleInterval = 0.6;
  static const double _minFragmentInterval = 1.0;
  static const double _maxSpeedMultiplier = 2.5;

  late PlayerStarComponent _star;

  double _survivalTime = 0;
  int _fragmentScore = 0;
  double _obstacleTimer = 1.4;
  double _fragmentTimer = 1.8;
  double _obstacleInterval = 1.6;
  double _fragmentInterval = 2.2;
  double _speedMultiplier = 1;
  double _nextDifficultyBump = _difficultyStep;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _star = PlayerStarComponent(startPosition: size / 2, clampBounds: size);
    await world.addAll([
      PlayfieldDragArea(star: _star)..size = size,
      _star,
    ]);
  }

  @override
  void onRemove() {
    score.dispose();
    isGameOver.dispose();
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver.value) {
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
      _spawnObstacle();
    }

    _fragmentTimer -= dt;
    if (_fragmentTimer <= 0) {
      _fragmentTimer = _fragmentInterval;
      _spawnFragment();
    }

    score.value = (_survivalTime * 2).floor() + _fragmentScore;
  }

  void _spawnObstacle() {
    final spawn = _edgeSpawnPosition();
    final velocity = _inwardVelocity(spawn, baseSpeed: 70);
    world.add(
      BlackHoleComponent(
        startPosition: spawn,
        velocity: velocity,
        onHitPlayer: _endRun,
      ),
    );
  }

  void _spawnFragment() {
    final spawn = _edgeSpawnPosition();
    final velocity = _inwardVelocity(spawn, baseSpeed: 50);
    world.add(
      FragmentComponent(
        startPosition: spawn,
        velocity: velocity,
        onCollected: _collectFragment,
      ),
    );
  }

  Vector2 _edgeSpawnPosition() {
    final edge = _random.nextInt(4);
    return switch (edge) {
      0 => Vector2(_random.nextDouble() * size.x, -40),
      1 => Vector2(size.x + 40, _random.nextDouble() * size.y),
      2 => Vector2(_random.nextDouble() * size.x, size.y + 40),
      _ => Vector2(-40, _random.nextDouble() * size.y),
    };
  }

  Vector2 _inwardVelocity(Vector2 spawn, {required double baseSpeed}) {
    final target = size / 2;
    final direction = (target - spawn)..normalize();
    return direction * baseSpeed * _speedMultiplier;
  }

  void _collectFragment() {
    _fragmentScore += 5;
    onFragmentCollected();
  }

  void _endRun() {
    if (isGameOver.value) {
      return;
    }
    isGameOver.value = true;
    pauseEngine();
    onObstacleHit();
  }

  void restart() {
    world.removeAll(world.children.toList());
    isGameOver.value = false;
    score.value = 0;
    _survivalTime = 0;
    _fragmentScore = 0;
    _obstacleTimer = 1.4;
    _fragmentTimer = 1.8;
    _obstacleInterval = 1.6;
    _fragmentInterval = 2.2;
    _speedMultiplier = 1;
    _nextDifficultyBump = _difficultyStep;
    _star = PlayerStarComponent(startPosition: size / 2, clampBounds: size);
    world.addAll([
      PlayfieldDragArea(star: _star)..size = size,
      _star,
    ]);
    resumeEngine();
  }
}
