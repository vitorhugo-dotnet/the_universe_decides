import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theuniversedecides/main.dart';
import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

import 'support/fake_webview_platform.dart';

Future<void> _pump(WidgetTester tester, List<List<int>> responses) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(820, 1740);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        randomOrgServiceProvider.overrideWith(
          (ref) => _FakeRandomOrgService(responses),
        ),
        githubProfileServiceProvider.overrideWith(
          (ref) => _FakeGitHubProfileService(
            const GitHubProfile(
              login: 'vitorhugo-dotnet',
              avatarUrl: '',
              name: 'Vitor Hugo',
              bio: 'Creator of The Universe Decides.',
            ),
          ),
        ),
        quickAccessServiceProvider.overrideWith(
          (ref) => _FakeQuickAccessService(),
        ),
      ],
      child: const UniverseDecidesApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // Golden pixels depend on the platform's font rasterizer; keep these
  // captures available locally while avoiding false failures on Linux CI.
  final skipGoldenOnCi = Platform.environment['CI'] == 'true';

  // The dice screen embeds a real WebView; register an in-memory platform
  // fake so the captured app can build it without a native surface.
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

  testWidgets('capture coin', (tester) async {
    await _pump(tester, [
      [1],
    ]);
    await tester.tap(find.text('Flip a coin'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('_captures/coin.png'),
    );
  }, skip: skipGoldenOnCi);

  testWidgets('capture dice', (tester) async {
    await _pump(tester, [
      [2, 3, 5],
    ]);
    await tester.tap(find.text('Dice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roll dice'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('_captures/dice.png'),
    );
  }, skip: skipGoldenOnCi);

  testWidgets('capture cards', (tester) async {
    await _pump(tester, [
      [52],
    ]);
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draw a card'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('_captures/cards.png'),
    );
  }, skip: skipGoldenOnCi);

  testWidgets('capture lists', (tester) async {
    await _pump(tester, [
      [1],
    ]);
    await tester.tap(find.text('Lists'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pizza');
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sushi');
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Let the universe choose'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('_captures/lists.png'),
    );
  }, skip: skipGoldenOnCi);

  testWidgets('capture tarot', (tester) async {
    await _pump(tester, [
      [23],
    ]);
    await tester.tap(find.text('Tarot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reveal card'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('_captures/tarot.png'),
    );
  }, skip: skipGoldenOnCi);

  testWidgets('capture about', (tester) async {
    await _pump(tester, const []);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('_captures/about.png'),
    );
  }, skip: skipGoldenOnCi);
}

class _FakeRandomOrgService extends RandomOrgService {
  _FakeRandomOrgService(List<List<int>> responses)
    : _responses = Queue.of(responses),
      super(
        client: MockClient((_) async => http.Response('', 200)),
        random: math.Random(1),
      );

  final Queue<List<int>> _responses;

  @override
  Stream<RandomOrgFallbackEvent> get fallbackEvents => const Stream.empty();

  @override
  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async => _responses.isEmpty ? const [] : _responses.removeFirst();

  @override
  void dispose() {}
}

class _FakeGitHubProfileService extends GitHubProfileService {
  _FakeGitHubProfileService(this.profile)
    : super(client: MockClient((_) async => http.Response('', 200)));

  final GitHubProfile profile;

  @override
  Future<GitHubProfile> fetchProfile({required String username}) async =>
      profile;

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
