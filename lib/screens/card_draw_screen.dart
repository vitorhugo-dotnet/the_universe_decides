import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/card_draw_controller.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';
import 'package:theuniversedecides/widgets/ritual_header.dart';

class CardDrawScreen extends ConsumerStatefulWidget {
  const CardDrawScreen({super.key});

  @override
  ConsumerState<CardDrawScreen> createState() => _CardDrawScreenState();
}

class _CardDrawScreenState extends ConsumerState<CardDrawScreen> {
  int _flipCount = 0;

  Future<void> _drawCard() async {
    final controller = ref.read(cardDrawProvider.notifier);
    if (ref.read(cardDrawProvider).isLoading) {
      return;
    }
    setState(() => _flipCount++);
    await controller.drawCard();
    if (!mounted) {
      return;
    }
    HapticFeedback.mediumImpact();
    ref.read(soundEffectsProvider.notifier).playDecision();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(cardDrawProvider);
    final cardKey = ValueKey<int>(_flipCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RitualHeader(
            eyebrow: l10n.cardEyebrow,
            title: l10n.cardTitle,
            subtitle: l10n.cardSubtitle,
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 210,
              height: 296,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.center,
                  children: [...previousChildren, ?currentChild],
                ),
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
                      final display = needsMirror
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: child,
                            )
                          : child;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0016)
                          ..rotateY(angle),
                        child: display,
                      );
                    },
                  );
                },
                child: _CardFace(key: cardKey, card: state.card),
              ),
            ),
          ),
          const SizedBox(height: 24),
          RitualButton(
            label: l10n.cardDrawButton,
            onPressed: state.isLoading ? null : _drawCard,
            maxWidth: double.infinity,
          ),
        ],
      ),
    );
  }
}

/// A single flipping card: the mystic back before a draw, a playing card after.
class _CardFace extends StatelessWidget {
  const _CardFace({super.key, required this.card});

  final PlayingCard? card;

  static const _cardRed = Color(0xFFD63A56);
  static const _cardDark = Color(0xFF171A20);

  @override
  Widget build(BuildContext context) {
    if (card == null) {
      return _buildBack();
    }
    return _buildFront(context, card!);
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF241A3D), Color(0xFF3E216E), Color(0xFF1A1030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.gold2.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 34,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.gold2.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              CupertinoIcons.sparkles,
              color: AppColors.gold1.withValues(alpha: 0.8),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context, PlayingCard card) {
    final theme = Theme.of(context);
    final suitColor = card.isRed ? _cardRed : _cardDark;
    final icon = _suitIcon(card.suit);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFEFEFE), Color(0xFFF4F5F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x14000000), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 34,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: _Corner(rank: card.rank, color: suitColor, icon: icon),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Transform.rotate(
              angle: math.pi,
              child: _Corner(rank: card.rank, color: suitColor, icon: icon),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 52, color: suitColor),
                const SizedBox(height: 12),
                Text(
                  card.shortLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: suitColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _suitIcon(CardSuit suit) => switch (suit) {
    CardSuit.hearts => CupertinoIcons.suit_heart_fill,
    CardSuit.diamonds => CupertinoIcons.suit_diamond_fill,
    CardSuit.clubs => CupertinoIcons.suit_club_fill,
    CardSuit.spades => CupertinoIcons.suit_spade_fill,
  };
}

class _Corner extends StatelessWidget {
  const _Corner({required this.rank, required this.color, required this.icon});

  final String rank;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          rank,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            height: 1,
          ),
        ),
        Icon(icon, size: 18, color: color),
      ],
    );
  }
}
