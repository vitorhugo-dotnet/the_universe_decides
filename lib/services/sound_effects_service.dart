import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final soundEffectsProvider = NotifierProvider<SoundEffectsNotifier, bool>(
  SoundEffectsNotifier.new,
);

class SoundEffectsNotifier extends Notifier<bool> {
  static const _key = 'sound_effects_enabled';
  late final AudioPlayer _player;
  bool _playing = false;

  @override
  bool build() {
    _player = AudioPlayer();
    unawaited(_load());
    ref.onDispose(_player.dispose);
    return true;
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    state = preferences.getBool(_key) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_key, enabled);
  }

  Future<void> playDecision() async {
    if (!state || _playing) return;
    _playing = true;
    try {
      await _player.setAudioContext(
        AudioContextConfig(
          respectSilence: true,
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );
      await _player.play(AssetSource('sounds/decision.wav'));
      await _player.onPlayerComplete.first.timeout(
        const Duration(seconds: 1),
        onTimeout: () {},
      );
    } catch (_) {
      // Sound is optional: unavailable audio must never affect a decision.
    } finally {
      _playing = false;
    }
  }
}
