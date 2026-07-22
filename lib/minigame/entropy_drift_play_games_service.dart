import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:games_services/games_services.dart';

/// Play Console resource IDs, supplied at build time so generated IDs never
/// leak into widgets. Empty IDs safely disable the corresponding feature.
abstract final class EntropyDriftPlayGamesIds {
  static const discovered = String.fromEnvironment(
    'PLAY_GAMES_ENTROPY_DISCOVERED_ID',
  );
  static const firstDrift = String.fromEnvironment('PLAY_GAMES_FIRST_DRIFT_ID');
  static const survivor30s = String.fromEnvironment(
    'PLAY_GAMES_SURVIVOR_30S_ID',
  );
  static const fragmentCollector = String.fromEnvironment(
    'PLAY_GAMES_FRAGMENT_COLLECTOR_ID',
  );
  static const entropyMaster = String.fromEnvironment(
    'PLAY_GAMES_ENTROPY_MASTER_ID',
  );
  static const leaderboard = String.fromEnvironment(
    'PLAY_GAMES_ENTROPY_LEADERBOARD_ID',
  );
}

final entropyDriftPlayGamesProvider = Provider<EntropyDriftPlayGamesService>(
  (ref) => EntropyDriftPlayGamesService(),
);

/// Best-effort, Android-only Play Games integration. Every public operation
/// absorbs platform/auth/network failures so the local game remains playable.
class EntropyDriftPlayGamesService {
  EntropyDriftPlayGamesService({
    EntropyDriftGamesGateway? gateway,
    bool? isAndroid,
    String leaderboardId = EntropyDriftPlayGamesIds.leaderboard,
  }) : _gateway = gateway ?? const GamesServicesGateway(),
       _isAndroid = isAndroid ?? Platform.isAndroid,
       _leaderboardId = leaderboardId;

  final EntropyDriftGamesGateway _gateway;
  final bool _isAndroid;
  final String _leaderboardId;
  bool _authenticated = false;
  bool _authenticationAttempted = false;
  bool _scoreSubmittedForRun = false;

  bool get isAuthenticated => _authenticated;

  Future<void> authenticateOnGameOpen() async {
    if (_authenticationAttempted || !_isAndroid) {
      return;
    }
    _authenticationAttempted = true;
    try {
      await _gateway.signIn();
      _authenticated = await _gateway.isSignedIn();
      if (_authenticated) {
        await _unlock(EntropyDriftPlayGamesIds.discovered);
      }
    } catch (_) {
      _authenticated = false;
    }
  }

  void startRun() => _scoreSubmittedForRun = false;

  Future<void> completeRun({
    required int score,
    required Duration survivalDuration,
    required int fragmentsCollected,
  }) async {
    if (!_authenticated || _scoreSubmittedForRun) {
      return;
    }
    _scoreSubmittedForRun = true;
    await _unlock(EntropyDriftPlayGamesIds.firstDrift);
    if (survivalDuration >= const Duration(seconds: 30)) {
      await _unlock(EntropyDriftPlayGamesIds.survivor30s);
    }
    if (fragmentsCollected >= 10) {
      await _unlock(EntropyDriftPlayGamesIds.fragmentCollector);
    }
    if (score >= 100) {
      await _unlock(EntropyDriftPlayGamesIds.entropyMaster);
    }
    final leaderboardId = _leaderboardId;
    if (leaderboardId.isEmpty) {
      return;
    }
    try {
      await _gateway.submitScore(leaderboardId, score);
    } catch (_) {}
  }

  Future<void> showLeaderboard() async {
    if (!_authenticated || _leaderboardId.isEmpty) {
      return;
    }
    try {
      await _gateway.showLeaderboard(_leaderboardId);
    } catch (_) {}
  }

  Future<void> _unlock(String id) async {
    if (!_authenticated || id.isEmpty) {
      return;
    }
    try {
      await _gateway.unlock(id);
    } catch (_) {}
  }
}

abstract interface class EntropyDriftGamesGateway {
  Future<void> signIn();
  Future<bool> isSignedIn();
  Future<void> unlock(String id);
  Future<void> submitScore(String leaderboardId, int score);
  Future<void> showLeaderboard(String leaderboardId);
}

class GamesServicesGateway implements EntropyDriftGamesGateway {
  const GamesServicesGateway();

  @override
  Future<void> signIn() async => GamesServices.signIn();

  @override
  Future<bool> isSignedIn() => GamesServices.isSignedIn;

  @override
  Future<void> unlock(String id) async => GamesServices.unlock(
    achievement: Achievement(androidID: id, percentComplete: 100),
  );

  @override
  Future<void> submitScore(String leaderboardId, int score) async =>
      GamesServices.submitScore(
        score: Score(androidLeaderboardID: leaderboardId, value: score),
      );

  @override
  Future<void> showLeaderboard(String leaderboardId) async =>
      GamesServices.showLeaderboards(androidLeaderboardID: leaderboardId);
}
