class DiceRollRequest {
  DiceRollRequest({
    required this.requestId,
    required this.notation,
    required List<int> results,
  }) : results = List.unmodifiable(results) {
    final match = _notationPattern.firstMatch(notation);
    if (match == null) {
      throw ArgumentError.value(notation, 'notation', 'Invalid dice notation');
    }

    final count = int.parse(match.group(1)!);
    final sides = int.parse(match.group(2)!);
    if (results.length != count ||
        results.any((result) => result < 1 || result > sides)) {
      throw ArgumentError.value(results, 'results', 'Invalid dice results');
    }
  }

  static final _notationPattern = RegExp(r'^([1-9]\d*)d(4|6|8|10|12|20|100)$');

  final String requestId;
  final String notation;
  final List<int> results;

  Map<String, Object> toJson() {
    return {'requestId': requestId, 'notation': notation, 'results': results};
  }
}
