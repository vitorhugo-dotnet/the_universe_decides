import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final entropyDriftHighScoreProvider =
    NotifierProvider<EntropyDriftHighScoreNotifier, int>(
      EntropyDriftHighScoreNotifier.new,
    );

class EntropyDriftHighScoreNotifier extends Notifier<int> {
  static const _key = 'entropy_drift_high_score';

  @override
  int build() {
    unawaited(_load());
    return 0;
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    state = preferences.getInt(_key) ?? 0;
  }

  Future<void> submitScore(int score) async {
    if (score <= state) {
      return;
    }
    state = score;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_key, score);
  }
}
