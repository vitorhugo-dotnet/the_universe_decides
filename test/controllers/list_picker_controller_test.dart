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

  group('ListPickerController.addItem', () {
    late ProviderContainer container;
    late ListPickerController controller;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      controller = container.read(listPickerProvider.notifier);
    });

    test('adds a new single item', () {
      final outcome = controller.addItem('Viagem');

      expect(container.read(listPickerProvider).items, ['Viagem']);
      expect(outcome.addedCount, 1);
      expect(outcome.duplicateCount, 0);
      expect(outcome.candidateCount, 1);
      expect(outcome.hasDuplicates, isFalse);
      expect(outcome.isSingleCandidate, isTrue);
    });

    test('rejects a duplicate single item, case- and whitespace-insensitively', () {
      controller.addItem('Viagem');
      final outcome = controller.addItem('  viagem  ');

      expect(container.read(listPickerProvider).items, ['Viagem']);
      expect(outcome.addedCount, 0);
      expect(outcome.duplicateCount, 1);
      expect(outcome.hasDuplicates, isTrue);
      expect(outcome.isSingleCandidate, isTrue);
    });

    test('" Amor " is treated as a duplicate of "Amor"', () {
      controller.addItem('Amor');
      final outcome = controller.addItem(' Amor ');

      expect(container.read(listPickerProvider).items, ['Amor']);
      expect(outcome.duplicateCount, 1);
    });

    test('keeps multi-word items intact and distinguishes different ones', () {
      controller.addItem('Viajar para Roma');
      final outcome = controller.addItem('Viajar para Paris');

      expect(container.read(listPickerProvider).items, [
        'Viajar para Roma',
        'Viajar para Paris',
      ]);
      expect(outcome.addedCount, 1);
      expect(outcome.duplicateCount, 0);
    });

    test('"Nova York" and "nova york" are the same item, not split by space', () {
      controller.addItem('Nova York');
      final outcome = controller.addItem('nova york');

      expect(container.read(listPickerProvider).items, ['Nova York']);
      expect(outcome.addedCount, 0);
      expect(outcome.duplicateCount, 1);
    });

    test('batch add dedupes against existing and within the batch, preserving order', () {
      controller.addItem('Roma');
      final outcome = controller.addItem('Paris, roma, Paris, Londres');

      expect(container.read(listPickerProvider).items, [
        'Roma',
        'Paris',
        'Londres',
      ]);
      expect(outcome.addedCount, 2);
      expect(outcome.duplicateCount, 2);
      expect(outcome.candidateCount, 4);
      expect(outcome.isSingleCandidate, isFalse);
      expect(outcome.hasDuplicates, isTrue);
    });

    test('comma-separated input still splits into multiple items when none duplicate', () {
      final outcome = controller.addItem(
        'Nova York, comprar café, filme de terror',
      );

      expect(container.read(listPickerProvider).items, [
        'Nova York',
        'comprar café',
        'filme de terror',
      ]);
      expect(outcome.addedCount, 3);
      expect(outcome.duplicateCount, 0);
      expect(outcome.hasDuplicates, isFalse);
    });

    test('a blank/whitespace-only input is a no-op with a zeroed outcome', () {
      final outcome = controller.addItem('   ');

      expect(container.read(listPickerProvider).items, isEmpty);
      expect(outcome.addedCount, 0);
      expect(outcome.duplicateCount, 0);
      expect(outcome.candidateCount, 0);
    });

    test('ignores adds while the picker is loading', () async {
      final client = _PendingClient();
      final loadingContainer = ProviderContainer(
        overrides: [
          randomOrgServiceProvider.overrideWithValue(
            RandomOrgService(client: client),
          ),
        ],
      );
      addTearDown(loadingContainer.dispose);
      final loadingController = loadingContainer.read(
        listPickerProvider.notifier,
      );
      loadingController.addItem('Roma');
      loadingController.addItem('Paris');

      final pick = loadingController.pickItem(reduceMotion: true);
      expect(loadingContainer.read(listPickerProvider).isLoading, isTrue);

      final outcome = loadingController.addItem('Viagem');

      expect(loadingContainer.read(listPickerProvider).items, [
        'Roma',
        'Paris',
      ]);
      expect(outcome.addedCount, 0);
      expect(outcome.duplicateCount, 0);
      expect(outcome.candidateCount, 0);

      client.complete('0');
      await pick;
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
