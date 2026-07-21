import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/minigame/entropy_drift_unlock_notifier.dart';

void main() {
  test('7 fast taps unlock, slow taps reset the streak', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(entropyDriftUnlockProvider.notifier);
    var now = DateTime(2026, 1, 1, 12, 0, 0);

    for (var i = 0; i < 5; i++) {
      final unlocked = notifier.registerTap(now: now);
      expect(unlocked, isFalse);
      now = now.add(const Duration(milliseconds: 200));
    }
    expect(container.read(entropyDriftUnlockProvider), 5);

    // A gap longer than the window resets the streak to 1 (the tap itself
    // still counts), it does not unlock early.
    now = now.add(const Duration(seconds: 3));
    final resetTap = notifier.registerTap(now: now);
    expect(resetTap, isFalse);
    expect(container.read(entropyDriftUnlockProvider), 1);

    for (var i = 0; i < 5; i++) {
      now = now.add(const Duration(milliseconds: 200));
      notifier.registerTap(now: now);
    }
    now = now.add(const Duration(milliseconds: 200));
    final unlocked = notifier.registerTap(now: now);
    expect(unlocked, isTrue);
    expect(container.read(entropyDriftUnlockProvider), 0);
  });

  test('fewer than 7 taps never unlocks', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(entropyDriftUnlockProvider.notifier);
    var now = DateTime(2026, 1, 1, 12, 0, 0);

    for (var i = 0; i < 6; i++) {
      final unlocked = notifier.registerTap(now: now);
      expect(unlocked, isFalse);
      now = now.add(const Duration(milliseconds: 100));
    }
    expect(container.read(entropyDriftUnlockProvider), 6);
  });
}
