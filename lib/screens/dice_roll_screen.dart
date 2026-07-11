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
import 'package:theuniversedecides/widgets/ritual_button.dart';
import 'package:theuniversedecides/widgets/ritual_header.dart';

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
                    key: Key('dice-count-$n'),
                    label: '$n',
                    selected: state.diceCount == n,
                    height: 40,
                    onTap: isBusy ? null : () => controller.setDiceCount(n),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          _SectionLabel(l10n.diceSidesLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sides in _availableSides)
                SizedBox(
                  width: 64,
                  child: _PillButton(
                    key: Key('dice-side-$sides'),
                    label: 'd$sides',
                    selected: state.selectedSides == sides,
                    height: 40,
                    onTap: isBusy
                        ? null
                        : () => controller.setSelectedSides(sides),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          RitualButton(
            key: const Key('dice-roll-button'),
            label: l10n.diceRollButton,
            onPressed: isBusy ? null : _startRoll,
          ),
          const SizedBox(height: 22),
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
              style: const TextStyle(fontSize: 13, color: Color(0xFFFFC9C9)),
            ),
          ],
          const SizedBox(height: 18),
          if (state.results.isNotEmpty)
            Column(
              children: [
                _DiceResults(results: state.results),
                const SizedBox(height: 16),
                Text(
                  state.results.join('  +  '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textCaption,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.diceTotal(state.total),
                  key: const Key('dice-total'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
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
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 40,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
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
      ),
    );
  }
}

/// The transparent dice renderer sits over the shell's cosmic background, with
/// a soft ritual glow to anchor it inside the composition.
class _DiceAnimationRegion extends StatelessWidget {
  const _DiceAnimationRegion({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.ritualGlow, Colors.transparent],
              ),
            ),
            child: SizedBox(width: 220, height: 220),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Ivory dice faces with gold pips, echoing the prototype's settled 3D dice.
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
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) => _DieFace(value: results[index]),
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
