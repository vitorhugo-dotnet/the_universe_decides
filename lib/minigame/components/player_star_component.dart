import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerStarComponent extends PositionComponent with CollisionCallbacks {
  PlayerStarComponent({
    required Vector2 startPosition,
    required this.clampBounds,
  }) : super(
         position: startPosition,
         size: Vector2.all(_radius * 2),
         anchor: Anchor.center,
       );

  static const double _radius = 14;

  /// The size of the play field the star is confined to. `moveTo` clamps
  /// the star's position so it never drags past these bounds.
  final Vector2 clampBounds;

  final _paint = Paint()..color = const Color(0xFFFCE38A);
  final _glowPaint = Paint()..color = const Color(0x66FCE38A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: _radius));
  }

  void moveTo(Vector2 target) {
    final halfSize = size / 2;
    position = Vector2(
      target.x.clamp(halfSize.x, clampBounds.x - halfSize.x),
      target.y.clamp(halfSize.y, clampBounds.y - halfSize.y),
    );
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    canvas.drawCircle(center, _radius * 1.8, _glowPaint);
    canvas.drawCircle(center, _radius, _paint);
  }
}
