import 'package:flutter/material.dart';

import 'package:theuniversedecides/minigame/entropy_drift_unlock_glyph.dart';
import 'package:theuniversedecides/theme/app_colors.dart';

/// Screen header from the prototype: a Fraunces-style italic eyebrow, a bold
/// title, and an optional muted subtitle.
class RitualHeader extends StatelessWidget {
  const RitualHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.titleSize = 26,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const EntropyDriftUnlockGlyph(),
            Flexible(
              child: Text(
                eyebrow,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  letterSpacing: 0.8,
                  color: AppColors.textDim,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: Colors.white,
          ),
        ),
        if (subtitle case final subtitle?) ...[
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSoft,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
