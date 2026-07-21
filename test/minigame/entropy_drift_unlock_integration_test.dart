import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theuniversedecides/main.dart';
import 'package:theuniversedecides/minigame/entropy_drift_screen.dart';
import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

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

  testWidgets('7 taps on the header glyph opens Entropy Drift', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

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
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.pumpAndSettle();

    final glyph = find.byIcon(Icons.auto_awesome);
    expect(glyph, findsOneWidget);

    for (var i = 0; i < 7; i++) {
      await tester.tap(glyph);
      await tester.pump(const Duration(milliseconds: 100));
    }
    // The glyph's pulse animation runs forward then reverse before pushing
    // the route; each stage needs its own pump to resolve its awaited
    // AnimationController Future.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(EntropyDriftScreen), findsOneWidget);
  });
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
