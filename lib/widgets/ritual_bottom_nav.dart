import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:theuniversedecides/theme/app_colors.dart';

typedef RitualNavItem = ({String id, String label});

/// Custom bottom navigation from the prototype: geometric outline icons drawn
/// with borders, gold when active and 40%-white when inactive, over a blurred
/// translucent bar.
class RitualBottomNav extends StatelessWidget {
  const RitualBottomNav({
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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(14, 6, 14, bottomInset + 12),
          decoration: const BoxDecoration(
            color: AppColors.navBarBackground,
            border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
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

class _NavButton extends StatelessWidget {
  const _NavButton({
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              child: Center(
                child: _NavIcon(id: item.id, color: color),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
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

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.id, required this.color});

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
