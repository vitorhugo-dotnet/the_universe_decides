import 'package:flutter_riverpod/flutter_riverpod.dart';

const entropyDriftTapsRequired = 7;
const entropyDriftTapWindow = Duration(milliseconds: 1500);

final entropyDriftUnlockProvider =
    NotifierProvider<EntropyDriftUnlockNotifier, int>(
      EntropyDriftUnlockNotifier.new,
    );

class EntropyDriftUnlockNotifier extends Notifier<int> {
  DateTime? _lastTapAt;

  @override
  int build() => 0;

  /// Registers a tap on the secret glyph. Returns true once the tap
  /// sequence reaches [entropyDriftTapsRequired] within the rolling
  /// [entropyDriftTapWindow]; the counter resets to 1 on that same call.
  bool registerTap({DateTime? now}) {
    final tapTime = now ?? DateTime.now();
    final lastTapAt = _lastTapAt;
    _lastTapAt = tapTime;

    final withinWindow =
        lastTapAt != null &&
        tapTime.difference(lastTapAt) <= entropyDriftTapWindow;
    final nextCount = withinWindow ? state + 1 : 1;

    if (nextCount >= entropyDriftTapsRequired) {
      state = 0;
      _lastTapAt = null;
      return true;
    }

    state = nextCount;
    return false;
  }
}
