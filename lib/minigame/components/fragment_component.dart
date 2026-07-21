import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:theuniversedecides/minigame/entropy_drift_game.dart';
import 'package:theuniversedecides/minigame/components/player_star_component.dart';

class FragmentComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<EntropyDriftGame> {
  FragmentComponent({
    required Vector2 startPosition,
    required this.velocity,
    required this.onCollected,
  }) : super(
         position: startPosition,
         size: Vector2.all(_radius * 2),
         anchor: Anchor.center,
       );

  static const double _radius = 8;

  final Vector2 velocity;
  final VoidCallback onCollected;

  final _paint = Paint()..color = const Color(0xFFF9B44C);

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
      onCollected();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle((size / 2).toOffset(), _radius, _paint);
  }
}
