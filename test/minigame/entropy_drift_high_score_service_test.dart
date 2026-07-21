import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theuniversedecides/minigame/entropy_drift_high_score_service.dart';

void main() {
  test('loads a persisted high score', () async {
    SharedPreferences.setMockInitialValues({'entropy_drift_high_score': 40});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(entropyDriftHighScoreProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(entropyDriftHighScoreProvider), 40);
  });

  test('submitScore persists a new high score and ignores a lower one', () async {
    SharedPreferences.setMockInitialValues({'entropy_drift_high_score': 40});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(entropyDriftHighScoreProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await notifier.submitScore(20);
    expect(container.read(entropyDriftHighScoreProvider), 40);

    await notifier.submitScore(75);
    expect(container.read(entropyDriftHighScoreProvider), 75);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('entropy_drift_high_score'), 75);
  });

  test('defaults to 0 with nothing persisted', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(entropyDriftHighScoreProvider), 0);
  });
}
