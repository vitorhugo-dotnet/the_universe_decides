import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theuniversedecides/main.dart';
import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

void main() {
  testWidgets('coin screen uses the random service', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final service = _FakeRandomOrgService([
      [1],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
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
    await tester.tap(find.text('Flip a coin'));
    await tester.pumpAndSettle();

    expect(find.text('TAILS'), findsWidgets);
    expect(service.requests, [(1, 0, 1)]);
  });

  testWidgets('dice screen requests the selected dice configuration', (
    WidgetTester tester,
  ) async {
    final service = _FakeRandomOrgService([
      [2, 3],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
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
    await tester.tap(find.text('Dice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roll dice'));
    await tester.pumpAndSettle();

    expect(find.text('Total: 5'), findsOneWidget);
    expect(service.requests, [(2, 1, 20)]);
  });

  testWidgets('card draw screen requests a playing card from the full deck', (
    WidgetTester tester,
  ) async {
    final service = _FakeRandomOrgService([
      [52],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
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
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Draw a card'));

    expect(find.text('K♠'), findsWidgets);
    expect(find.byIcon(CupertinoIcons.suit_spade_fill), findsWidgets);
    expect(service.requests, [(1, 1, 52)]);
  });

  testWidgets('list screen picks one item through the random service', (
    WidgetTester tester,
  ) async {
    final service = _FakeRandomOrgService([
      [1],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
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
    await tester.tap(find.text('Lists'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Chá');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Café');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose for me'));
    await tester.pumpAndSettle();

    expect(find.text('Café'), findsWidgets);
    expect(service.requests, [(1, 0, 1)]);
  });

  testWidgets('tarot screen requests one card from the 78-card deck', (
    WidgetTester tester,
  ) async {
    final service = _FakeRandomOrgService([
      [23],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
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
    await tester.tap(find.text('Tarot'));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Draw a card'));

    expect(find.text('Ace of Wands'), findsWidgets);
    expect(find.text('Minor Arcana'), findsWidgets);
    expect(service.requests, [(1, 1, 78)]);
  });

  testWidgets('about tab loads profile and main screen has no top bar', (
    WidgetTester tester,
  ) async {
    final randomService = _FakeRandomOrgService(const []);
    final githubService = _FakeGitHubProfileService(
      const GitHubProfile(
        login: 'vitorhugo-dotnet',
        avatarUrl: '',
        name: 'Vitor Hugo',
        bio: 'Developer',
      ),
    );
    final quickAccessService = _FakeQuickAccessService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => randomService),
          githubProfileServiceProvider.overrideWith((ref) => githubService),
          quickAccessServiceProvider.overrideWith((ref) => quickAccessService),
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('About me'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Vitor Hugo'), findsOneWidget);
    expect(find.text('@vitorhugo-dotnet'), findsOneWidget);
    expect(find.text('Add coin'), findsOneWidget);
    expect(find.text('Add d20'), findsOneWidget);
    expect(find.byIcon(Icons.monetization_on), findsOneWidget);
    expect(find.byIcon(Icons.casino), findsOneWidget);
    expect(githubService.usernames, ['vitorhugo-dotnet']);
  });

  testWidgets('quick dice action opens dice and rolls d20 by default', (
    WidgetTester tester,
  ) async {
    final randomService = _FakeRandomOrgService([
      [17],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => randomService),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
              ),
            ),
          ),
          quickAccessServiceProvider.overrideWith(
            (ref) =>
                _FakeQuickAccessService(initialAction: QuickAccessAction.dice),
          ),
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total: 17'), findsOneWidget);
    expect(randomService.requests, [(1, 1, 20)]);
  });

  testWidgets('app shows portuguese labels for pt-BR locale', (
    WidgetTester tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('pt')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith(
            (ref) => _FakeRandomOrgService(const []),
          ),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
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

    expect(find.text('Moeda'), findsWidgets);
    expect(find.text('Cartas'), findsOneWidget);
    expect(find.text('Jogar uma moeda'), findsOneWidget);
    expect(find.text('Sobre mim'), findsOneWidget);
  });

  testWidgets('app shows english labels for en locale', (
    WidgetTester tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith(
            (ref) => _FakeRandomOrgService(const []),
          ),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
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

    expect(find.text('Coin'), findsWidgets);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Flip a coin'), findsOneWidget);
    expect(find.text('About me'), findsOneWidget);
  });

  testWidgets(
    'app shows acrylic fallback notice when random.org is unavailable',
    (WidgetTester tester) async {
      final randomService = _FakeRandomOrgService(const []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomOrgServiceProvider.overrideWith((ref) => randomService),
            githubProfileServiceProvider.overrideWith(
              (ref) => _FakeGitHubProfileService(
                const GitHubProfile(
                  login: 'vitorhugo-dotnet',
                  avatarUrl: '',
                  name: 'Vitor Hugo',
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

      randomService.emitFallbackNotice();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.text('Random.org is unavailable. Using local randomness.'),
        findsOneWidget,
      );
    },
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class _FakeRandomOrgService extends RandomOrgService {
  _FakeRandomOrgService(List<List<int>> responses)
    : _responses = Queue.of(responses),
      super(
        client: MockClient((_) async => http.Response('', 200)),
        random: math.Random(1),
      );

  final Queue<List<int>> _responses;
  final List<(int, int, int)> requests = [];
  final StreamController<RandomOrgFallbackEvent> _fallbackController =
      StreamController<RandomOrgFallbackEvent>.broadcast();

  @override
  Stream<RandomOrgFallbackEvent> get fallbackEvents =>
      _fallbackController.stream;

  @override
  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async {
    requests.add((count, min, max));
    return _responses.isEmpty ? const [] : _responses.removeFirst();
  }

  void emitFallbackNotice() {
    _fallbackController.add(const RandomOrgFallbackEvent());
  }

  @override
  void dispose() {
    _fallbackController.close();
  }
}

class _FakeGitHubProfileService extends GitHubProfileService {
  _FakeGitHubProfileService(this.profile)
    : super(client: MockClient((_) async => http.Response('', 200)));

  final GitHubProfile profile;
  final List<String> usernames = [];

  @override
  Future<GitHubProfile> fetchProfile({required String username}) async {
    usernames.add(username);
    return profile;
  }

  @override
  void dispose() {}
}

class _FakeQuickAccessService implements QuickAccessService {
  _FakeQuickAccessService({this.initialAction});

  final QuickAccessAction? initialAction;

  @override
  Stream<QuickAccessAction> get actions => const Stream.empty();

  @override
  Future<QuickAccessAction?> getInitialAction() async => initialAction;

  @override
  Future<QuickAccessTileRequestResult> requestTile(
    QuickAccessAction action,
  ) async {
    return QuickAccessTileRequestResult.added;
  }
}
