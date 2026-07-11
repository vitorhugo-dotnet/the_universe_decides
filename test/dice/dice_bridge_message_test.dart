import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/dice/dice_bridge_message.dart';

void main() {
  test('parse returns a validated rollCompleted message', () {
    final message = DiceBridgeMessage.parse(
      '{"event":"rollCompleted","requestId":"request-42","results":[3,5]}',
    );

    expect(message, isNotNull);
    expect(message!.event, DiceBridgeEvent.rollCompleted);
    expect(message.requestId, 'request-42');
    expect(message.results, [3, 5]);
  });

  test('parse returns null for malformed JSON', () {
    expect(DiceBridgeMessage.parse('{not valid json'), isNull);
  });

  test('parse returns null for an unknown event type', () {
    expect(
      DiceBridgeMessage.parse(
        '{"event":"rollStarted","requestId":"request-42","results":[]}',
      ),
      isNull,
    );
  });

  test('parse returns null when requestId is missing', () {
    expect(
      DiceBridgeMessage.parse('{"event":"rollCompleted","results":[3,5]}'),
      isNull,
    );
  });
}
