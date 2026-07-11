import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/tarot_draw_controller.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';
import 'package:theuniversedecides/widgets/ritual_header.dart';

class TarotDrawScreen extends ConsumerWidget {
  const TarotDrawScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(tarotDrawProvider);
    final controller = ref.read(tarotDrawProvider.notifier);
    final cardKey = ValueKey<int>(state.drawCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RitualHeader(
            eyebrow: l10n.tarotEyebrow,
            title: l10n.tarotTitle,
            subtitle: l10n.tarotSubtitle,
          ),
          const SizedBox(height: 22),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 900),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [...previousChildren, ?currentChild],
                  );
                },
                transitionBuilder: (child, animation) {
                  final isIncoming = child.key == cardKey;
                  final rotation = Tween<double>(
                    begin: isIncoming ? math.pi : -math.pi,
                    end: 0,
                  ).animate(animation);

                  return AnimatedBuilder(
                    animation: rotation,
                    child: child,
                    builder: (context, child) {
                      final angle = rotation.value;
                      final needsMirror = angle.abs() > (math.pi / 2);
                      final displayChild = needsMirror
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: child,
                            )
                          : child;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0018)
                          ..rotateY(angle),
                        child: displayChild,
                      );
                    },
                  );
                },
                child: _TarotCardFace(key: cardKey, card: state.card),
              ),
            ),
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    key: ValueKey(state.card?.deckNumber ?? 0),
                    children: [
                      Text(
                        state.card?.title ?? l10n.tarotWaiting,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.card == null
                            ? l10n.tarotTapReveal
                            : state.card!.isMajorArcana
                            ? l10n.tarotMajorArcana
                            : l10n.tarotMinorArcana,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.whiteMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          RitualButton(
            label: l10n.tarotButton,
            onPressed: state.isLoading ? null : controller.drawCard,
            maxWidth: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _TarotCardFace extends StatelessWidget {
  const _TarotCardFace({super.key, required this.card});

  final TarotCard? card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRevealed = card != null;

    return AspectRatio(
      aspectRatio: 2 / 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 400;
          final cardPadding = isCompact ? 16.0 : 22.0;
          final iconSize = isCompact ? 42.0 : 54.0;
          final mainGap = isCompact ? 10.0 : 20.0;
          final secondaryGap = isCompact ? 8.0 : 14.0;
          final contentWidth = constraints.maxWidth.isFinite
              ? math.max(120.0, constraints.maxWidth - (cardPadding * 2))
              : 220.0;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: isRevealed
                    ? const [
                        Color(0xFF1D1234),
                        Color(0xFF3E216E),
                        Color(0xFF8E6B2B),
                      ]
                    : const [
                        Color(0xFF0F091A),
                        Color(0xFF281443),
                        Color(0xFF5E3A12),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFFE6C26A).withValues(alpha: 0.72),
                width: 1.6,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x99000000),
                  blurRadius: 34,
                  offset: Offset(0, 22),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: RadialGradient(
                        colors: [const Color(0x66F8D26D), Colors.transparent],
                        radius: isRevealed ? 0.95 : 0.75,
                        center: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: _TarotBadge(
                              icon: isRevealed
                                  ? Icons.visibility_rounded
                                  : Icons.auto_awesome,
                              label: isRevealed
                                  ? (card!.isMajorArcana
                                        ? l10n.tarotMajorArcana
                                        : l10n.tarotMinorArcana)
                                  : l10n.navTarot,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TarotBadge(
                            icon: Icons.stars_rounded,
                            label: '#${card?.deckNumber ?? '--'}',
                          ),
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: contentWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isRevealed
                                        ? Icons.brightness_3
                                        : Icons.auto_awesome,
                                    size: iconSize,
                                    color: const Color(0xFFF6D98B),
                                  ),
                                  SizedBox(height: mainGap),
                                  Text(
                                    isRevealed
                                        ? card!.title
                                        : l10n.tarotWaiting,
                                    style:
                                        (isCompact
                                                ? theme.textTheme.titleLarge
                                                : theme.textTheme.headlineSmall)
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              height: 1.15,
                                            ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: secondaryGap),
                                  Text(
                                    isRevealed
                                        ? l10n.tarotDeckPosition(
                                            card!.deckNumber,
                                          )
                                        : l10n.tarotTapReveal,
                                    style:
                                        (isCompact
                                                ? theme.textTheme.bodyMedium
                                                : theme.textTheme.bodyLarge)
                                            ?.copyWith(
                                              color: const Color(0xE6F4E7FF),
                                              height: 1.35,
                                            ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 12 : 16,
                          vertical: isCompact ? 10 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Text(
                          isRevealed
                              ? (card!.isMajorArcana
                                    ? l10n.tarotMajorArcana
                                    : l10n.tarotMinorArcana)
                              : l10n.tarotTapReveal,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TarotBadge extends StatelessWidget {
  const _TarotBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    const unconstrainedTextMaxWidth = 132.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.maxWidth.isFinite;

        return Container(
          width: hasBoundedWidth ? constraints.maxWidth : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: hasBoundedWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFFF2D480)),
              const SizedBox(width: 4),
              if (hasBoundedWidth)
                Expanded(child: _TarotBadgeLabel(label: label))
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: unconstrainedTextMaxWidth,
                  ),
                  child: _TarotBadgeLabel(label: label),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TarotBadgeLabel extends StatelessWidget {
  const _TarotBadgeLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
