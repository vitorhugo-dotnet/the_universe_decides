import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theuniversedecides/services/github_profile_service.dart';

void main() {
  test('fetchProfile parses the GitHub response', () async {
    final service = GitHubProfileService(
      client: MockClient(
        (_) async => http.Response('''
{"login":"vitorhugo-dotnet","avatar_url":"https://avatars.githubusercontent.com/u/1?v=4","name":"Vitor Hugo","bio":"Developer","html_url":"https://github.com/vitorhugo-dotnet"}
''', 200),
      ),
    );

    addTearDown(service.dispose);

    final profile = await service.fetchProfile(username: 'vitorhugo-dotnet');

    expect(profile.login, 'vitorhugo-dotnet');
    expect(profile.avatarUrl, 'https://avatars.githubusercontent.com/u/1?v=4');
    expect(profile.name, 'Vitor Hugo');
    expect(profile.bio, 'Developer');
    expect(profile.profileUrl, 'https://github.com/vitorhugo-dotnet');
  });

  test('fetchProfile throws on not found users', () async {
    final service = GitHubProfileService(
      client: MockClient((_) async => http.Response('Not Found', 404)),
    );

    addTearDown(service.dispose);

    expect(
      service.fetchProfile(username: 'missing-user'),
      throwsA(isA<StateError>()),
    );
  });
}
