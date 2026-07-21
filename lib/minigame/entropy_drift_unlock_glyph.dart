import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/minigame/entropy_drift_screen.dart';
import 'package:theuniversedecides/minigame/entropy_drift_unlock_notifier.dart';
import 'package:theuniversedecides/theme/app_colors.dart';

/// Decorative glyph placed before the RitualHeader eyebrow text. It reads
/// as ordinary theme decoration, but counts taps toward the secret Entropy
/// Drift unlock sequence.
class EntropyDriftUnlockGlyph extends ConsumerStatefulWidget {
  const EntropyDriftUnlockGlyph({super.key});

  @override
  ConsumerState<EntropyDriftUnlockGlyph> createState() =>
      _EntropyDriftUnlockGlyphState();
}

class _EntropyDriftUnlockGlyphState
    extends ConsumerState<EntropyDriftUnlockGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: 1,
      upperBound: 1.6,
      value: 1,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    final unlocked =
        ref.read(entropyDriftUnlockProvider.notifier).registerTap();
    if (!unlocked) {
      return;
    }

    await _pulseController.forward();
    if (!mounted) {
      return;
    }
    await _pulseController.reverse();
    if (!mounted) {
      return;
    }

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const EntropyDriftScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ScaleTransition(
          scale: _pulseController,
          child: const Icon(
            Icons.auto_awesome,
            size: 12,
            color: AppColors.textFaint,
          ),
        ),
      ),
    );
  }
}
