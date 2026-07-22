import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:theuniversedecides/controllers/list_picker_controller.dart';
import 'package:theuniversedecides/services/random_org_service.dart';

void main() {
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

class _PendingClient extends http.BaseClient {
  final _response = Completer<http.Response>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
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
