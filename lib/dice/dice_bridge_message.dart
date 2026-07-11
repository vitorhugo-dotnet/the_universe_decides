import 'dart:convert';

enum DiceBridgeEvent { rollCompleted }

class DiceBridgeMessage {
  DiceBridgeMessage._({
    required this.event,
    required this.requestId,
    required List<int> results,
  }) : results = List.unmodifiable(results);

  final DiceBridgeEvent event;
  final String requestId;
  final List<int> results;

  static DiceBridgeMessage? parse(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      if (decoded['event'] != 'rollCompleted') {
        return null;
      }

      final requestId = decoded['requestId'];
      if (requestId is! String || requestId.isEmpty) {
        return null;
      }

      final rawResults = decoded['results'];
      if (rawResults is! List || rawResults.any((value) => value is! int)) {
        return null;
      }

      return DiceBridgeMessage._(
        event: DiceBridgeEvent.rollCompleted,
        requestId: requestId,
        results: rawResults.cast<int>(),
      );
    } on FormatException {
      return null;
    }
  }
}
