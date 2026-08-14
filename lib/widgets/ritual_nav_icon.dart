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
