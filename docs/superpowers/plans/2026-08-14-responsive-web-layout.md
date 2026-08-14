# Responsive Web Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every screen arrange itself from the window width, so a desktop browser gets a two-pane layout with a side navigation rail instead of a phone column centred in empty space.

**Architecture:** One `lib/layout/` package owns every arrangement decision. `ritual_breakpoint.dart` maps a width to one of three bands; `ritual_screen_frame.dart` takes three slots (`header`, optional `stage`, `body`) and arranges them per band. The six screens are rewritten to hand the frame their content instead of laying themselves out. The shell swaps `RitualBottomNav` for `RitualNavRail` in the widest band.

**Tech Stack:** Flutter 3.44.7, Dart, `flutter_riverpod`, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-08-14-responsive-web-layout-design.md`

## Global Constraints

- Bands are selected by **window width**, never by `kIsWeb`. The existing `kIsWeb` branch in `lib/screens/main_screen.dart` is removed.
- Band thresholds, exact values: `compact` is `< 600`, `medium` is `>= 600` and `< 1024`, `expanded` is `>= 1024`.
- `medium` content column is capped at `720`. `expanded` About column is capped at `640`. `expanded` stage pane is `420` wide with a `48` gutter.
- Behaviour in `compact` must not change. Any diff that alters what a `< 600` window renders is a defect.
- `lib/**` must never import `dart:io`. Browser-only libraries stay behind the conditional import in `lib/dice/dice_web_view.dart`. `test/web/web_compilation_path_test.dart` enforces both.
- Do not touch the randomness pipeline, the RANDOM.ORG fallback, or the results history.
- `flutter analyze` must report no issues before every commit.

## File Structure

**Created:**

| File | Responsibility |
| --- | --- |
| `lib/layout/ritual_breakpoint.dart` | `RitualBand` enum, thresholds, width-to-band resolution, `BuildContext` lookup |
| `lib/layout/ritual_screen_frame.dart` | The three-slot frame; the only widget that decides arrangement |
| `lib/widgets/ritual_nav_icon.dart` | `RitualNavIcon`, extracted from the private `_NavIcon` so bar and rail share one source |
| `lib/widgets/ritual_nav_rail.dart` | Vertical navigation for `expanded` |
| `test/support/layout_harness.dart` | Pumps a widget at a chosen logical window size |

**Modified:** `lib/widgets/ritual_bottom_nav.dart`, `lib/screens/main_screen.dart`, and the six screens under `lib/screens/`.

---

### Task 1: Breakpoint foundation

**Files:**
- Create: `lib/layout/ritual_breakpoint.dart`
- Create: `test/support/layout_harness.dart`
- Test: `test/layout/ritual_breakpoint_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum RitualBand { compact, medium, expanded }`; `const double kRitualMediumMinWidth = 600`; `const double kRitualExpandedMinWidth = 1024`; `RitualBand ritualBandForWidth(double width)`; `RitualBand ritualBandOf(BuildContext context)`; extension getters `RitualBand.isCompact`, `.isMedium`, `.isExpanded`. Test helper `Future<void> pumpAtWidth(WidgetTester tester, Widget child, {required double width, double height = 900})`.

- [ ] **Step 1: Write the failing test**

Create `test/layout/ritual_breakpoint_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_breakpoint.dart';

import '../support/layout_harness.dart';

void main() {
  test('width maps to the documented band, boundaries included', () {
    expect(ritualBandForWidth(0), RitualBand.compact);
    expect(ritualBandForWidth(599.99), RitualBand.compact);
    expect(ritualBandForWidth(600), RitualBand.medium);
    expect(ritualBandForWidth(1023.99), RitualBand.medium);
    expect(ritualBandForWidth(1024), RitualBand.expanded);
    expect(ritualBandForWidth(2560), RitualBand.expanded);
  });

  test('band convenience getters agree with the enum', () {
    expect(RitualBand.compact.isCompact, isTrue);
    expect(RitualBand.compact.isExpanded, isFalse);
    expect(RitualBand.medium.isMedium, isTrue);
    expect(RitualBand.expanded.isExpanded, isTrue);
  });

  testWidgets('ritualBandOf reads the window width', (tester) async {
    late RitualBand seen;

    for (final entry in const {
      400.0: RitualBand.compact,
      800.0: RitualBand.medium,
      1400.0: RitualBand.expanded,
    }.entries) {
      await pumpAtWidth(
        tester,
        Builder(
          builder: (context) {
            seen = ritualBandOf(context);
            return const SizedBox();
          },
        ),
        width: entry.key,
      );

      expect(seen, entry.value, reason: 'width ${entry.key}');
    }
  });
}
```

Create `test/support/layout_harness.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] inside a [MaterialApp] whose window is exactly [width] by
/// [height] logical pixels, so band-dependent layout can be asserted without
/// depending on the default test surface size.
Future<void> pumpAtWidth(
  WidgetTester tester,
  Widget child, {
  required double width,
  double height = 900,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/layout/ritual_breakpoint_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:theuniversedecides/layout/ritual_breakpoint.dart'`.

- [ ] **Step 3: Write minimal implementation**

Create `lib/layout/ritual_breakpoint.dart`:

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/layout/ritual_breakpoint_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/layout/ritual_breakpoint.dart test/layout/ritual_breakpoint_test.dart test/support/layout_harness.dart
git commit -m "feat(layout): resolve a layout band from the window width"
```

---

### Task 2: Share one navigation icon between bar and rail

The rail must draw the same six geometric icons the bar draws. They live in the private `_NavIcon` of `lib/widgets/ritual_bottom_nav.dart`, so extract them before the rail needs them. Behaviour is unchanged; this is a move.

**Files:**
- Create: `lib/widgets/ritual_nav_icon.dart`
- Modify: `lib/widgets/ritual_bottom_nav.dart` (delete the private `_NavIcon` class, import the new one, change the one call site from `_NavIcon(` to `RitualNavIcon(`)
- Test: `test/widgets/ritual_nav_icon_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `class RitualNavIcon extends StatelessWidget` with `const RitualNavIcon({super.key, required String id, required Color color})`. Valid ids: `coin`, `dice`, `cards`, `lists`, `tarot`, `about`.

- [ ] **Step 1: Write the failing test**

Create `test/widgets/ritual_nav_icon_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/widgets/ritual_nav_icon.dart';

void main() {
  testWidgets('every navigation id renders an icon in the given colour', (
    tester,
  ) async {
    for (final id in const ['coin', 'dice', 'cards', 'lists', 'tarot', 'about']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: RitualNavIcon(id: id, color: const Color(0xFFAABBCC))),
        ),
      );

      expect(
        find.byType(RitualNavIcon),
        findsOneWidget,
        reason: 'id $id must render',
      );
      expect(tester.takeException(), isNull, reason: 'id $id must not throw');
    }
  });

  testWidgets('an unknown id falls back instead of throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: RitualNavIcon(id: 'nope', color: Color(0xFFFFFFFF))),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/ritual_nav_icon_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:theuniversedecides/widgets/ritual_nav_icon.dart'`.

- [ ] **Step 3: Write minimal implementation**

Create `lib/widgets/ritual_nav_icon.dart` containing the geometric outline icons, moved verbatim from the private `_NavIcon` in `lib/widgets/ritual_bottom_nav.dart` and renamed:

```dart
import 'package:flutter/material.dart';

/// The geometric outline icons of the ritual navigation.
///
/// Shared rather than private because the bottom bar and the vertical rail are
/// the same navigation in two orientations; two copies would drift.
class RitualNavIcon extends StatelessWidget {
  const RitualNavIcon({super.key, required this.id, required this.color});

  final String id;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: color, width: 2);

    switch (id) {
      case 'coin':
      case 'about':
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(side),
          ),
        );
      case 'dice':
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.fromBorderSide(side),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      case 'cards':
        return Transform.rotate(
          angle: -8 * 3.1415926535 / 180,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.fromBorderSide(side),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      case 'lists':
        return Container(
          width: 20,
          height: 14,
          decoration: BoxDecoration(
            border: Border(left: side, top: side, bottom: side),
          ),
        );
      case 'tarot':
        return Container(
          width: 20,
          height: 24,
          decoration: BoxDecoration(
            border: Border.fromBorderSide(side),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      default:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(side),
          ),
        );
    }
  }
}
```

Then in `lib/widgets/ritual_bottom_nav.dart`: delete the whole `class _NavIcon extends StatelessWidget { ... }` block, add `import 'package:theuniversedecides/widgets/ritual_nav_icon.dart';`, and change the single call site inside `_NavButton` from `_NavIcon(id: item.id, color: color)` to `RitualNavIcon(id: item.id, color: color)`.

- [ ] **Step 4: Run the tests to verify nothing regressed**

Run: `flutter test test/widgets/ritual_nav_icon_test.dart && flutter test test/_capture_test.dart && flutter analyze`
Expected: new test PASSes; the capture goldens still PASS, proving the icons are pixel-identical after the move; analyze reports no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/ritual_nav_icon.dart lib/widgets/ritual_bottom_nav.dart test/widgets/ritual_nav_icon_test.dart
git commit -m "refactor(nav): share the navigation icons between bar and rail"
```

---

### Task 3: Vertical navigation rail

**Files:**
- Create: `lib/widgets/ritual_nav_rail.dart`
- Test: `test/widgets/ritual_nav_rail_test.dart`

**Interfaces:**
- Consumes: `RitualNavIcon` (Task 2); `RitualNavItem` from `lib/widgets/ritual_bottom_nav.dart`, which is `typedef RitualNavItem = ({String id, String label});`.
- Produces: `class RitualNavRail extends StatelessWidget` with `const RitualNavRail({super.key, required List<RitualNavItem> items, required int selectedIndex, required ValueChanged<int> onSelected, ValueChanged<int>? onLongPress})`; `const double kRitualNavRailWidth = 88`.

- [ ] **Step 1: Write the failing test**

Create `test/widgets/ritual_nav_rail_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/widgets/ritual_bottom_nav.dart';
import 'package:theuniversedecides/widgets/ritual_nav_rail.dart';

const _items = <RitualNavItem>[
  (id: 'coin', label: 'Coin'),
  (id: 'dice', label: 'Dice'),
  (id: 'cards', label: 'Cards'),
  (id: 'lists', label: 'Lists'),
  (id: 'tarot', label: 'Tarot'),
  (id: 'about', label: 'About'),
];

void main() {
  testWidgets('renders one entry per item and reports taps by index', (
    tester,
  ) async {
    final tapped = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RitualNavRail(
            items: _items,
            selectedIndex: 0,
            onSelected: tapped.add,
          ),
        ),
      ),
    );

    expect(find.text('Tarot'), findsOneWidget);
    await tester.tap(find.text('Tarot'));
    expect(tapped, [4]);
  });

  testWidgets('reports a long press by index, so Entropy Drift still opens', (
    tester,
  ) async {
    final pressed = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RitualNavRail(
            items: _items,
            selectedIndex: 0,
            onSelected: (_) {},
            onLongPress: pressed.add,
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Coin'));
    expect(pressed, [0]);
  });

  testWidgets('occupies the documented rail width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              RitualNavRail(
                items: _items,
                selectedIndex: 0,
                onSelected: (_) {},
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(RitualNavRail)).width,
      kRitualNavRailWidth,
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/ritual_nav_rail_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:theuniversedecides/widgets/ritual_nav_rail.dart'`.

- [ ] **Step 3: Write minimal implementation**

Create `lib/widgets/ritual_nav_rail.dart`:

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_bottom_nav.dart';
import 'package:theuniversedecides/widgets/ritual_nav_icon.dart';

/// Width the rail reserves. `kRitualExpandedMinWidth` is derived from it.
const double kRitualNavRailWidth = 88;

/// The ritual navigation, turned on its side for a window wide enough that a
/// bottom bar would strand the controls far from the content.
///
/// Same items, same icons, same gold-on-active treatment and the same blurred
/// translucent surface as [RitualBottomNav]; only the axis changes.
class RitualNavRail extends StatelessWidget {
  const RitualNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.onLongPress,
  });

  final List<RitualNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kRitualNavRailWidth,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.navBarBackground,
              border: Border(right: BorderSide(color: Color(0x14FFFFFF))),
            ),
            child: SafeArea(
              right: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _RailButton(
                        item: items[i],
                        active: i == selectedIndex,
                        onTap: () => onSelected(i),
                        onLongPress: onLongPress == null
                            ? null
                            : () => onLongPress!(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.item,
    required this.active,
    required this.onTap,
    this.onLongPress,
  });

  final RitualNavItem item;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.gold1 : AppColors.textFaint;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              child: Center(child: RitualNavIcon(id: item.id, color: color)),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/ritual_nav_rail_test.dart && flutter analyze`
Expected: PASS, 3 tests; analyze reports no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/ritual_nav_rail.dart test/widgets/ritual_nav_rail_test.dart
git commit -m "feat(nav): add the vertical navigation rail"
```

---

### Task 4: The screen frame

The frame is the only widget allowed to decide arrangement. Screens hand it slots.

Two body behaviours exist in the codebase and both must survive: the coin screen fills the available height and does not scroll, while the other five scroll. `stageFlexes` selects between them.

**Files:**
- Create: `lib/layout/ritual_screen_frame.dart`
- Test: `test/layout/ritual_screen_frame_test.dart`

**Interfaces:**
- Consumes: `RitualBand`, `ritualBandOf` (Task 1).
- Produces: `class RitualScreenFrame extends StatelessWidget` with
  `const RitualScreenFrame({super.key, required Widget header, required Widget body, Widget? stage, bool stageFlexes = false, EdgeInsets compactPadding = const EdgeInsets.fromLTRB(22, 20, 22, 18)})`;
  `const double kRitualStagePaneWidth = 420`; `const double kRitualPaneGutter = 48`; `const double kRitualMediumMaxWidth = 720`; `const double kRitualReadingMaxWidth = 640`.

- [ ] **Step 1: Write the failing test**

Create `test/layout/ritual_screen_frame_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';

import '../support/layout_harness.dart';

const _header = Text('HEADER');
const _body = Text('BODY');
const _stage = SizedBox(key: ValueKey('stage'), width: 100, height: 100);

void main() {
  testWidgets('every slot renders in every band', (tester) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(header: _header, body: _body, stage: _stage),
        width: width,
      );

      expect(find.text('HEADER'), findsOneWidget, reason: 'width $width');
      expect(find.text('BODY'), findsOneWidget, reason: 'width $width');
      expect(find.byKey(const ValueKey('stage')), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('compact stacks the stage above the body', (tester) async {
    await pumpAtWidth(
      tester,
      const RitualScreenFrame(header: _header, body: _body, stage: _stage),
      width: 400,
    );

    final stage = tester.getRect(find.byKey(const ValueKey('stage')));
    final body = tester.getRect(find.text('BODY'));
    expect(stage.bottom, lessThanOrEqualTo(body.top));
  });

  testWidgets('expanded puts the stage left of the body', (tester) async {
    await pumpAtWidth(
      tester,
      const RitualScreenFrame(header: _header, body: _body, stage: _stage),
      width: 1400,
    );

    final stage = tester.getRect(find.byKey(const ValueKey('stage')));
    final body = tester.getRect(find.text('BODY'));
    expect(stage.right, lessThanOrEqualTo(body.left));
  });

  testWidgets('a frame with no stage stays a single column when expanded', (
    tester,
  ) async {
    await pumpAtWidth(
      tester,
      const RitualScreenFrame(header: _header, body: _body),
      width: 1400,
    );

    final header = tester.getRect(find.text('HEADER'));
    final body = tester.getRect(find.text('BODY'));
    expect(header.bottom, lessThanOrEqualTo(body.top),
        reason: 'a stageless screen must not be forced into two panes');
    expect(body.width, lessThanOrEqualTo(kRitualReadingMaxWidth));
  });

  testWidgets('medium caps the column at the documented width', (tester) async {
    await pumpAtWidth(
      tester,
      const RitualScreenFrame(
        header: _header,
        body: SizedBox(key: ValueKey('wide'), height: 20),
      ),
      width: 900,
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('wide'))).width,
      lessThanOrEqualTo(kRitualMediumMaxWidth),
    );
  });

  testWidgets('no band overflows', (tester) async {
    for (final width in const [400.0, 600.0, 1023.0, 1024.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const RitualScreenFrame(
          header: _header,
          body: _body,
          stage: _stage,
          stageFlexes: true,
        ),
        width: width,
        height: 640,
      );

      expect(tester.takeException(), isNull, reason: 'width $width overflowed');
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/layout/ritual_screen_frame_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:theuniversedecides/layout/ritual_screen_frame.dart'`.

- [ ] **Step 3: Write minimal implementation**

Create `lib/layout/ritual_screen_frame.dart`:

```dart
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

  @override
  Widget build(BuildContext context) {
    switch (ritualBandOf(context)) {
      case RitualBand.compact:
        return Padding(padding: compactPadding, child: _stacked());
      case RitualBand.medium:
        return Padding(
          padding: compactPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: kRitualMediumMaxWidth,
              ),
              child: _stacked(),
            ),
          ),
        );
      case RitualBand.expanded:
        return Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: stage == null ? _readingColumn() : _twoPane(),
        );
    }
  }

  Widget _stacked() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          if (stage != null) ...[
            const SizedBox(height: 24),
            Center(child: stage),
            const SizedBox(height: 24),
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/layout/ritual_screen_frame_test.dart && flutter analyze`
Expected: PASS, 6 tests; analyze reports no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/layout/ritual_screen_frame.dart test/layout/ritual_screen_frame_test.dart
git commit -m "feat(layout): add the three-slot screen frame"
```

---

### Task 5: Wire the shell to the band

Replaces the `kIsWeb` branch in `lib/screens/main_screen.dart` with band selection, and swaps the bottom bar for the rail in `expanded`.

**Files:**
- Modify: `lib/screens/main_screen.dart` — delete `const double _webShellMaxWidth = 560;` and the `import 'package:flutter/foundation.dart' show kIsWeb;`, and replace the `build` method's `shell`/`Scaffold` section
- Test: `test/screens/main_screen_layout_test.dart`

**Interfaces:**
- Consumes: `RitualBand`, `ritualBandOf` (Task 1); `RitualNavRail` (Task 3).
- Produces: nothing new; `MainScreen` keeps its existing public API.

- [ ] **Step 1: Write the failing test**

Create `test/screens/main_screen_layout_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/screens/main_screen.dart';
import 'package:theuniversedecides/widgets/ritual_bottom_nav.dart';
import 'package:theuniversedecides/widgets/ritual_nav_rail.dart';

import '../support/fake_webview_platform.dart';
import '../support/layout_harness.dart';

Future<void> _pumpShell(WidgetTester tester, double width) async {
  await pumpAtWidth(
    tester,
    const ProviderScope(child: MainScreen()),
    width: width,
  );
  await tester.pump();
}

void main() {
  setUpAll(FakeWebViewPlatform.register);

  testWidgets('narrow windows keep the bottom bar', (tester) async {
    await _pumpShell(tester, 400);

    expect(find.byType(RitualBottomNav), findsOneWidget);
    expect(find.byType(RitualNavRail), findsNothing);
  });

  testWidgets('medium windows keep the bottom bar', (tester) async {
    await _pumpShell(tester, 800);

    expect(find.byType(RitualBottomNav), findsOneWidget);
    expect(find.byType(RitualNavRail), findsNothing);
  });

  testWidgets('wide windows swap the bar for the rail', (tester) async {
    await _pumpShell(tester, 1400);

    expect(find.byType(RitualNavRail), findsOneWidget);
    expect(find.byType(RitualBottomNav), findsNothing);
  });

  testWidgets('the rail selects a tab', (tester) async {
    await _pumpShell(tester, 1400);

    await tester.tap(find.descendant(
      of: find.byType(RitualNavRail),
      matching: find.text('Cards'),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/main_screen_layout_test.dart`
Expected: FAIL — the wide-window test finds no `RitualNavRail`, because `MainScreen` still renders `RitualBottomNav` at every width.

- [ ] **Step 3: Write minimal implementation**

In `lib/screens/main_screen.dart`, delete the `kIsWeb` import and the `_webShellMaxWidth` constant, add:

```dart
import 'package:theuniversedecides/layout/ritual_breakpoint.dart';
import 'package:theuniversedecides/widgets/ritual_nav_rail.dart';
```

and replace everything in `build` from `final shell = Column(` to the closing of the returned `Scaffold` with:

```dart
    final band = ritualBandOf(context);
    final content = SafeArea(
      bottom: false,
      child: IndexedStack(index: _selectedIndex, children: _screens),
    );

    void select(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    // The rail replaces the bar rather than joining it: a window wide enough
    // for two panes strands a bottom bar far below the content it drives.
    final shell = band.isExpanded
        ? Row(
            children: [
              RitualNavRail(
                items: navItems,
                selectedIndex: _selectedIndex,
                onSelected: select,
                onLongPress: _openEntropyDrift,
              ),
              Expanded(child: content),
            ],
          )
        : Column(
            children: [
              Expanded(child: content),
              RitualBottomNav(
                items: navItems,
                selectedIndex: _selectedIndex,
                onSelected: select,
                onLongPress: _openEntropyDrift,
              ),
            ],
          );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RitualBackground(
        child: Stack(children: [const ShellRuneRings(), shell]),
      ),
    );
```

The old web-only `Center`/`ConstrainedBox` wrapper is gone: the frame from Task 4 now owns content width in every band.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/main_screen_layout_test.dart && flutter test && flutter analyze`
Expected: the new test PASSes; the whole suite PASSes, including `test/_capture_test.dart`, whose 410x870 logical surface stays in `compact`; analyze reports no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/main_screen.dart test/screens/main_screen_layout_test.dart
git commit -m "feat(layout): choose the shell from the band, not the platform"
```

---

### Task 6: Coin screen onto the frame

**Files:**
- Modify: `lib/screens/coin_flip_screen.dart` — the `build` method only; the physics, ticker, drag handling and `_buildArena`/`_buildCoinScene`/`_buildResultBlock` are untouched
- Test: `test/screens/coin_flip_layout_test.dart`

**Interfaces:**
- Consumes: `RitualScreenFrame` (Task 4).
- Produces: nothing new.

- [ ] **Step 1: Write the failing test**

Create `test/screens/coin_flip_layout_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('the coin lays out through the frame in every band', (
    tester,
  ) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: CoinFlipScreen()),
        width: width,
        height: 700,
      );

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('quick mode bypasses the frame', (tester) async {
    await pumpAtWidth(
      tester,
      const ProviderScope(child: CoinFlipScreen(quickMode: true)),
      width: 400,
    );

    expect(find.byType(RitualScreenFrame), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/coin_flip_layout_test.dart`
Expected: FAIL — no `RitualScreenFrame` found; the screen still builds its own `Padding`/`Column`.

- [ ] **Step 3: Write minimal implementation**

In `lib/screens/coin_flip_screen.dart` add `import 'package:theuniversedecides/layout/ritual_screen_frame.dart';` and replace the returned tree of `build` — everything from `return GestureDetector(` to its closing `);` — with:

```dart
    // Quick mode is a bare full-screen coin launched from the tile: no header,
    // no controls, and nothing for the frame to arrange.
    if (widget.quickMode) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => unawaited(_closeQuickMode()),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Center(child: _buildArena())),
                _buildResultBlock(l10n, state, busy),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: RitualScreenFrame(
        stageFlexes: true,
        compactPadding: const EdgeInsets.fromLTRB(24, 24, 24, 6),
        header: RitualHeader(
          eyebrow: l10n.coinEyebrow,
          title: l10n.coinTitle,
          subtitle: l10n.coinRitualSubtitle,
          titleSize: 28,
        ),
        stage: _buildArena(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              style: const TextStyle(fontSize: 12, color: AppColors.textFaint),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/coin_flip_layout_test.dart && flutter test test/_capture_test.dart && flutter test test/quick_coin_route_test.dart && flutter analyze`
Expected: all PASS. The capture goldens prove the compact coin is unchanged; the quick-coin test proves the tile route still works.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/coin_flip_screen.dart test/screens/coin_flip_layout_test.dart
git commit -m "feat(coin): lay the coin out through the screen frame"
```

---

### Task 7: Cards screen onto the frame

**Files:**
- Modify: `lib/screens/card_draw_screen.dart` — the `build` method only; `_CardFace` and the flip animation are untouched
- Test: `test/screens/card_draw_layout_test.dart`

**Interfaces:**
- Consumes: `RitualScreenFrame` (Task 4).
- Produces: nothing new.

- [ ] **Step 1: Write the failing test**

Create `test/screens/card_draw_layout_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/card_draw_screen.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('the card lays out through the frame in every band', (
    tester,
  ) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: CardDrawScreen()),
        width: width,
        height: 700,
      );

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/card_draw_layout_test.dart`
Expected: FAIL — no `RitualScreenFrame` found.

- [ ] **Step 3: Write minimal implementation**

In `lib/screens/card_draw_screen.dart` add `import 'package:theuniversedecides/layout/ritual_screen_frame.dart';`, then replace the returned `SingleChildScrollView(...)` with a `RitualScreenFrame`. The stage is the existing `SizedBox(width: 210, height: 296, child: AnimatedSwitcher(...))` — move that subtree verbatim into the `stage:` argument, dropping the `Center` and the two `SizedBox(height: 24)` spacers, which the frame now supplies:

```dart
    return RitualScreenFrame(
      header: RitualHeader(
        eyebrow: l10n.cardEyebrow,
        title: l10n.cardTitle,
        subtitle: l10n.cardSubtitle,
      ),
      stage: SizedBox(
        width: 210,
        height: 296,
        child: AnimatedSwitcher(
          // ...the existing AnimatedSwitcher arguments, unchanged...
        ),
      ),
      body: RitualButton(
        label: l10n.cardDrawButton,
        onPressed: state.isLoading ? null : _drawCard,
        maxWidth: double.infinity,
      ),
    );
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/card_draw_layout_test.dart && flutter test test/_capture_test.dart && flutter analyze`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/card_draw_screen.dart test/screens/card_draw_layout_test.dart
git commit -m "feat(cards): lay the card draw out through the screen frame"
```

---

### Task 8: Tarot screen onto the frame

The tarot card already runs `AspectRatio(2/3)` with a `LayoutBuilder` whose local `isCompact` is derived from height. That flag becomes band-derived so two notions of "compact" cannot disagree.

**Files:**
- Modify: `lib/screens/tarot_draw_screen.dart` — the screen's `build` method, and the `isCompact` line inside the card's `LayoutBuilder` (currently `final isCompact = constraints.maxHeight < 400;`)
- Test: `test/screens/tarot_draw_layout_test.dart`

**Interfaces:**
- Consumes: `RitualScreenFrame` (Task 4); `ritualBandOf`, `RitualBand` (Task 1).
- Produces: nothing new.

- [ ] **Step 1: Write the failing test**

Create `test/screens/tarot_draw_layout_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/tarot_draw_screen.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('the tarot lays out through the frame in every band', (
    tester,
  ) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: TarotDrawScreen()),
        width: width,
        height: 700,
      );

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/tarot_draw_layout_test.dart`
Expected: FAIL — no `RitualScreenFrame` found.

- [ ] **Step 3: Write minimal implementation**

Add `import 'package:theuniversedecides/layout/ritual_screen_frame.dart';` and `import 'package:theuniversedecides/layout/ritual_breakpoint.dart';`.

Replace the screen's returned scrolling column with a `RitualScreenFrame` whose `stage` is the existing tarot card widget and whose `body` is the draw button plus the reading text that follows it today.

In the card's `LayoutBuilder`, replace:

```dart
          final isCompact = constraints.maxHeight < 400;
```

with:

```dart
          // The band, not a private height threshold: a wide window gives the
          // card a tall pane, and two disagreeing notions of "compact" would
          // shrink the type while the card grows.
          final isCompact =
              ritualBandOf(context).isCompact && constraints.maxHeight < 400;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/tarot_draw_layout_test.dart && flutter test test/tarot_draw_controller_test.dart && flutter test test/_capture_test.dart && flutter analyze`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/tarot_draw_screen.dart test/screens/tarot_draw_layout_test.dart
git commit -m "feat(tarot): lay the tarot draw out through the screen frame"
```

---

### Task 9: Dice screen onto the frame

The dice surface is an `<iframe>` behind `HtmlElementView` on the web. It must keep a stable box: resizing it while the physics animation runs is where the bridge breaks. The stage therefore keeps the existing fixed `320` height region rather than flexing.

**Files:**
- Modify: `lib/screens/dice_roll_screen.dart` — the `build` method only; `_DiceAnimationRegion`, `_PillButton` and the roll plumbing are untouched
- Test: `test/screens/dice_roll_layout_test.dart`

**Interfaces:**
- Consumes: `RitualScreenFrame` (Task 4).
- Produces: nothing new.

- [ ] **Step 1: Write the failing test**

Create `test/screens/dice_roll_layout_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/dice/dice_web_view.dart';
import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/dice_roll_screen.dart';

import '../support/fake_webview_platform.dart';
import '../support/layout_harness.dart';

void main() {
  setUpAll(FakeWebViewPlatform.register);

  testWidgets('the dice lay out through the frame in every band', (
    tester,
  ) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: DiceRollScreen()),
        width: width,
        height: 700,
      );

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('the dice surface keeps one stable size across bands', (
    tester,
  ) async {
    final sizes = <double>[];

    for (final width in const [400.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: DiceRollScreen()),
        width: width,
        height: 700,
      );

      sizes.add(tester.getSize(find.byType(DiceWebView)).height);
    }

    expect(
      sizes.first,
      sizes.last,
      reason:
          'the dice iframe must not be resized by the band; the physics bridge '
          'breaks when the surface changes size mid-animation',
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/dice_roll_layout_test.dart`
Expected: FAIL — no `RitualScreenFrame` found.

- [ ] **Step 3: Write minimal implementation**

Add `import 'package:theuniversedecides/layout/ritual_screen_frame.dart';`, then replace the returned `SingleChildScrollView(...)` with:

```dart
    return RitualScreenFrame(
      header: RitualHeader(
        eyebrow: l10n.diceEyebrow,
        title: l10n.diceTitle,
        titleSize: 22,
      ),
      stage: _DiceAnimationRegion(
        child:
            widget.diceWebViewBuilder?.call(_diceWebViewController) ??
            DiceWebView(controller: _diceWebViewController),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ...the existing count pills, side pills, roll button, animation
          // error text and total text, in their current order, with the
          // `_DiceAnimationRegion` block removed because it is now the stage...
        ],
      ),
    );
```

Keep `_DiceAnimationRegion`'s fixed `SizedBox(height: 320)` exactly as it is; that fixed size is what the second test asserts.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/dice_roll_layout_test.dart && flutter test test/dice_roll_screen_test.dart && flutter test test/dice && flutter test test/_capture_test.dart && flutter analyze`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/dice_roll_screen.dart test/screens/dice_roll_layout_test.dart
git commit -m "feat(dice): lay the dice roll out through the screen frame"
```

---

### Task 10: Lists screen onto the frame

Lists is the one screen whose stage depends on state. In wheel mode the stage is the wheel. In classic mode there is no visual object, so the stage shows the drawn result instead — the skeleton must not change when the mode toggles, or the page appears to navigate elsewhere.

**Files:**
- Modify: `lib/screens/list_picker_screen.dart` — the `build` method; add a private `Widget _buildStage(AppLocalizations l10n, ListPickerState state)`
- Test: `test/screens/list_picker_layout_test.dart`

**Interfaces:**
- Consumes: `RitualScreenFrame` (Task 4).
- Produces: nothing new. The existing `_SelectedBanner` widget is reused as the classic-mode stage content.

- [ ] **Step 1: Write the failing test**

Create `test/screens/list_picker_layout_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/list_picker_screen.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('lists lay out through the frame in every band', (tester) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: ListPickerScreen()),
        width: width,
        height: 700,
      );

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('toggling the mode keeps the wide skeleton', (tester) async {
    await pumpAtWidth(
      tester,
      const ProviderScope(child: ListPickerScreen()),
      width: 1400,
      height: 700,
    );

    final frameBefore = tester.getRect(find.byType(RitualScreenFrame));

    await tester.tap(find.text('Wheel'));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byType(RitualScreenFrame)),
      frameBefore,
      reason:
          'switching modes must not resize the page, or it reads as having '
          'navigated somewhere else',
    );
    expect(tester.takeException(), isNull);
  });
}
```

If the English label for the wheel toggle is not `Wheel`, read the real value from `lib/l10n/app_en.arb` (key `listModeWheel`) and use it.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/list_picker_layout_test.dart`
Expected: FAIL — no `RitualScreenFrame` found.

- [ ] **Step 3: Write minimal implementation**

Add `import 'package:theuniversedecides/layout/ritual_screen_frame.dart';`. Add the stage builder:

```dart
  /// The stage for the current mode.
  ///
  /// Wheel mode has a visual object. Classic mode has none, so the drawn result
  /// takes the wheel's place: leaving the pane empty looks broken, and dropping
  /// to one column on the toggle makes the page jump.
  Widget _buildStage(AppLocalizations l10n, ListPickerState state) {
    if (_mode == _ListPickerMode.wheel) {
      return const ListPickerWheelView();
    }

    final selectedIndex = state.selectedIndex;
    if (selectedIndex == null) {
      return _EmptyState(text: l10n.listEmptyState);
    }

    return _SelectedBanner(
      label: l10n.listChosenByUniverse,
      value: state.items[selectedIndex],
    );
  }
```

Then replace the returned `SingleChildScrollView(...)` with a `RitualScreenFrame` whose `stage:` is `_buildStage(l10n, state)` and whose `body:` is the existing column content — text field row, mode toggle, and the item rows — with the wheel view and the selected banner removed from it, since both now live in the stage.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/list_picker_layout_test.dart && flutter test test/list_picker_screen_test.dart && flutter test test/_capture_test.dart && flutter analyze`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/list_picker_screen.dart test/screens/list_picker_layout_test.dart
git commit -m "feat(lists): give classic mode a stage and lay lists out through the frame"
```

---

### Task 11: About screen onto the frame

About has no ritual object. It passes no stage, so the frame keeps it a single centred column capped at `kRitualReadingMaxWidth`.

**Files:**
- Modify: `lib/screens/about_me_screen.dart` — the `build` method only
- Test: `test/screens/about_me_layout_test.dart`

**Interfaces:**
- Consumes: `RitualScreenFrame`, `kRitualReadingMaxWidth` (Task 4).
- Produces: nothing new.

- [ ] **Step 1: Write the failing test**

Create `test/screens/about_me_layout_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/about_me_screen.dart';

import '../support/layout_harness.dart';

void main() {
  testWidgets('about lays out through the frame in every band', (tester) async {
    for (final width in const [400.0, 800.0, 1400.0]) {
      await pumpAtWidth(
        tester,
        const ProviderScope(child: AboutMeScreen()),
        width: width,
        height: 700,
      );
      await tester.pump();

      expect(find.byType(RitualScreenFrame), findsOneWidget,
          reason: 'width $width');
    }
  });

  testWidgets('about never widens past a readable measure', (tester) async {
    await pumpAtWidth(
      tester,
      const ProviderScope(child: AboutMeScreen()),
      width: 1400,
      height: 700,
    );
    await tester.pump();

    final title = find.text('About').first;
    expect(
      tester.getRect(title).left,
      greaterThan(kRitualReadingMaxWidth / 4),
      reason: 'a stageless page must stay centred, not hug the left edge',
    );
  });
}
```

If the English About title is not `About`, read the real value from `lib/l10n/app_en.arb` (key `aboutTitle`) and use it.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/about_me_layout_test.dart`
Expected: FAIL — no `RitualScreenFrame` found.

- [ ] **Step 3: Write minimal implementation**

Add `import 'package:theuniversedecides/layout/ritual_screen_frame.dart';`, then replace the returned `SingleChildScrollView(...)` with:

```dart
    return RitualScreenFrame(
      header: RitualHeader(eyebrow: l10n.aboutEyebrow, title: l10n.aboutTitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ...the existing children, unchanged, minus the leading RitualHeader
          // and its following SizedBox(height: 20), which the frame supplies...
        ],
      ),
    );
```

Leave the `if (!kIsWeb)` guard around the Quick Settings section exactly as it is: that is a platform capability check, not a layout decision, and it is correct.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/about_me_layout_test.dart && flutter test test/about_privacy_policy_test.dart && flutter test test/_capture_test.dart && flutter analyze`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/about_me_screen.dart test/screens/about_me_layout_test.dart
git commit -m "feat(about): keep about a single readable column on wide windows"
```

---

### Task 12: Version and release notes

**Files:**
- Modify: `pubspec.yaml` (line 6)
- Modify: `CHANGELOG.xml` (replace all content)

- [ ] **Step 1: Bump the semantic version**

Read the current value on line 6 of `pubspec.yaml`. It is `version: <major>.<minor>.<patch>+<build>`. This is a user-visible `feat`, so apply a `MINOR` increment: raise `<minor>` by one and reset `<patch>` to `0`. **Preserve everything after `+` byte for byte** — CI owns the build number and a manual change to it breaks the release.

From the `2.6.x` line currently on `master` the result is `2.7.0`, keeping the existing build number.

- [ ] **Step 2: Rewrite the release notes**

Replace the entire content of `CHANGELOG.xml` — never append to the old notes. Use exactly these nine locale tags in this order: `en-US`, `pt-BR`, `es-ES`, `de`, `fr-FR`, `hi`, `it`, `tr`, `uk`. Each block stays under 500 Unicode characters, uses `-` bullets, and every opening tag has an identical closing tag. Do not mention the Entropy Drift minigame; it is a hidden easter egg.

Write exactly this content:

```xml
<en-US>
- The web version now adapts to your screen: wide windows get a side menu and a two-column layout. 🖥️
</en-US>

<pt-BR>
- A versão web agora se adapta à sua tela: janelas largas ganham menu lateral e layout em duas colunas. 🖥️
</pt-BR>

<es-ES>
- La versión web ahora se adapta a tu pantalla: las ventanas anchas tienen menú lateral y diseño a dos columnas. 🖥️
</es-ES>

<de>
- Die Web-Version passt sich jetzt deinem Bildschirm an: breite Fenster erhalten ein Seitenmenü und ein zweispaltiges Layout. 🖥️
</de>

<fr-FR>
- La version web s'adapte désormais à votre écran : les fenêtres larges obtiennent un menu latéral et une mise en page sur deux colonnes. 🖥️
</fr-FR>

<hi>
- वेब संस्करण अब आपकी स्क्रीन के अनुसार ढल जाता है: चौड़ी विंडो में साइड मेन्यू और दो-कॉलम लेआउट मिलता है। 🖥️
</hi>

<it>
- La versione web ora si adatta al tuo schermo: le finestre larghe hanno un menu laterale e un layout a due colonne. 🖥️
</it>

<tr>
- Web sürümü artık ekranınıza uyum sağlıyor: geniş pencerelerde yan menü ve iki sütunlu düzen geliyor. 🖥️
</tr>

<uk>
- Веб-версія тепер підлаштовується під ваш екран: широкі вікна отримують бічне меню та макет у дві колонки. 🖥️
</uk>
```

- [ ] **Step 3: Verify**

Run: `flutter analyze && flutter test`
Expected: all PASS.

Confirm by eye that `pubspec.yaml` line 6 changed only in the `MAJOR.MINOR.PATCH` portion, and that `CHANGELOG.xml` contains exactly nine locale blocks with matching open and close tags.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml CHANGELOG.xml
git commit -m "chore: release the responsive web layout"
```

---

## Verification after the last task

Run the full gate the CI runs, plus a real browser check:

```bash
flutter analyze
flutter test
flutter build web --release --base-href "/"
```

Then serve `build/web` and open it at three window sizes — roughly 400, 800 and 1400 logical pixels wide — confirming: the bottom bar at the two narrow sizes and the rail at the widest; no horizontal scrollbar at any size; the coin, dice, cards, tarot and wheel all reachable and operable; and the dice animation completing without the surface resizing.
