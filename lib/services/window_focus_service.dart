import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reports whether the app window owns the screen, or whether a system window
/// — the notification panel above all — is holding the focus instead.
///
/// [AppLifecycleState] cannot answer this for the quick coin. Flutter only
/// leaves [AppLifecycleState.resumed] once Android calls
/// `onWindowFocusChanged(false)`, and `QuickCoinActivity` is launched *behind*
/// an already open panel: its window never held the focus, so no focus change
/// is ever reported and the engine keeps assuming the app is focused. The
/// native side answers with `Activity.hasWindowFocus()`, which is the real
/// current state rather than the accumulated one.
abstract class WindowFocusService {
  /// Emits the current focus state immediately, then every change.
  Stream<bool> get focusChanges;
}

final windowFocusServiceProvider = Provider<WindowFocusService>(
  (_) => const EventChannelWindowFocusService(),
);

class EventChannelWindowFocusService implements WindowFocusService {
  const EventChannelWindowFocusService();

  static const _eventChannel = EventChannel(
    'theuniversedecides/quick_access/window_focus',
  );

  @override
  Stream<bool> get focusChanges async* {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      yield true;
      return;
    }

    try {
      await for (final event in _eventChannel.receiveBroadcastStream()) {
        yield event is bool ? event : true;
      }
    } on MissingPluginException {
      // Only QuickCoinActivity registers this channel. Anywhere else — the
      // main activity, an older build — "the window is ours" is the right
      // assumption, and never holding a flip hostage to a missing channel
      // matters more than the gate.
      yield true;
    } on PlatformException {
      yield true;
    }
  }
}
