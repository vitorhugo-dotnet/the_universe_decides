import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:theuniversedecides/controllers/dice_roll_controller.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

void main() {
  group('DiceRollController', () {
    test('startRoll allows only one active request', () async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(diceRollProvider.notifier);

      final firstStart = controller.startRoll();
      final secondStart = controller.startRoll();

      expect(client.requestCount, 1);
      expect(container.read(diceRollProvider).isFetching, isTrue);

      client.complete('3');
      await Future.wait([firstStart, secondStart]);
      expect(container.read(diceRollProvider).isRolling, isTrue);
    });

    test('startRoll stores the generated request and its total', () async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(diceRollProvider.notifier);
      controller.setDiceCount(2);
      controller.setSelectedSides(6);

      final start = controller.startRoll();
      client.complete('3\n5');
      await start;

      final state = container.read(diceRollProvider);
      expect(state.rollRequest, isNotNull);
      expect(state.rollRequest!.notation, '2d6');
      expect(state.rollRequest!.results, [3, 5]);
      expect(state.total, 8);
      expect(state.isFetching, isFalse);
      expect(state.isRolling, isTrue);
      expect(state.isBusy, isTrue);
    });

    test('completion rejects a stale request id', () async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(diceRollProvider.notifier);

      final requestId = await _startAndGetRequestId(controller, client);
      controller.completeAnimation('stale-request');

      expect(container.read(diceRollProvider).activeRequestId, requestId);
      expect(container.read(diceRollProvider).isRolling, isTrue);
    });

    test('animation timeout releases only the active rolling lock', () async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(diceRollProvider.notifier);

      final requestId = await _startAndGetRequestId(controller, client);
      controller.timeoutAnimation(requestId);

      final state = container.read(diceRollProvider);
      expect(state.isFetching, isFalse);
      expect(state.isRolling, isFalse);
      expect(state.activeRequestId, isNull);
      expect(state.animationError, isNotNull);
      expect(state.results, [3]);
    });

    test('animation failure retains fetched values', () async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(diceRollProvider.notifier);

      final requestId = await _startAndGetRequestId(controller, client);
      controller.failAnimation(requestId, 'Renderer unavailable');

      final state = container.read(diceRollProvider);
      expect(state.isRolling, isFalse);
      expect(state.activeRequestId, isNull);
      expect(state.animationError, 'Renderer unavailable');
      expect(state.rollRequest!.results, [3]);
      expect(state.total, 3);
    });
  });
}

ProviderContainer _containerFor(_PendingClient client) {
  final service = RandomOrgService(client: client);
  return ProviderContainer(
    overrides: [randomOrgServiceProvider.overrideWithValue(service)],
  );
}

Future<String> _startAndGetRequestId(
  DiceRollController controller,
  _PendingClient client,
) async {
  final start = controller.startRoll();
  client.complete('3');
  await start;
  return controller.state.activeRequestId!;
}

class _PendingClient extends http.BaseClient {
  final _response = Completer<http.Response>();
  var requestCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestCount++;
    final response = await _response.future;
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }

  void complete(String body) {
    _response.complete(http.Response(body, 200));
  }
}
