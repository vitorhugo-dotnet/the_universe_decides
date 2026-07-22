import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/minigame/entropy_drift_engine.dart';
import 'package:theuniversedecides/minigame/entropy_drift_high_score_service.dart';
import 'package:theuniversedecides/minigame/entropy_drift_strings.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';

/// Entropy Drift — the hidden minigame. Rendered with plain Flutter widgets
/// (a flat [Stack] of small [Positioned] bodies animated by one
/// [AnimationController]) instead of a Flame `GameWidget`. A full-screen canvas
/// repainted every frame hits an Android partial-repaint driver bug and renders
/// black on some GPUs (e.g. the Galaxy M54's Xclipse); moving small cached
/// widgets does not.
class EntropyDriftScreen extends ConsumerStatefulWidget {
  const EntropyDriftScreen({super.key});

  @override
  ConsumerState<EntropyDriftScreen> createState() => _EntropyDriftScreenState();
}

class _EntropyDriftScreenState extends ConsumerState<EntropyDriftScreen>
    with SingleTickerProviderStateMixin {
  late final EntropyDriftEngine _engine;
  late final AnimationController _clock;
  DateTime? _lastTick;

  @override
  void initState() {
    super.initState();
    _engine = EntropyDriftEngine(
      onObstacleHit: _handleObstacleHit,
      onFragmentCollected: _handleFragmentCollected,
    );
    _engine.isGameOver.addListener(_handleGameOverChanged);
    // A repeating controller is used purely as a per-frame clock; its value is
    // ignored. Advancing the simulation off wall-clock deltas keeps physics
    // independent of frame rate.
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(_onFrame)
      ..repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    _engine.isGameOver.removeListener(_handleGameOverChanged);
    _engine.dispose();
    super.dispose();
  }

  void _onFrame() {
    final now = DateTime.now();
    final last = _lastTick;
    _lastTick = now;
    if (last == null) {
      return;
    }
    var dt = now.difference(last).inMicroseconds / Duration.microsecondsPerSecond;
    if (dt > 0.05) {
      dt = 0.05;
    }
    _engine.tick(dt);
  }

  void _handleObstacleHit() {
    HapticFeedback.mediumImpact();
    ref.read(soundEffectsProvider.notifier).playDecision();
  }

  void _handleFragmentCollected() {
    HapticFeedback.selectionClick();
  }

  void _handleGameOverChanged() {
    if (!_engine.isGameOver.value) {
      return;
    }
    _clock.stop();
    ref
        .read(entropyDriftHighScoreProvider.notifier)
        .submitScore(_engine.score.value);
  }

  void _restart() {
    _engine.restart();
    _lastTick = null;
    if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = EntropyDriftStrings.of(context);
    final media = MediaQuery.of(context);
    _engine.setSize(media.size);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) {
          final gameOver = _engine.isGameOver.value;
          return Stack(
            children: [
              // Drag layer (bottom): moving the finger steers the star.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) =>
                      _engine.moveStar(details.localPosition),
                  onPanUpdate: (details) =>
                      _engine.moveStar(details.localPosition),
                  child: const SizedBox.expand(),
                ),
              ),
              for (final obstacle in _engine.obstacles)
                Positioned(
                  key: ValueKey<String>('o${obstacle.id}'),
                  left: obstacle.position.dx - _BlackHoleWidget.extent,
                  top: obstacle.position.dy - _BlackHoleWidget.extent,
                  child: const IgnorePointer(child: _BlackHoleWidget()),
                ),
              for (final fragment in _engine.fragments)
                Positioned(
                  key: ValueKey<String>('f${fragment.id}'),
                  left: fragment.position.dx - _FragmentWidget.extent,
                  top: fragment.position.dy - _FragmentWidget.extent,
                  child: const IgnorePointer(child: _FragmentWidget()),
                ),
              Positioned(
                left: _engine.star.dx - _StarWidget.extent,
                top: _engine.star.dy - _StarWidget.extent,
                child: const IgnorePointer(child: _StarWidget()),
              ),
              Positioned(
                top: media.padding.top + 12,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ScoreBadge(
                      label: strings.score,
                      value: _engine.score.value,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              if (gameOver)
                _GameOverOverlay(
                  strings: strings,
                  score: _engine.score.value,
                  onPlayAgain: _restart,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StarWidget extends StatelessWidget {
  const _StarWidget();

  static const double extent = 26; // room for the glow (radius 14 * 1.8)

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: extent * 2,
    height: extent * 2,
    child: CustomPaint(painter: _StarPainter()),
  );
}

class _StarPainter extends CustomPainter {
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      EntropyDriftEngine.starRadius * 1.8,
      Paint()..color = const Color(0x66FCE38A),
    );
    canvas.drawCircle(
      center,
      EntropyDriftEngine.starRadius,
      Paint()..color = const Color(0xFFFCE38A),
    );
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => false;
}

class _BlackHoleWidget extends StatelessWidget {
  const _BlackHoleWidget();

  static const double extent = EntropyDriftEngine.obstacleRadius;

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: extent * 2,
    height: extent * 2,
    child: CustomPaint(painter: _BlackHolePainter()),
  );
}

class _BlackHolePainter extends CustomPainter {
  const _BlackHolePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      EntropyDriftEngine.obstacleRadius,
      Paint()..color = const Color(0xFF090611),
    );
    canvas.drawCircle(
      center,
      EntropyDriftEngine.obstacleRadius * 0.7,
      Paint()
        ..color = const Color(0xFF7A4FFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_BlackHolePainter oldDelegate) => false;
}

class _FragmentWidget extends StatelessWidget {
  const _FragmentWidget();

  static const double extent = EntropyDriftEngine.fragmentRadius;

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: extent * 2,
    height: extent * 2,
    child: CustomPaint(painter: _FragmentPainter()),
  );
}

class _FragmentPainter extends CustomPainter {
  const _FragmentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      EntropyDriftEngine.fragmentRadius,
      Paint()..color = const Color(0xFFF9B44C),
    );
  }

  @override
  bool shouldRepaint(_FragmentPainter oldDelegate) => false;
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
    final isNewHighScore = score > highScore;

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
