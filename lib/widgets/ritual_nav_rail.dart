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
