import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/card_draw_controller.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/widgets/mystic_screen_scaffold.dart';

class CardDrawScreen extends ConsumerStatefulWidget {
  const CardDrawScreen({super.key});

  @override
  ConsumerState<CardDrawScreen> createState() => _CardDrawScreenState();
}

class _CardDrawScreenState extends ConsumerState<CardDrawScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _drawCard() async {
    final controller = ref.read(cardDrawProvider.notifier);
    if (ref.read(cardDrawProvider).isLoading) {
      return;
    }

    final animation = _controller.forward(from: 0);
    await controller.drawCard();
    await animation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(cardDrawProvider);
    final card = state.card;

    return MysticScreenScaffold(
      title: l10n.navCards,
      subtitle: l10n.cardDrawSubtitle,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                height: 340,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final scale =
                          1 - (math.sin(_controller.value * math.pi) * 0.06);
                      final tilt = math.sin(_controller.value * math.pi) * 0.05;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateZ(tilt)
                          ..scaleByDouble(scale, scale, 1, 1),
                        child: _PlayingCardView(card: card),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: state.isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        key: ValueKey(card?.shortLabel ?? 'card-empty'),
                        children: [
                          Text(
                            card?.shortLabel ?? l10n.cardDrawPrompt,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card == null
                                ? l10n.cardDrawTapPrompt
                                : l10n.cardDrawResolved,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.isLoading ? null : _drawCard,
                  icon: const Icon(Icons.style),
                  label: Text(l10n.cardDrawButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayingCardView extends StatelessWidget {
  const _PlayingCardView({required this.card});

  final PlayingCard? card;

  static const _cardRed = Color(0xFFD63A56);
  static const _cardDark = Color(0xFF171A20);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suitColor = card == null
        ? theme.colorScheme.onSurfaceVariant
        : (card!.isRed ? _cardRed : _cardDark);

    return Container(
      width: 220,
      height: 312,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFEFEFE), Color(0xFFF4F5F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x14000000), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 28,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: card == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    size: 42,
                    color: suitColor,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '?',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: suitColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Positioned(
                  top: 18,
                  left: 18,
                  child: _CardCorner(
                    rank: card!.rank,
                    color: suitColor,
                    icon: _suitIcon(card!.suit),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: _CardCorner(
                      rank: card!.rank,
                      color: suitColor,
                      icon: _suitIcon(card!.suit),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_suitIcon(card!.suit), size: 54, color: suitColor),
                      const SizedBox(height: 14),
                      Text(
                        card!.rank,
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: suitColor,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        card!.shortLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: suitColor.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
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

class _CardCorner extends StatelessWidget {
  const _CardCorner({
    required this.rank,
    required this.color,
    required this.icon,
  });

  final String rank;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rank,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            height: 0.95,
          ),
        ),
        Icon(icon, size: 20, color: color),
      ],
    );
  }
}
