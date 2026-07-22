import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:theuniversedecides/controllers/list_picker_controller.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

void main() {
  group('ListPickerController.spinWheel', () {
    test('rejects a spin with fewer than two items', () async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(listPickerProvider.notifier);
      controller.addItem('Only one');

      final winner = await controller.spinWheel();

      expect(winner, isNull);
      expect(client.requestCount, 0);
      expect(container.read(listPickerProvider).isLoading, isFalse);
    });

    test('reuses the same randomness service as the classic reveal',
        () async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(listPickerProvider.notifier);
      controller.addItem('Pizza, Sushi, Tacos');

      final spin = controller.spinWheel();
      expect(container.read(listPickerProvider).isLoading, isTrue);

      client.complete('1');
      final winner = await spin;

      expect(client.requestCount, 1);
      expect(winner, 1);
      final state = container.read(listPickerProvider);
      expect(state.selectedIndex, 1);
      expect(state.isLoading, isFalse);
      expect(state.isScanning, isFalse, reason: 'wheel has its own reveal');
    });

    test('blocks a second spin while one is already in flight', () async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(listPickerProvider.notifier);
      controller.addItem('A, B, C');

      final first = controller.spinWheel();
      final second = controller.spinWheel();

      expect(client.requestCount, 1);

      client.complete('0');
      final results = await Future.wait([first, second]);

      expect(results, [0, isNull]);
    });

    test('falls back to a local integer when the service fails', () async {
      final client = _FailingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      final controller = container.read(listPickerProvider.notifier);
      controller.addItem('A, B');

      final winner = await controller.spinWheel();

      expect(winner, anyOf(0, 1));
      expect(container.read(listPickerProvider).selectedIndex, winner);
    });
  });
}

ProviderContainer _containerFor(http.Client client) {
  final service = RandomOrgService(client: client);
  return ProviderContainer(
    overrides: [randomOrgServiceProvider.overrideWithValue(service)],
  );
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

class _FailingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw Exception('network unavailable');
  }
}
