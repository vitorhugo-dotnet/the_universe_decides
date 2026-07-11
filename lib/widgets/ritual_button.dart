import 'package:flutter/material.dart';

import 'package:theuniversedecides/theme/app_colors.dart';

/// The prototype's primary action button: a gold gradient pill with dark text
/// and a soft amber glow. Dims to 55% opacity while disabled.
class RitualButton extends StatelessWidget {
  const RitualButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 54,
    this.borderRadius = 18,
    this.fontSize = 16,
    this.maxWidth = 320,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final double fontSize;
  final double maxWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                colors: [AppColors.gold1, AppColors.gold2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.goldShadow,
                  blurRadius: 24,
                  spreadRadius: -8,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: onPressed,
                child: SizedBox(
                  height: height,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: fontSize + 2,
                          color: AppColors.goldText,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: AppColors.goldText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
