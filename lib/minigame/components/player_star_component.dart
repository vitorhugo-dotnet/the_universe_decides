import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerStarComponent extends PositionComponent with CollisionCallbacks {
  PlayerStarComponent({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2.all(_radius * 2),
        anchor: Anchor.center,
      );

  static const double _radius = 14;

  final _paint = Paint()..color = const Color(0xFFFCE38A);
  final _glowPaint = Paint()..color = const Color(0x66FCE38A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: _radius));
  }

  void moveTo(Vector2 target) {
    position = target;
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    canvas.drawCircle(center, _radius * 1.8, _glowPaint);
    canvas.drawCircle(center, _radius, _paint);
  }
}
