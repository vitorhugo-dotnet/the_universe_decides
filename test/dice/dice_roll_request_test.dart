import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/dice/dice_roll_request.dart';

void main() {
  test('toJson serializes the dice roll request contract', () {
    final request = DiceRollRequest(
      requestId: 'request-42',
      notation: '2d6',
      results: [3, 5],
    );

    expect(request.toJson(), {
      'requestId': 'request-42',
      'notation': '2d6',
      'results': [3, 5],
    });
  });
}
