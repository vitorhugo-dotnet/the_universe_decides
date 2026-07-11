import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/dice_roll_controller.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';
import 'package:theuniversedecides/widgets/ritual_header.dart';

class DiceRollScreen extends ConsumerStatefulWidget {
  const DiceRollScreen({super.key});

  @override
  ConsumerState<DiceRollScreen> createState() => _DiceRollScreenState();
}

class _DiceRollScreenState extends ConsumerState<DiceRollScreen>
    with SingleTickerProviderStateMixin {
  // Prototype dice options: counts 1-5, sides d4/d6/d20/d100.
  static const _availableSides = [4, 6, 20, 100];
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
    _tumbleCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RitualHeader(
            eyebrow: l10n.diceEyebrow,
            title: l10n.diceTitle,
            titleSize: 22,
          ),
          const SizedBox(height: 16),
          _SectionLabel(l10n.diceCountLabel),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var n = 1; n <= 5; n++) ...[
                if (n > 1) const SizedBox(width: 8),
                Expanded(
                  child: _PillButton(
                    label: '$n',
                    selected: state.diceCount == n,
                    height: 36,
                    onTap: () => controller.setDiceCount(n),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          _SectionLabel(l10n.diceSidesLabel),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < _availableSides.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _PillButton(
                    label: 'd${_availableSides[i]}',
                    selected: state.selectedSides == _availableSides[i],
                    height: 40,
                    onTap: () =>
                        controller.setSelectedSides(_availableSides[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          RitualButton(
            label: l10n.diceRollButton,
            onPressed: state.isLoading ? null : _rollDice,
          ),
          const SizedBox(height: 22),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final isRolling = state.isLoading || _controller.isAnimating;
              if (!isRolling) {
                return child!;
              }
              return _DiceGrid(
                diceCount: state.diceCount,
                sides: state.selectedSides,
                tumbleProgress: _tumbleCurve.value,
                tumbleSteps: _tumbleSteps,
              );
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: state.results.isEmpty
                  ? const SizedBox(height: 8)
                  : Column(
                      key: ValueKey(state.results.join(',')),
                      children: [
                        _DiceGrid.fromResults(state.results),
                        const SizedBox(height: 18),
                        Text(
                          state.results.join('  +  '),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textCaption,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.diceTotal(total),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.textCaption,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 36,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: selected
                ? const LinearGradient(
                    colors: [AppColors.gold1, AppColors.gold2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : const Color(0x0DFFFFFF),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0x24FFFFFF),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.goldText : AppColors.whiteMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ivory dice faces, matching the prototype's white 3D dice within the SDK-only
/// tumble animation.
class _DiceGrid extends StatelessWidget {
  const _DiceGrid({
    required this.diceCount,
    required this.sides,
    required this.tumbleProgress,
    required this.tumbleSteps,
  }) : results = null;

  const _DiceGrid.fromResults(this.results)
    : diceCount = 0,
      sides = 0,
      tumbleProgress = 0,
      tumbleSteps = 0;

  final int diceCount;
  final int sides;
  final double tumbleProgress;
  final int tumbleSteps;
  final List<int>? results;

  @override
  Widget build(BuildContext context) {
    final finalResults = results;
    final count = finalResults?.length ?? diceCount;
    final step = (tumbleProgress * tumbleSteps).floor();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (finalResults != null) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.18, end: 1.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: _DieFace(value: finalResults[index]),
          );
        }
        final face =
            1 + math.Random(step * 97 + index * 31 + sides).nextInt(sides);
        final wobble =
            math.sin((tumbleProgress * tumbleSteps - step) * math.pi) * 0.08;
        return Transform.rotate(
          angle: wobble,
          child: _DieFace(value: face),
        );
      },
    );
  }
}

class _DieFace extends StatelessWidget {
  const _DieFace({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFEFEFE), Color(0xFFF1F0F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.goldText,
          ),
        ),
      ),
    );
  }
}
