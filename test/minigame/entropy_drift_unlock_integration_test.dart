import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theuniversedecides/main.dart';
import 'package:theuniversedecides/minigame/entropy_drift_screen.dart';
import 'package:theuniversedecides/minigame/entropy_drift_play_games_service.dart';
import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/widgets/ritual_bottom_nav.dart';

import '../support/fake_webview_platform.dart';

void main() {
  setUp(FakeWebViewPlatform.register);

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  testWidgets('normal taps select tabs and a long press opens Entropy Drift', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final playGamesService = _FakePlayGamesService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith(
            (ref) => _FakeRandomOrgService(),
          ),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(),
          ),
          quickAccessServiceProvider.overrideWith(
            (ref) => _FakeQuickAccessService(),
          ),
          entropyDriftPlayGamesProvider.overrideWithValue(playGamesService),
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.pumpAndSettle();

    final navButtons = find.descendant(
      of: find.byType(RitualBottomNav),
      matching: find.byType(InkWell),
    );
    expect(navButtons, findsNWidgets(6));
    expect(find.byIcon(Icons.auto_awesome), findsWidgets);
    expect(find.byType(EntropyDriftScreen), findsNothing);
    expect(playGamesService.authenticationAttempts, 0);

    await tester.longPress(navButtons.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(EntropyDriftScreen), findsOneWidget);
    expect(playGamesService.authenticationAttempts, 1);
  });
}

class _FakePlayGamesService extends EntropyDriftPlayGamesService {
  int authenticationAttempts = 0;

  @override
  Future<void> authenticateOnGameOpen() async {
    authenticationAttempts++;
  }
}

class _FakeRandomOrgService extends RandomOrgService {
  _FakeRandomOrgService()
    : super(
        client: MockClient((_) async => http.Response('', 200)),
        random: math.Random(1),
      );

  @override
  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async => [1];
}

class _FakeGitHubProfileService extends GitHubProfileService {
  _FakeGitHubProfileService()
    : super(client: MockClient((_) async => http.Response('', 200)));

  @override
  Future<GitHubProfile> fetchProfile({required String username}) async {
    return const GitHubProfile(
      login: 'vitorhugo-dotnet',
      avatarUrl: '',
      name: 'Vitor Hugo',
    );
  }

  @override
  void dispose() {}
}

class _FakeQuickAccessService implements QuickAccessService {
  @override
  Stream<QuickAccessAction> get actions => const Stream.empty();

  @override
  Future<QuickAccessAction?> getInitialAction() async => null;

  @override
  Future<QuickAccessTileRequestResult> requestTile(
    QuickAccessAction action,
  ) async => QuickAccessTileRequestResult.added;
}
