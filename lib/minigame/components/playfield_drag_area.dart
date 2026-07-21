import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:theuniversedecides/minigame/components/player_star_component.dart';

/// A full-field, invisible component that turns any drag on the screen into
/// star movement — the player doesn't have to start the drag on the star.
class PlayfieldDragArea extends PositionComponent with DragCallbacks {
  PlayfieldDragArea({required this.star});

  final PlayerStarComponent star;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    star.moveTo(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    star.moveTo(event.localEndPosition);
  }
}
