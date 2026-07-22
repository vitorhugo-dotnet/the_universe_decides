import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/minigame/entropy_drift_play_games_service.dart';

void main() {
  test('does not call game APIs before authentication', () async {
    final gateway = _RecordingGateway();
    final service = EntropyDriftPlayGamesService(
      gateway: gateway,
      isAndroid: true,
      leaderboardId: 'leaderboard',
    );

    await service.completeRun(
      score: 150,
      survivalDuration: const Duration(seconds: 40),
      fragmentsCollected: 12,
    );

    expect(gateway.calls, isEmpty);
  });

  test('authentication failure is contained and attempted only once', () async {
    final gateway = _RecordingGateway(throwOnSignIn: true);
    final service = EntropyDriftPlayGamesService(
      gateway: gateway,
      isAndroid: true,
      leaderboardId: 'leaderboard',
    );

    await service.authenticateOnGameOpen();
    await service.authenticateOnGameOpen();

    expect(service.isAuthenticated, isFalse);
    expect(gateway.calls, ['signIn']);
  });

  test('a run submits online at most once', () async {
    final gateway = _RecordingGateway(signedIn: true);
    final service = EntropyDriftPlayGamesService(
      gateway: gateway,
      isAndroid: true,
      leaderboardId: 'leaderboard',
    );
    await service.authenticateOnGameOpen();
    service.startRun();

    await service.completeRun(
      score: 150,
      survivalDuration: const Duration(seconds: 40),
      fragmentsCollected: 12,
    );
    await service.completeRun(
      score: 150,
      survivalDuration: const Duration(seconds: 40),
      fragmentsCollected: 12,
    );

    expect(gateway.calls.where((call) => call == 'score'), hasLength(1));
  });
}

class _RecordingGateway implements EntropyDriftGamesGateway {
  _RecordingGateway({this.signedIn = false, this.throwOnSignIn = false});

  final bool signedIn;
  final bool throwOnSignIn;
  final List<String> calls = [];

  @override
  Future<bool> isSignedIn() async {
    calls.add('isSignedIn');
    return signedIn;
  }

  @override
  Future<void> signIn() async {
    calls.add('signIn');
    if (throwOnSignIn) throw StateError('offline');
  }

  @override
  Future<void> showLeaderboard(String leaderboardId) async =>
      calls.add('leaderboard');

  @override
  Future<void> submitScore(String leaderboardId, int score) async =>
      calls.add('score');

  @override
  Future<void> unlock(String id) async => calls.add('unlock');
}
