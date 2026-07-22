import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/coin_flip_controller.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/services/results_history_service.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_background.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';
import 'package:theuniversedecides/widgets/ritual_header.dart';

/// Phases of the coin state machine, mirroring the prototype's `phys.phase`.
enum _Phase { idle, rising, landing, dragging, returning }

class _Sample {
  const _Sample(this.pos, this.t);
  final Offset pos;
  final double t; // milliseconds
}

class _CoinTransform {
  const _CoinTransform({
    required this.x,
    required this.y,
    required this.rotXDeg,
    required this.rotYDeg,
    required this.lift,
  });

  final double x;
  final double y;
  final double rotXDeg;
  final double rotYDeg;
  final double lift;
}

class CoinFlipScreen extends ConsumerStatefulWidget {
  const CoinFlipScreen({super.key});

  @override
  ConsumerState<CoinFlipScreen> createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends ConsumerState<CoinFlipScreen>
    with TickerProviderStateMixin {
  // Physics constants tuned to the ritual variant (lift 120, ~4.6 spins).
  static const double _maxLiftValue = 120;
  static const double _riseMs = 360;
  static const double _landMs = 720;
  static const double _returnMs = 280;
  static const double _minSpinMs = 520;
  static const double _spinDegPerMs = 0.95;
  static const double _wobbleDeg = 12;

  final math.Random _rand = math.Random();

  late final Ticker _ticker;
  late final AnimationController _impact;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  _Phase _phase = _Phase.idle;
  Duration _now = Duration.zero;
  Duration _phaseStart = Duration.zero;

  // Throw parameters.
  double _spinDir = 1;
  double _omega = _spinDegPerMs;
  double _maxLift = _maxLiftValue;
  double _driftX = 0;
  double _wobbleAmp = _wobbleDeg;
  double _wobbleFreq = 9;
  double _throwStartX = 0;
  double _landStartX = 0;
  double _rotYHandoff = 0;
  double _rotYFinal = 0;
  double _restRotY = 0;

  int? _pendingResult;
  bool _resultReady = false;
  bool _impactFired = false;
  bool _revealed = false;

  // Drag tracking.
  Offset _dragOrigin = Offset.zero;
  Offset _dragOffset = Offset.zero;
  final List<_Sample> _samples = <_Sample>[];
  final Stopwatch _dragClock = Stopwatch();
  double _fromX = 0;
  double _fromY = 0;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _impact = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _impact.dispose();
    _frame.dispose();
    super.dispose();
  }

  // --- easing helpers ---------------------------------------------------------
  double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
  double _easeInOutQuad(double t) =>
      t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2).toDouble() / 2;

  // --- ticker loop ------------------------------------------------------------
  void _onTick(Duration elapsed) {
    _now = elapsed;
    final t = (elapsed - _phaseStart).inMicroseconds / 1000.0;

    switch (_phase) {
      case _Phase.rising:
        if (_resultReady && t >= _minSpinMs) {
          _beginLanding(t);
        }
      case _Phase.landing:
        final p = (t / _landMs).clamp(0.0, 1.0);
        if (!_impactFired && p >= 0.88) {
          _impactFired = true;
          _fireImpact();
        }
        if (p >= 1.0) {
          _endFlight();
          return;
        }
      case _Phase.returning:
        final p = (t / _returnMs).clamp(0.0, 1.0);
        if (p >= 1.0) {
          _endReturn();
          return;
        }
      case _Phase.idle:
      case _Phase.dragging:
        break;
    }

    _frame.value++;
  }

  void _beginLanding(double tHandoff) {
    final rotYNow = _spinDir * _omega * tHandoff;
    final rp = (tHandoff / _riseMs).clamp(0.0, 1.0);
    _landStartX = _throwStartX * (1 - _easeOutCubic(rp));
    _rotYHandoff = rotYNow;
    final target = _pendingResult == 1 ? 180.0 : 0.0;
    _rotYFinal = _nextCongruent(rotYNow, _spinDir, target, 360);
    _phase = _Phase.landing;
    _phaseStart = _now;
    _impactFired = false;
    setState(() {});
  }

  /// Smallest rotation continuing in [dir] that is >= [minTurn] beyond [from]
  /// and congruent to [target] (mod 360) — so the coin decelerates onto the
  /// resolved face while still spinning forward.
  double _nextCongruent(
    double from,
    double dir,
    double target,
    double minTurn,
  ) {
    if (dir >= 0) {
      final base = from + minTurn;
      final k = ((base - target) / 360).ceil();
      return target + 360 * k;
    } else {
      final base = from - minTurn;
      final k = ((base - target) / 360).floor();
      return target + 360 * k;
    }
  }

  void _fireImpact() {
    _impact.forward(from: 0);
    HapticFeedback.mediumImpact();
    unawaited(ref.read(soundEffectsProvider.notifier).playDecision());
  }

  void _endFlight() {
    _ticker.stop();
    _phase = _Phase.idle;
    _restRotY = _pendingResult == 1 ? 180 : 0;
    _revealed = true;
    _dragOffset = Offset.zero;
    setState(() {});
    _frame.value++;
  }

  void _endReturn() {
    _ticker.stop();
    _phase = _Phase.idle;
    _dragOffset = Offset.zero;
    setState(() {});
    _frame.value++;
  }

  // --- launching --------------------------------------------------------------
  Future<void> _launchAuto() async {
    if (_phase != _Phase.idle) return;
    if (ref.read(coinFlipProvider).isLoading) return;

    if (_reduceMotion) {
      await _launchReduced();
      return;
    }

    _spinDir = _rand.nextBool() ? 1 : -1;
    _omega = _spinDegPerMs;
    _maxLift = _maxLiftValue;
    _driftX = (_rand.nextDouble() * 2 - 1) * 10 * 0.6;
    _wobbleAmp = _wobbleDeg;
    _wobbleFreq = 9 * (0.85 + _rand.nextDouble() * 0.3);
    _throwStartX = 0;
    _startFlight();

    await _resolveAndReveal();
  }

  void _startFlight() {
    _resultReady = false;
    _pendingResult = null;
    _impactFired = false;
    _revealed = false;
    _phase = _Phase.rising;
    _phaseStart = Duration.zero;
    _now = Duration.zero;
    if (!_ticker.isActive) {
      _ticker.start();
    }
    setState(() {});
  }

  Future<void> _resolveAndReveal() async {
    await ref.read(coinFlipProvider.notifier).flip();
    if (!mounted) return;
    _pendingResult = ref.read(coinFlipProvider).result ?? 0;
    _resultReady = true;
    _recordHistory(_pendingResult!);
  }

  Future<void> _launchReduced() async {
    setState(() => _revealed = false);
    await ref.read(coinFlipProvider.notifier).flip();
    if (!mounted) return;
    final result = ref.read(coinFlipProvider).result ?? 0;
    setState(() {
      _restRotY = result == 1 ? 180 : 0;
      _revealed = true;
    });
    HapticFeedback.selectionClick();
    unawaited(ref.read(soundEffectsProvider.notifier).playDecision());
    _recordHistory(result);
  }

  /// Records the completed flip in the results history. Reuses the same
  /// heads/tails label the result banner shows, so the history stays in the
  /// language the flip was made in.
  void _recordHistory(int result) {
    final l10n = AppLocalizations.of(context)!;
    final label = result == 0 ? l10n.coinHeads : l10n.coinTails;
    unawaited(
      ref
          .read(resultsHistoryProvider.notifier)
          .addEntry(modality: HistoryModality.coin, resultLabel: label),
    );
  }

  // --- drag -------------------------------------------------------------------
  void _onPanStart(DragStartDetails details) {
    if (_reduceMotion || _phase != _Phase.idle) return;
    if (ref.read(coinFlipProvider).isLoading) return;
    _phase = _Phase.dragging;
    _revealed = false;
    _dragOrigin = details.globalPosition;
    _dragOffset = Offset.zero;
    _dragClock
      ..reset()
      ..start();
    _samples
      ..clear()
      ..add(_Sample(details.globalPosition, 0));
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_phase != _Phase.dragging) return;
    final raw = details.globalPosition - _dragOrigin;
    _dragOffset = _rubberBand(raw);
    _samples.add(
      _Sample(details.globalPosition, _dragClock.elapsedMicroseconds / 1000.0),
    );
    if (_samples.length > 6) {
      _samples.removeAt(0);
    }
    _frame.value++;
  }

  Offset _rubberBand(Offset raw) {
    final dist = raw.distance;
    const maxD = 100.0;
    if (dist <= maxD || dist == 0) return raw;
    final k = (maxD / dist) * (1 - math.min(0.4, (dist - maxD) / 300));
    return raw * k;
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_phase != _Phase.dragging) return;
    _dragClock.stop();

    final a = _samples.first;
    final b = _samples.last;
    final dt = math.max(16.0, b.t - a.t);
    final vx = (b.pos.dx - a.pos.dx) / dt;
    final vy = (b.pos.dy - a.pos.dy) / dt;
    final speed = math.sqrt(vx * vx + vy * vy);
    final cur = _dragOffset;

    if (speed < 0.28) {
      _fromX = cur.dx;
      _fromY = cur.dy;
      _phase = _Phase.returning;
      _phaseStart = Duration.zero;
      _now = Duration.zero;
      if (!_ticker.isActive) _ticker.start();
      setState(() {});
      return;
    }

    final dirSign = vx >= 0 ? 1.0 : -1.0;
    final boost = math.min(1.4, speed / 1.2);
    _spinDir = dirSign;
    _omega = _spinDegPerMs * (1 + boost * 0.4);
    _maxLift = _maxLiftValue * (0.9 + boost * 0.4);
    _driftX = dirSign * 10 * (0.6 + boost * 0.5);
    _wobbleAmp = _wobbleDeg;
    _wobbleFreq = 9 * (0.85 + _rand.nextDouble() * 0.3);
    _throwStartX = cur.dx;
    HapticFeedback.lightImpact();
    _startFlight();

    await _resolveAndReveal();
  }

  // --- transform computation --------------------------------------------------
  _CoinTransform _compute() {
    final t = (_now - _phaseStart).inMicroseconds / 1000.0;
    double x = 0;
    double y = 0;
    double rotY = 0;
    double rotX = 0;
    double lift = 0;

    switch (_phase) {
      case _Phase.dragging:
        x = _dragOffset.dx;
        y = _dragOffset.dy;
        rotY = _dragOffset.dx * 0.45;
        rotX = -_dragOffset.dy * 0.32;
        lift = math.min(34.0, _dragOffset.distance * 0.26);
      case _Phase.rising:
        final rp = (t / _riseMs).clamp(0.0, 1.0);
        lift = rp < 1
            ? _maxLift * _easeOutCubic(rp)
            : _maxLift * (0.985 + 0.015 * math.sin(t / 220));
        rotY = _spinDir * _omega * t;
        rotX = _wobbleAmp * math.sin(t / (1000 / _wobbleFreq));
        x = _throwStartX * (1 - _easeOutCubic(rp));
      case _Phase.landing:
        final p = (t / _landMs).clamp(0.0, 1.0);
        lift = _maxLift * (1 - _easeInOutQuad(p));
        rotY = _rotYHandoff + (_rotYFinal - _rotYHandoff) * _easeOutCubic(p);
        rotX = _wobbleAmp * (1 - p) * math.sin(2 * math.pi * 1.5 * p);
        x = _landStartX * (1 - p) + _driftX * math.sin(p * math.pi);
      case _Phase.returning:
        final p = (t / _returnMs).clamp(0.0, 1.0);
        final e = 1 - _easeOutCubic(p);
        x = _fromX * e;
        y = _fromY * e;
      case _Phase.idle:
        rotY = _revealed ? _restRotY : 0;
    }

    return _CoinTransform(x: x, y: y, rotXDeg: rotX, rotYDeg: rotY, lift: lift);
  }

  // --- build ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    _reduceMotion = MediaQuery.of(context).disableAnimations;

    ref.listen<int>(coinQuickAccessTriggerProvider, (previous, next) {
      if (previous != next) {
        _launchAuto();
      }
    });

    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(coinFlipProvider);
    final busy = _phase != _Phase.idle || state.isLoading;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RitualHeader(
              eyebrow: l10n.coinEyebrow,
              title: l10n.coinTitle,
              subtitle: l10n.coinRitualSubtitle,
              titleSize: 28,
            ),
            Expanded(child: Center(child: _buildArena())),
            _buildResultBlock(l10n, state, busy),
            const SizedBox(height: 10),
            RitualButton(
              label: l10n.coinButton,
              onPressed: busy ? null : _launchAuto,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.coinDragHelper,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textFaint,
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildArena() {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const CoinRuneRings(),
            AnimatedBuilder(
              animation: Listenable.merge([_frame, _impact]),
              builder: (context, _) => _buildCoinScene(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinScene() {
    final tr = _compute();
    final scale = 1 + tr.lift / 300;
    final shadowScale = math.max(0.4, 1 - tr.lift / 240);
    final shadowOpacity = math.max(0.1, 0.4 - tr.lift / 480);

    final modAngle = ((tr.rotYDeg % 360) + 360) % 360;
    final isFront = modAngle < 90 || modAngle > 270;

    final impactValue = _impact.value;
    final impactActive = impactValue > 0 && impactValue < 1;
    final shake = impactActive
        ? math.sin(impactValue * math.pi * 3) * 3 * (1 - impactValue)
        : 0.0;

    final dragMag = _phase == _Phase.dragging
        ? math.min(1.0, _dragOffset.distance / 100)
        : 0.0;

    final coinMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016)
      ..translateByDouble(tr.x + shake, tr.y - tr.lift, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..rotateX(tr.rotXDeg * math.pi / 180)
      ..rotateY(tr.rotYDeg * math.pi / 180);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Ground shadow.
        Transform.translate(
          offset: Offset(tr.x * 0.6, 96),
          child: Transform.scale(
            scale: shadowScale,
            child: Opacity(
              opacity: shadowOpacity,
              child: Container(
                width: 148,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.coinDropShadow, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Charge glow while dragging.
        if (dragMag > 0)
          Opacity(
            opacity: 0.25 + dragMag * 0.6,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold2.withValues(alpha: 0.55),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold2.withValues(alpha: 0.35),
                    blurRadius: 18 + dragMag * 30,
                    spreadRadius: dragMag * 6,
                  ),
                ],
              ),
            ),
          ),
        // Impact ring.
        if (impactActive)
          Opacity(
            opacity: (0.8 * (1 - impactValue)).clamp(0.0, 0.8),
            child: Transform.scale(
              scale: 0.4 + 0.6 * impactValue,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.impactRing, width: 1.5),
                ),
              ),
            ),
          ),
        // The coin itself.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: busyForGesture() ? null : _launchAuto,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform(
            alignment: Alignment.center,
            transform: coinMatrix,
            child: SizedBox(
              width: 168,
              height: 168,
              child: Stack(
                children: [
                  Opacity(
                    opacity: isFront ? 1 : 0,
                    child: const _CoinFace(front: true),
                  ),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: Opacity(
                      opacity: isFront ? 0 : 1,
                      child: const _CoinFace(front: false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Flash overlay.
        if (impactActive)
          IgnorePointer(
            child: Opacity(
              opacity: (0.22 * (1 - impactValue)).clamp(0.0, 0.22),
              child: Container(width: 300, height: 300, color: Colors.white),
            ),
          ),
      ],
    );
  }

  bool busyForGesture() =>
      _phase != _Phase.idle || ref.read(coinFlipProvider).isLoading;

  Widget _buildResultBlock(
    AppLocalizations l10n,
    CoinFlipState state,
    bool busy,
  ) {
    final showResult =
        _phase == _Phase.idle && _revealed && state.result != null;

    Widget child;
    if (showResult) {
      final label = state.result == 0 ? l10n.coinHeads : l10n.coinTails;
      child = Column(
        key: ValueKey('result-$label'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.coinResultCaption,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textCaption),
          ),
        ],
      );
    } else {
      final String hint;
      if (_phase == _Phase.dragging) {
        hint = l10n.coinHintDrag;
      } else if (busy) {
        hint = '';
      } else {
        hint = l10n.coinHint;
      }
      child = Text(
        hint,
        key: ValueKey('hint-$hint'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13.5, color: AppColors.textDim),
      );
    }

    return SizedBox(
      height: 92,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
      ),
    );
  }
}

/// One face of the coin. Front = CARA (gold + dark dot), back = COROA
/// (purple + crescent). Matches `faceStyle`/`faceIcon` from the prototype.
class _CoinFace extends StatelessWidget {
  const _CoinFace({required this.front});

  final bool front;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 168,
      height: 168,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: front
              ? const [AppColors.coinFrontStart, AppColors.coinFrontEnd]
              : const [AppColors.coinBackStart, AppColors.coinBackEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.coinBorder, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner highlight (approximates the CSS inset top highlight).
          Positioned(
            top: 10,
            left: 30,
            right: 30,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              front ? const _SunGlyph() : const _MoonGlyph(),
              const SizedBox(height: 10),
              Text(
                front ? l10n.coinHeads : l10n.coinTails,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.coinLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunGlyph extends StatelessWidget {
  const _SunGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x9E000000),
      ),
    );
  }
}

class _MoonGlyph extends StatelessWidget {
  const _MoonGlyph();

  @override
  Widget build(BuildContext context) {
    // Crescent: a dark disc with an offset coloured disc carving it.
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x9E000000),
            ),
          ),
          Positioned(
            left: 9,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.coinBackEnd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
