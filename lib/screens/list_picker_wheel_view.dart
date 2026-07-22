import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/list_picker_controller.dart';
import 'package:theuniversedecides/controllers/wheel_geometry.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';

/// The "spin the wheel" reveal mode for List Draw.
///
/// Renders the *same* items and state managed by [listPickerProvider] (no
/// separate item list is kept) as a segmented wheel. Spinning calls
/// [ListPickerController.spinWheel], which uses the exact same randomness
/// service and selection rule as the classic reveal — this widget only owns
/// a purely visual rotation animation that lands on whatever index the
/// service already picked.
class ListPickerWheelView extends ConsumerStatefulWidget {
  const ListPickerWheelView({super.key});

  @override
  ConsumerState<ListPickerWheelView> createState() =>
      _ListPickerWheelViewState();
}

class _ListPickerWheelViewState extends ConsumerState<ListPickerWheelView>
    with SingleTickerProviderStateMixin {
  static const _spinDuration = Duration(milliseconds: 3200);
  static const _minimumDragAngle = 0.25;
  static const _wheelCenter = Offset(120, 140);

  late final AnimationController _spinController;
  double _rotation = 0;
  double _animateFrom = 0;
  double _animateTo = 0;
  bool _spinning = false;
  double? _lastDragAngle;
  double _dragAngularDistance = 0;
  Offset _lastDragPosition = Offset.zero;

  /// True once *this* wheel instance has produced a result. Kept separate
  /// from `state.selectedIndex` (shared with the classic mode) so switching
  /// into wheel mode after a classic pick doesn't show a banner for a result
  /// the wheel itself never visually landed on.
  bool _hasSpunOnce = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: _spinDuration,
    )..addListener(_onTick);
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _onTick() {
    final t = Curves.easeOutCubic.transform(_spinController.value);
    setState(() {
      _rotation = _animateFrom + (_animateTo - _animateFrom) * t;
    });
  }

  Future<void> _spin({WheelFlickProfile? flick}) async {
    final listState = ref.read(listPickerProvider);
    if (_spinning ||
        listState.isLoading ||
        !isValidWheelSelection(listState.items)) {
      return;
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    setState(() {
      _spinning = true;
      _hasSpunOnce = false;
    });

    if (!reduceMotion && flick != null) {
      _spinController.duration = const Duration(milliseconds: 700);
      _animateFrom = _rotation;
      _animateTo =
          _rotation + flick.direction * math.pi * 2 * 1.5;
      _spinController.forward(from: 0);
    }

    final winner = await ref.read(listPickerProvider.notifier).spinWheel();
    if (!mounted) {
      return;
    }
    if (winner == null) {
      _spinController.stop();
      setState(() => _spinning = false);
      return;
    }

    final itemCount = ref.read(listPickerProvider).items.length;

    if (reduceMotion) {
      setState(() {
        _rotation = computeWheelTargetRotation(
          winnerIndex: winner,
          itemCount: itemCount,
          currentRotation: _rotation,
          extraSpins: 0,
          direction: flick?.direction ?? 1,
        );
        _spinning = false;
        _hasSpunOnce = true;
      });
      await _celebrate();
      return;
    }

    _spinController.stop();
    _spinController.duration = flick?.duration ?? _spinDuration;
    _animateFrom = _rotation;
    _animateTo = computeWheelTargetRotation(
      winnerIndex: winner,
      itemCount: itemCount,
      currentRotation: _rotation,
      extraSpins: flick?.extraSpins ?? wheelDefaultExtraSpins,
      direction: flick?.direction ?? 1,
    );
    await _spinController.forward(from: 0);
    if (!mounted) {
      return;
    }
    setState(() {
      _spinning = false;
      _hasSpunOnce = true;
    });
    await _celebrate();
  }

  Future<void> _celebrate() async {
    HapticFeedback.mediumImpact();
    await ref.read(soundEffectsProvider.notifier).playDecision();
  }

  bool get _canHandleDrag {
    final state = ref.read(listPickerProvider);
    return !_spinning &&
        !state.isLoading &&
        isValidWheelSelection(state.items);
  }

  void _onPanStart(DragStartDetails details) {
    if (!_canHandleDrag) return;
    _lastDragPosition = details.localPosition;
    _lastDragAngle = _angleFor(details.localPosition);
    _dragAngularDistance = 0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final previousAngle = _lastDragAngle;
    if (previousAngle == null || !_canHandleDrag) return;

    final currentAngle = _angleFor(details.localPosition);
    final delta = shortestAngularDelta(previousAngle, currentAngle);
    _lastDragAngle = currentAngle;
    _lastDragPosition = details.localPosition;
    _dragAngularDistance += delta.abs();
    setState(() => _rotation += delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_lastDragAngle == null || !_canHandleDrag) {
      _resetDrag();
      return;
    }

    final radius = _lastDragPosition - _wheelCenter;
    final velocity = details.velocity.pixelsPerSecond;
    final angularVelocity = wheelAngularVelocity(
      positionFromCenter: math.Point(radius.dx, radius.dy),
      pixelsPerSecond: math.Point(velocity.dx, velocity.dy),
    );
    final profile = computeWheelFlickProfile(
      angularVelocity: angularVelocity,
    );
    final shouldSpin =
        _dragAngularDistance >= _minimumDragAngle && profile != null;
    _resetDrag();
    if (shouldSpin) {
      _spin(flick: profile);
    }
  }

  void _onPanCancel() => _resetDrag();

  double _angleFor(Offset position) => wheelPointerPositionAngle(
        position: math.Point(position.dx, position.dy),
        center: const math.Point(120.0, 140.0),
      );

  void _resetDrag() {
    _lastDragAngle = null;
    _dragAngularDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(listPickerProvider);
    final canSpin =
        !_spinning && !state.isLoading && isValidWheelSelection(state.items);
    final hasWinner =
        _hasSpunOnce &&
        !_spinning &&
        state.selectedIndex != null &&
        state.selectedIndex! < state.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          key: const ValueKey('list-wheel-dial'),
          onTap: canSpin ? () => _spin() : null,
          onPanStart: canSpin ? _onPanStart : null,
          onPanUpdate: canSpin ? _onPanUpdate : null,
          onPanEnd: canSpin ? _onPanEnd : null,
          onPanCancel: canSpin ? _onPanCancel : null,
          child: _WheelDial(items: state.items, rotation: _rotation),
        ),
        const SizedBox(height: 20),
        RitualButton(
          label: l10n.listWheelSpinButton,
          onPressed: canSpin ? _spin : null,
          maxWidth: double.infinity,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: hasWinner
                ? _WheelResultBanner(
                    key: ValueKey('wheel-result-${state.selectedIndex}'),
                    label: l10n.listChosenByUniverse,
                    value: state.items[state.selectedIndex!],
                    hint: l10n.listWheelSpinAgainHint,
                  )
                : Container(
                    key: const ValueKey('wheel-hint'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0x0AFFFFFF),
                      border: Border.all(color: const Color(0x14FFFFFF)),
                    ),
                    child: Text(
                      state.items.length < 2
                          ? l10n.listEmptyState
                          : l10n.listWheelHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textDim,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _WheelResultBanner extends StatelessWidget {
  const _WheelResultBanner({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppColors.listResultGradientStart,
            AppColors.listResultGradientEnd,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.whiteMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: const TextStyle(fontSize: 12, color: AppColors.whiteMuted),
          ),
        ],
      ),
    );
  }
}

/// The static pointer, spinning wheel disc, and center hub.
class _WheelDial extends StatelessWidget {
  const _WheelDial({required this.items, required this.rotation});

  final List<String> items;
  final double rotation;

  static const double _diameter = 240;
  static const double _pointerHeight = 20;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _diameter,
      height: _diameter + _pointerHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: _pointerHeight,
            child: Transform.rotate(
              key: const ValueKey('list-wheel-disc'),
              angle: rotation,
              child: CustomPaint(
                size: const Size(_diameter, _diameter),
                painter: _WheelPainter(items: items),
              ),
            ),
          ),
          Positioned(
            top: _pointerHeight + _diameter / 2 - 16,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.gold1, AppColors.gold2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 8),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(28, _pointerHeight + 4),
              painter: _PointerPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.gold2;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A small, repeating, on-brand palette for the wheel segments — enough
/// contrast between neighbours to read as distinct slices at any item count.
const _segmentPalette = <Color>[
  AppColors.gold2,
  AppColors.listResultGradientEnd,
  AppColors.listResultGradientStart,
  AppColors.coinBackEnd,
  AppColors.gold1,
  AppColors.acrylicAccent,
];

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.items});

  final List<String> items;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    // Base disc so an empty/one-item wheel still reads as a wheel.
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0x14FFFFFF),
    );

    final itemCount = items.length;
    if (itemCount == 0) {
      return;
    }

    final segment = wheelSegmentAngle(itemCount);
    final showLabels = wheelShouldShowLabels(itemCount);
    final fontSize = wheelLabelFontSize(itemCount);

    for (var i = 0; i < itemCount; i++) {
      final startAngle = i * segment;
      final color = _segmentPalette[i % _segmentPalette.length];

      canvas.drawArc(
        rect,
        startAngle,
        segment,
        true,
        Paint()..color = color,
      );
      canvas.drawArc(
        rect,
        startAngle,
        segment,
        true,
        Paint()
          ..color = const Color(0x33000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      if (showLabels) {
        _drawLabel(
          canvas,
          center: center,
          radius: radius,
          midAngle: startAngle + segment / 2,
          text: items[i],
          fontSize: fontSize,
        );
      }
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawLabel(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double midAngle,
    required String text,
    required double fontSize,
  }) {
    // Leave room for the hub near the center and a small margin at the rim.
    final maxWidth = math.max(24.0, radius * 0.66);

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: const [Shadow(color: Color(0x99000000), blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(midAngle);
    // Place the label along the radius, outside the hub, growing outward.
    painter.paint(
      canvas,
      Offset(radius * 0.32, -painter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.items != items;
}
