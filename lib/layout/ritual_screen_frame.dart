import 'package:flutter/material.dart';

import 'package:theuniversedecides/layout/ritual_breakpoint.dart';

/// Width of the stage pane in [RitualBand.expanded].
const double kRitualStagePaneWidth = 420;

/// Space between the stage pane and the body pane.
const double kRitualPaneGutter = 48;

/// Widest the single column grows in [RitualBand.medium].
const double kRitualMediumMaxWidth = 720;

/// Widest a stageless screen grows, chosen to keep the measure readable.
const double kRitualReadingMaxWidth = 640;

/// Arranges one screen's three slots according to the window's band.
///
/// This is the only widget in the app that decides arrangement. Screens pass
/// content and stay ignorant of the band, which is what stops six screens from
/// each growing their own notion of "wide".
class RitualScreenFrame extends StatelessWidget {
  const RitualScreenFrame({
    super.key,
    required this.header,
    required this.body,
    this.stage,
    this.stageFlexes = false,
    this.compactPadding = const EdgeInsets.fromLTRB(22, 20, 22, 18),
    this.stageSpacing = 24,
  });

  /// The screen's [RitualHeader].
  final Widget header;

  /// Result, controls and buttons.
  final Widget body;

  /// The visual object of the ritual. Screens without one — About — pass null
  /// and stay a single readable column in every band.
  final Widget? stage;

  /// Whether the stage should take the leftover height instead of its intrinsic
  /// size. True for the coin, whose arena fills the screen and does not scroll;
  /// false for screens that scroll.
  final bool stageFlexes;

  final EdgeInsets compactPadding;

  /// Vertical space between the stage and the header above it / body below
  /// it, in the non-flexing (scrolling) stacked arrangement.
  ///
  /// Screens had differing spacing around their ritual object before this
  /// frame existed, and a single hardcoded value silently shifts the ones
  /// that differ from it. Defaults to 24, the value every screen converted
  /// so far happened to use.
  final double stageSpacing;

  @override
  Widget build(BuildContext context) {
    switch (ritualBandOf(context)) {
      case RitualBand.compact:
        // Non-flexing screens scroll: the padding must travel inside the
        // SingleChildScrollView so it scrolls away with the content, exactly
        // as the pre-plan `SingleChildScrollView(padding: ...)` did. Flexing
        // screens (the coin) don't scroll, so the padding stays as an
        // enclosing Padding around the whole arrangement.
        final content = _stacked(scrollPadding: compactPadding);
        return stageFlexes
            ? Padding(padding: compactPadding, child: content)
            : content;
      case RitualBand.medium:
        final content = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: kRitualMediumMaxWidth,
            ),
            child: _stacked(scrollPadding: compactPadding),
          ),
        );
        return stageFlexes
            ? Padding(padding: compactPadding, child: content)
            : content;
      case RitualBand.expanded:
        return Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: stage == null ? _readingColumn() : _twoPane(),
        );
    }
  }

  /// [scrollPadding] is only applied when the screen scrolls (`!stageFlexes`):
  /// it is passed straight to the [SingleChildScrollView] so it remains part
  /// of the scrollable content, rather than fixed chrome around the viewport.
  Widget _stacked({EdgeInsets? scrollPadding}) {
    final stage = this.stage;

    if (stageFlexes) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (stage != null) Expanded(child: Center(child: stage)),
          body,
        ],
      );
    }

    return SingleChildScrollView(
      padding: scrollPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          if (stage != null) ...[
            SizedBox(height: stageSpacing),
            Center(child: stage),
            SizedBox(height: stageSpacing),
          ],
          body,
        ],
      ),
    );
  }

  Widget _readingColumn() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kRitualReadingMaxWidth),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header, const SizedBox(height: 20), body],
          ),
        ),
      ),
    );
  }

  Widget _twoPane() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: kRitualStagePaneWidth,
          child: Center(child: stage),
        ),
        const SizedBox(width: kRitualPaneGutter),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [header, const SizedBox(height: 20), body],
            ),
          ),
        ),
      ],
    );
  }
}
