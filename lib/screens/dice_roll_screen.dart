import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/dice_roll_controller.dart';
import 'package:theuniversedecides/dice/dice_bridge_message.dart';
import 'package:theuniversedecides/dice/dice_roll_request.dart';
import 'package:theuniversedecides/dice/dice_web_view.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';

typedef DiceWebViewBuilder = Widget Function(DiceWebViewController controller);

class DiceRollScreen extends ConsumerStatefulWidget {
  const DiceRollScreen({super.key, this.diceWebViewBuilder});

  final DiceWebViewBuilder? diceWebViewBuilder;

  @override
  ConsumerState<DiceRollScreen> createState() => _DiceRollScreenState();
}

class _DiceRollScreenState extends ConsumerState<DiceRollScreen>
    with WidgetsBindingObserver {
  static const _availableSides = [4, 6, 8, 10, 12, 20, 100];
  static const _animationTimeout = Duration(seconds: 12);

  late final DiceWebViewController _diceWebViewController;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _diceWebViewController = DiceWebViewController(
      onRollCompleted: _completeDiceAnimation,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _diceWebViewController.resume();
    } else {
      _diceWebViewController.pause();
    }
  }

  Future<void> _startRoll() => ref.read(diceRollProvider.notifier).startRoll();

  void _completeDiceAnimation(DiceBridgeMessage message) {
    _animationTimer?.cancel();
    ref.read(diceRollProvider.notifier).completeAnimation(message.requestId);
  }

  Future<void> _animateRequest(DiceRollRequest request) async {
    await _diceWebViewController.roll(request);
    if (!mounted ||
        ref.read(diceRollProvider).activeRequestId != request.requestId) {
      return;
    }
    _animationTimer?.cancel();
    _animationTimer = Timer(_animationTimeout, () {
      if (!mounted) {
        return;
      }
      ref.read(diceRollProvider.notifier).timeoutAnimation(request.requestId);
    });
  }

  void _showAnimationError(String error) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(diceRollProvider);
    final controller = ref.read(diceRollProvider.notifier);
    final isBusy = state.isBusy;

    ref.listen<DiceRollState>(diceRollProvider, (previous, next) {
      final previousRequestId = previous?.rollRequest?.requestId;
      final request = next.rollRequest;
      if (next.isRolling &&
          request != null &&
          request.requestId != previousRequestId) {
        _animateRequest(request);
      }
      if (next.animationError != null &&
          next.animationError != previous?.animationError) {
        _showAnimationError(next.animationError!);
      }
    });
    ref.listen<int>(diceQuickAccessTriggerProvider, (previous, next) {
      if (previous == next) {
        return;
      }
      controller.setDiceCount(1);
      controller.setSelectedSides(20);
      _startRoll();
    });

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.scaffoldBackground,
            AppColors.backgroundGradientMiddle,
            AppColors.scaffoldBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 36),
        children: [
          Text(
            'Dice Ritual',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.whiteMuted,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'RPG Dice',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: AppColors.whiteStrong,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 34),
          _SectionLabel(label: l10n.diceCount),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final count = index + 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 4 ? 0 : 10),
                  child: _RitualChoiceButton(
                    key: Key('dice-count-$count'),
                    label: '$count',
                    selected: state.diceCount == count,
                    onPressed: isBusy
                        ? null
                        : () => controller.setDiceCount(count),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: l10n.diceSides),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableSides.map((sides) {
              return SizedBox(
                width: 112,
                child: _RitualChoiceButton(
                  key: Key('dice-side-$sides'),
                  label: 'd$sides',
                  selected: state.selectedSides == sides,
                  onPressed: isBusy
                      ? null
                      : () => controller.setSelectedSides(sides),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 80,
            child: FilledButton(
              key: const Key('dice-roll-button'),
              onPressed: isBusy ? null : _startRoll,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFC653),
                disabledBackgroundColor: const Color(0xFF75603A),
                foregroundColor: const Color(0xFF21192C),
                disabledForegroundColor: AppColors.whiteMuted,
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                state.isFetching ? 'Summoning dice…' : l10n.diceRollButton,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _DiceAnimationRegion(
            child:
                widget.diceWebViewBuilder?.call(_diceWebViewController) ??
                DiceWebView(controller: _diceWebViewController),
          ),
          if (state.animationError != null) ...[
            const SizedBox(height: 12),
            Text(
              state.animationError!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFFFC9C9),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (state.results.isEmpty)
            Text(
              l10n.diceEmptyState,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.whiteMuted,
              ),
            )
          else ...[
            _DiceResults(results: state.results),
            const SizedBox(height: 20),
            Text(
              state.results.join(' + '),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.whiteMuted,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.diceTotal(state.total),
              key: const Key('dice-total'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.whiteStrong,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.whiteMuted,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _RitualChoiceButton extends StatelessWidget {
  const _RitualChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: selected
            ? const Color(0xFFFFC653)
            : Colors.transparent,
        foregroundColor: selected
            ? const Color(0xFF21192C)
            : AppColors.whiteMuted,
        disabledForegroundColor: AppColors.whiteMuted.withValues(alpha: 0.45),
        side: BorderSide(
          color: selected ? const Color(0xFFFFD985) : AppColors.whiteBorder,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        textStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    );
  }
}

class _DiceAnimationRegion extends StatelessWidget {
  const _DiceAnimationRegion({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.whiteBorder),
              ),
            ),
            child: SizedBox(width: 200, height: 200),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _DiceResults extends StatelessWidget {
  const _DiceResults({required this.results});

  final List<int> results;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              '${results[index]}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF21192C),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      },
    );
  }
}
