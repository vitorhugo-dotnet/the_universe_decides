import 'dart:io';

import 'package:flutter/foundation.dart';
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
    } catch (_) {
      _authenticated = false;
      _debugLog(
        'Play Games sign-in failed; continuing with offline gameplay. '
        'Check account eligibility, tester access, network connectivity, and '
        'the Android OAuth certificate SHA-1.',
      );
      return;
    }

    try {
      _authenticated = await _gateway.isSignedIn();
    } catch (_) {
      _authenticated = false;
      _debugLog(
        'Play Games could not verify authentication; continuing offline. '
        'Check the APP_ID manifest metadata and Play Games project setup.',
      );
      return;
    }

    if (!_authenticated) {
      _debugLog(
        'Play Games sign-in completed without an authenticated account. '
        'Check tester access, published Play Games configuration, APP_ID, and '
        'OAuth certificate SHA-1.',
      );
      return;
    }
    await _unlock(
      EntropyDriftPlayGamesIds.discovered,
      feature: 'discovery achievement',
    );
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
    await _unlock(
      EntropyDriftPlayGamesIds.firstDrift,
      feature: 'first-run achievement',
    );
    if (survivalDuration >= const Duration(seconds: 30)) {
      await _unlock(
        EntropyDriftPlayGamesIds.survivor30s,
        feature: 'survival achievement',
      );
    }
    if (fragmentsCollected >= 10) {
      await _unlock(
        EntropyDriftPlayGamesIds.fragmentCollector,
        feature: 'fragment achievement',
      );
    }
    if (score >= 100) {
      await _unlock(
        EntropyDriftPlayGamesIds.entropyMaster,
        feature: 'score achievement',
      );
    }
    final leaderboardId = _leaderboardId;
    if (leaderboardId.isEmpty) {
      _debugLog(
        'Play Games leaderboard is disabled because its resource ID is not '
        'configured; achievements and offline gameplay remain available.',
      );
      return;
    }
    try {
      await _gateway.submitScore(leaderboardId, score);
    } catch (_) {
      _debugLog('Play Games score submission failed; local score was kept.');
    }
  }

  Future<void> showLeaderboard() async {
    if (!_authenticated || _leaderboardId.isEmpty) {
      return;
    }
    try {
      await _gateway.showLeaderboard(_leaderboardId);
    } catch (_) {
      _debugLog('Play Games leaderboard UI could not be opened.');
    }
  }

  Future<void> _unlock(String id, {required String feature}) async {
    if (!_authenticated) {
      return;
    }
    if (id.isEmpty) {
      _debugLog(
        'Play Games $feature is disabled because its resource ID is not '
        'configured; other online features remain available.',
      );
      return;
    }
    try {
      await _gateway.unlock(id);
    } catch (_) {
      _debugLog('Play Games $feature unlock failed; gameplay continues.');
    }
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[EntropyDriftPlayGames] $message');
    }
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
