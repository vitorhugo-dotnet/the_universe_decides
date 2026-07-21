import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:theuniversedecides/minigame/entropy_drift_game.dart';
import 'package:theuniversedecides/minigame/components/player_star_component.dart';

class BlackHoleComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<EntropyDriftGame> {
  BlackHoleComponent({
    required Vector2 startPosition,
    required this.velocity,
    required this.onHitPlayer,
  }) : super(
         position: startPosition,
         size: Vector2.all(_radius * 2),
         anchor: Anchor.center,
       );

  static const double _radius = 22;

  final Vector2 velocity;
  final VoidCallback onHitPlayer;

  final _corePaint = Paint()..color = const Color(0xFF090611);
  final _ringPaint = Paint()
    ..color = const Color(0xFF7A4FFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: _radius));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    final bounds = game.size;
    const margin = 80.0;
    if (position.x < -margin ||
        position.y < -margin ||
        position.x > bounds.x + margin ||
        position.y > bounds.y + margin) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerStarComponent) {
      onHitPlayer();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    canvas.drawCircle(center, _radius, _corePaint);
    canvas.drawCircle(center, _radius * 0.7, _ringPaint);
  }
}
