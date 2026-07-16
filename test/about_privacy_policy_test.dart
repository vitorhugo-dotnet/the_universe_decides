import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/about_me_screen.dart';
import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';

void main() {
  testWidgets('about screen exposes the privacy policy link', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(),
          ),
          quickAccessServiceProvider.overrideWith(
            (ref) => _FakeQuickAccessService(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AboutMeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final link = find.widgetWithText(TextButton, 'Privacy Policy');

    expect(link, findsOneWidget);
    expect(tester.widget<TextButton>(link).onPressed, isNotNull);
  });
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
      bio: 'Developer',
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
  ) async {
    return QuickAccessTileRequestResult.added;
  }
}
