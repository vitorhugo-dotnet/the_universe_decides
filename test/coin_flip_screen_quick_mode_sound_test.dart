import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';

void main() {
  Widget buildApp(Widget home) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  void enableReducedMotion(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  // The screen's shell renders CoinRuneRings, whose rings repeat forever
  // unless MediaQuery.disableAnimations is set, so pumpAndSettle never
  // quiesces while exercising the normal (non reduced-motion) impact path.
  // Drive a bounded number of frames instead — comfortably more than the
  // ~1.24s rise+land flight takes — then assert directly.
  Future<void> pumpCoinFlightFrames(WidgetTester tester) async {
    for (var i = 0; i < 150; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  testWidgets(
    'quick mode with the normal animated impact does not play the decision sound',
    (tester) async {
      final sound = _RecordingSoundEffectsNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomOrgServiceProvider.overrideWith(
              (ref) => _FakeRandomOrgService(0),
            ),
            soundEffectsProvider.overrideWith(() => sound),
          ],
          child: buildApp(
            const CoinFlipScreen(
              quickMode: true,
              autoStart: true,
              autoClose: false,
            ),
          ),
        ),
      );
      await pumpCoinFlightFrames(tester);

      expect(sound.playDecisionCallCount, 0);
    },
  );

  testWidgets('reduced-motion quick mode does not play the decision sound', (
    tester,
  ) async {
    final sound = _RecordingSoundEffectsNotifier();
    enableReducedMotion(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith(
            (ref) => _FakeRandomOrgService(1),
          ),
          soundEffectsProvider.overrideWith(() => sound),
        ],
        child: buildApp(
          const CoinFlipScreen(
            quickMode: true,
            autoStart: true,
            autoClose: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(sound.playDecisionCallCount, 0);
  });

  testWidgets('normal mode with the animated impact still plays the decision sound', (
    tester,
  ) async {
    final sound = _RecordingSoundEffectsNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith(
            (ref) => _FakeRandomOrgService(0),
          ),
          soundEffectsProvider.overrideWith(() => sound),
        ],
        child: buildApp(const CoinFlipScreen()),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Flip a coin'));
    await pumpCoinFlightFrames(tester);

    expect(sound.playDecisionCallCount, 1);
  });

  testWidgets('reduced-motion normal mode still plays the decision sound', (
    tester,
  ) async {
    final sound = _RecordingSoundEffectsNotifier();
    enableReducedMotion(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith(
            (ref) => _FakeRandomOrgService(1),
          ),
          soundEffectsProvider.overrideWith(() => sound),
        ],
        child: buildApp(const CoinFlipScreen()),
      ),
    );
    await tester.tap(find.text('Flip a coin'));
    await tester.pumpAndSettle();

    expect(sound.playDecisionCallCount, 1);
  });
}

class _RecordingSoundEffectsNotifier extends SoundEffectsNotifier {
  int playDecisionCallCount = 0;

  @override
  bool build() => true;

  @override
  Future<void> playDecision() async {
    playDecisionCallCount++;
  }
}

class _FakeRandomOrgService extends RandomOrgService {
  _FakeRandomOrgService(this._result)
    : super(client: MockClient((_) async => http.Response('', 200)));

  final int _result;

  @override
  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async => [_result];

  @override
  void dispose() {}
}
