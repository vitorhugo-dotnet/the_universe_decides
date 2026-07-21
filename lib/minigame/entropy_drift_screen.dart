import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/minigame/entropy_drift_game.dart';
import 'package:theuniversedecides/minigame/entropy_drift_high_score_service.dart';
import 'package:theuniversedecides/minigame/entropy_drift_strings.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';

class EntropyDriftScreen extends ConsumerStatefulWidget {
  const EntropyDriftScreen({super.key});

  @override
  ConsumerState<EntropyDriftScreen> createState() =>
      _EntropyDriftScreenState();
}

class _EntropyDriftScreenState extends ConsumerState<EntropyDriftScreen> {
  late final EntropyDriftGame _game;

  @override
  void initState() {
    super.initState();
    _game = EntropyDriftGame(
      onObstacleHit: _handleObstacleHit,
      onFragmentCollected: _handleFragmentCollected,
    );
    _game.isGameOver.addListener(_handleGameOverChanged);
  }

  @override
  void dispose() {
    _game.isGameOver.removeListener(_handleGameOverChanged);
    super.dispose();
  }

  void _handleObstacleHit() {
    HapticFeedback.mediumImpact();
    ref.read(soundEffectsProvider.notifier).playDecision();
  }

  void _handleFragmentCollected() {
    HapticFeedback.selectionClick();
  }

  void _handleGameOverChanged() {
    if (!_game.isGameOver.value) {
      return;
    }
    ref
        .read(entropyDriftHighScoreProvider.notifier)
        .submitScore(_game.score.value);
  }

  void _restart() {
    _game.restart();
  }

  @override
  Widget build(BuildContext context) {
    final strings = EntropyDriftStrings.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _game)),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: _game.score,
                    builder: (context, score, _) =>
                        _ScoreBadge(label: strings.score, value: score),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _game.isGameOver,
              builder: (context, isGameOver, _) {
                if (!isGameOver) {
                  return const SizedBox.shrink();
                }
                return _GameOverOverlay(
                  strings: strings,
                  score: _game.score.value,
                  onPlayAgain: _restart,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.acrylicSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.acrylicBorder),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GameOverOverlay extends ConsumerWidget {
  const _GameOverOverlay({
    required this.strings,
    required this.score,
    required this.onPlayAgain,
  });

  final EntropyDriftStrings strings;
  final int score;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highScore = ref.watch(entropyDriftHighScoreProvider);
    final isNewHighScore = score >= highScore && score > 0;

    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.blackSoft,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.gameOverTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${strings.score}: $score',
                  style: const TextStyle(color: AppColors.textSoft),
                ),
                const SizedBox(height: 4),
                Text(
                  isNewHighScore
                      ? strings.newHighScore
                      : '${strings.highScore}: $highScore',
                  style: const TextStyle(
                    color: AppColors.gold1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),
                RitualButton(label: strings.playAgain, onPressed: onPlayAgain),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    strings.backToApp,
                    style: const TextStyle(color: AppColors.textSoft),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
