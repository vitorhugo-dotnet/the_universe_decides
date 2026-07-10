import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/dice_roll_controller.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/mystic_screen_scaffold.dart';

class DiceRollScreen extends ConsumerStatefulWidget {
  const DiceRollScreen({super.key});

  @override
  ConsumerState<DiceRollScreen> createState() => _DiceRollScreenState();
}

class _DiceRollScreenState extends ConsumerState<DiceRollScreen>
    with SingleTickerProviderStateMixin {
  static const _availableSides = [4, 6, 8, 10, 12, 20, 100];
  static const _tumbleSteps = 14;

  late final AnimationController _controller;
  late final Animation<double> _tumbleCurve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    // Ticks land closer together as the roll progresses, giving the dice a
    // tumble-then-settle feel instead of a flat, constant flicker.
    _tumbleCurve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    final controller = ref.read(diceRollProvider.notifier);
    if (ref.read(diceRollProvider).isLoading) {
      return;
    }

    final animation = _controller.forward(from: 0);
    await controller.roll();
    await animation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(diceRollProvider);
    final controller = ref.read(diceRollProvider.notifier);
    final total = state.results.fold<int>(0, (sum, value) => sum + value);

    ref.listen<int>(diceQuickAccessTriggerProvider, (previous, next) {
      if (previous == next) {
        return;
      }

      controller.setDiceCount(1);
      controller.setSelectedSides(20);
      _rollDice();
    });

    return MysticScreenScaffold(
      title: l10n.navDice,
      subtitle: l10n.diceSubtitle,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.diceCount,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: List.generate(
                      5,
                      (index) => ButtonSegment<int>(
                        value: index + 1,
                        label: Text('${index + 1}'),
                      ),
                    ),
                    selected: {state.diceCount},
                    onSelectionChanged: (selection) {
                      controller.setDiceCount(selection.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.diceSides,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableSides
                        .map(
                          (sides) => ChoiceChip(
                            label: Text('d$sides'),
                            selected: state.selectedSides == sides,
                            onSelected: (_) {
                              controller.setSelectedSides(sides);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: state.isLoading ? null : _rollDice,
                    icon: const Icon(Icons.casino),
                    label: Text(l10n.diceRollButton),
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      if (!state.isLoading) {
                        return child!;
                      }
                      return _TumblingDiceGrid(
                        diceCount: state.diceCount,
                        sides: state.selectedSides,
                        tumbleProgress: _tumbleCurve.value,
                        tumbleSteps: _tumbleSteps,
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: state.results.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.panelBackground,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(l10n.diceEmptyState),
                            )
                          : Column(
                            key: ValueKey(state.results.join(',')),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.diceResults,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.results.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 1.35,
                                    ),
                                itemBuilder: (context, index) {
                                  final value = state.results[index];
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 1.18, end: 1.0),
                                    duration: const Duration(milliseconds: 320),
                                    curve: Curves.easeOutBack,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: child,
                                      );
                                    },
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primaryContainer,
                                            theme.colorScheme.secondaryContainer,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$value',
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: theme
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.diceTotal(total),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                    ),
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

class _TumblingDiceGrid extends StatelessWidget {
  const _TumblingDiceGrid({
    required this.diceCount,
    required this.sides,
    required this.tumbleProgress,
    required this.tumbleSteps,
  });

  final int diceCount;
  final int sides;
  final double tumbleProgress;
  final int tumbleSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = (tumbleProgress * tumbleSteps).floor();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: diceCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        // A fresh pseudo-random face per tumble step gives the illusion of the
        // die actually rolling instead of just fading between states.
        final face = 1 + math.Random(step * 97 + index * 31 + sides).nextInt(sides);
        final wobble = math.sin((tumbleProgress * tumbleSteps - step) * math.pi) * 0.08;

        return Transform.rotate(
          angle: wobble,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                '$face',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
