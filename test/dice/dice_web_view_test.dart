import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/dice/dice_roll_request.dart';
import 'package:theuniversedecides/dice/dice_web_view.dart';

void main() {
  test('roll is a no-op before the local bridge is ready', () async {
    final controller = DiceWebViewController();

    await controller.roll(
      DiceRollRequest(
        requestId: 'request-42',
        notation: '2d6',
        results: [3, 5],
      ),
    );

    expect(controller.activeRequestId, isNull);
  });

  test('ignores malformed and stale bridge messages', () async {
    final completedRequestIds = <String>[];
    final controller = DiceWebViewController(
      onRollCompleted: (message) => completedRequestIds.add(message.requestId),
    );

    await controller.handleBridgeMessage('{not valid json');
    await controller.handleBridgeMessage(
      '{"event":"rollCompleted","requestId":"stale","results":[3,5]}',
    );

    expect(completedRequestIds, isEmpty);
    expect(controller.activeRequestId, isNull);
  });

  test('keeps the active request when a stale completion arrives', () async {
    final completedRequestIds = <String>[];
    final controller = DiceWebViewController(
      onRollCompleted: (message) => completedRequestIds.add(message.requestId),
    )..attachJavaScriptRunner((_) async {});

    await controller.handleBridgeMessage('{"type":"ready"}');
    await controller.roll(
      DiceRollRequest(
        requestId: 'request-42',
        notation: '2d6',
        results: [3, 5],
      ),
    );
    await controller.handleBridgeMessage(
      '{"event":"rollCompleted","requestId":"stale","results":[3,5]}',
    );

    expect(completedRequestIds, isEmpty);
    expect(controller.activeRequestId, 'request-42');
  });

  test('asks the bridge to finish only the active request', () async {
    final scripts = <String>[];
    final controller = DiceWebViewController()
      ..attachJavaScriptRunner((script) async => scripts.add(script));

    await controller.handleBridgeMessage('{"type":"ready"}');
    await controller.roll(
      DiceRollRequest(
        requestId: 'request-42',
        notation: '2d6',
        results: [3, 5],
      ),
    );
    await controller.finishRoll('stale-request');
    await controller.finishRoll('request-42');

    expect(scripts, hasLength(2));
    expect(scripts.last, 'window.DiceBridge.finish("request-42");');
  });
}
