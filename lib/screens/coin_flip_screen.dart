import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/coin_flip_controller.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/mystic_screen_scaffold.dart';

class CoinFlipScreen extends ConsumerStatefulWidget {
  const CoinFlipScreen({super.key});

  @override
  ConsumerState<CoinFlipScreen> createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends ConsumerState<CoinFlipScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _spinCurve;
  late final Animation<double> _landingBounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    // Eased spin so the toss decelerates into a satisfying landing instead
    // of stopping abruptly, with a small pop right as the coin settles.
    _spinCurve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _landingBounce = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 1.0, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _flipCoin() async {
    final controller = ref.read(coinFlipProvider.notifier);
    if (ref.read(coinFlipProvider).isLoading) {
      return;
    }

    final animation = _controller.forward(from: 0);
    await controller.flip();
    await animation;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(coinQuickAccessTriggerProvider, (previous, next) {
      if (previous != next) {
        _flipCoin();
      }
    });

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(coinFlipProvider);
    final resultLabel = switch (state.result) {
      0 => l10n.coinHeads,
      1 => l10n.coinTails,
      _ => l10n.coinPrompt,
    };

    return MysticScreenScaffold(
      title: l10n.navCoin,
      subtitle: l10n.coinSubtitle,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    height: 240,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final spin = state.isLoading
                              ? _spinCurve.value * math.pi * 10
                              : (state.result ?? 0) == 1
                              ? math.pi
                              : 0.0;
                          final showingFront = (spin % (math.pi * 2)) < math.pi;
                          final faceValue = state.isLoading
                              ? (showingFront ? 0 : 1)
                              : (state.result ?? 0);
                          final scale = 1 + (_landingBounce.value * 0.08);

                          // Perspective plus X/Y rotation keeps the coin toss feeling 3D while
                          // still landing on the resolved Riverpod state after the fetch finishes.
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateX(
                                state.isLoading
                                    ? math.sin(_controller.value * math.pi) *
                                          0.18
                                    : 0.0,
                              )
                              ..rotateY(spin)
                              ..scaleByDouble(scale, scale, 1, 1),
                            child: _CoinFace(value: faceValue),
                          );
                        },
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: state.isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            key: ValueKey(resultLabel),
                            children: [
                              Text(
                                resultLabel,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.result == null
                                    ? l10n.coinTapPrompt
                                    : l10n.coinResolved,
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: state.isLoading ? null : _flipCoin,
                    icon: const Icon(Icons.monetization_on),
                    label: Text(l10n.coinButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinFace extends StatelessWidget {
  const _CoinFace({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isCara = value == 0;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isCara
              ? const [AppColors.coinFrontStart, AppColors.coinFrontEnd]
              : const [AppColors.coinBackStart, AppColors.coinBackEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
        border: Border.all(color: AppColors.whiteBorder, width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCara ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              size: 44,
              color: AppColors.blackSoft,
            ),
            const SizedBox(height: 12),
            Text(
              isCara ? l10n.coinHeads : l10n.coinTails,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.blackMuted,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
