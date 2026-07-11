class DiceRollRequest {
  DiceRollRequest({
    required this.requestId,
    required this.notation,
    required List<int> results,
  }) : results = List.unmodifiable(results);

  final String requestId;
  final String notation;
  final List<int> results;

  Map<String, Object> toJson() {
    return {
      'requestId': requestId,
      'notation': notation,
      'results': results,
    };
  }
}
