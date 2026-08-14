import 'package:flutter/widgets.dart';

/// Smallest window width that stops being a hand-held column.
const double kRitualMediumMinWidth = 600;

/// Smallest window width that fits the navigation rail beside two panes.
///
/// The rail takes about 88 logical pixels, leaving 936 at this threshold; the
/// stage pane (420), the gutter (48) and a readable body pane need 928. Below
/// this a single column reads better than two squeezed ones.
const double kRitualExpandedMinWidth = 1024;

/// How much horizontal room the layout has to work with.
///
/// Bands are chosen from the window width and never from the platform, so an
/// Android phone and a narrow browser window get the identical [compact]
/// layout, and an Android tablet gets the wide one for free.
enum RitualBand { compact, medium, expanded }

extension RitualBandQueries on RitualBand {
  bool get isCompact => this == RitualBand.compact;
  bool get isMedium => this == RitualBand.medium;
  bool get isExpanded => this == RitualBand.expanded;
}

RitualBand ritualBandForWidth(double width) {
  if (width >= kRitualExpandedMinWidth) {
    return RitualBand.expanded;
  }
  if (width >= kRitualMediumMinWidth) {
    return RitualBand.medium;
  }
  return RitualBand.compact;
}

RitualBand ritualBandOf(BuildContext context) =>
    ritualBandForWidth(MediaQuery.sizeOf(context).width);
