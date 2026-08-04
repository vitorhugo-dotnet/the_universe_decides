import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/minigame/entropy_drift_engine.dart';

void main() {
  EntropyDriftEngine build({VoidCallback? onHit, VoidCallback? onCollect}) {
    final engine = EntropyDriftEngine(
      onObstacleHit: onHit ?? () {},
      onFragmentCollected: onCollect ?? () {},
    );
    engine.setSize(const Size(400, 800));
    return engine;
  }

  test('centres the star on first layout and clamps movement to the field', () {
    final engine = build();
    addTearDown(engine.dispose);

    expect(engine.star, const Offset(200, 400));

    engine.moveStar(const Offset(-100, 5000));
    expect(engine.star.dx, EntropyDriftEngine.starRadius);
    expect(engine.star.dy, 800 - EntropyDriftEngine.starRadius);
  });

  test('hitting a black hole ends the run once', () {
    var hits = 0;
    final engine = build(onHit: () => hits++);
    addTearDown(engine.dispose);

    engine.obstacles.add(
      DriftBody(
        id: 0,
        position: engine.star,
        velocity: Offset.zero,
        radius: EntropyDriftEngine.obstacleRadius,
      ),
    );

    engine.tick(0.016);
    engine.tick(0.016);

    expect(engine.isGameOver.value, isTrue);
    expect(hits, 1);
  });

  test('collecting a fragment adds 5 to the score and removes it', () {
    var collected = 0;
    final engine = build(onCollect: () => collected++);
    addTearDown(engine.dispose);

    engine.fragments.add(
      DriftBody(
        id: 0,
        position: engine.star,
        velocity: Offset.zero,
        radius: EntropyDriftEngine.fragmentRadius,
      ),
    );

    engine.tick(0.016);

    expect(collected, 1);
    expect(engine.fragments, isEmpty);
    expect(engine.score.value, greaterThanOrEqualTo(5));
  });

  test('does not advance after game over', () {
    final engine = build();
    addTearDown(engine.dispose);

    engine.isGameOver.value = true;
    final before = engine.score.value;
    engine.tick(1.0);

    expect(engine.score.value, before);
    expect(engine.obstacles, isEmpty);
  });
}
