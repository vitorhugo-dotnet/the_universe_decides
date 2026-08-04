import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theuniversedecides/services/results_history_service.dart';

void main() {
  test('starts empty with nothing persisted', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(resultsHistoryProvider), isEmpty);
  });

  test('loads persisted entries on start, newest first as stored', () async {
    final stored = jsonEncode([
      {
        'id': 'a',
        'modality': 'coin',
        'resultLabel': 'HEADS',
        'timestamp': DateTime(2026, 1, 1).toIso8601String(),
      },
    ]);
    SharedPreferences.setMockInitialValues({
      'results_history_entries_v1': stored,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Reading the provider triggers build(), which kicks off the async
    // load; give it a beat to settle before asserting.
    container.read(resultsHistoryProvider);
    await Future<void>.delayed(Duration.zero);

    final entries = container.read(resultsHistoryProvider);
    expect(entries, hasLength(1));
    expect(entries.first.modality, HistoryModality.coin);
    expect(entries.first.resultLabel, 'HEADS');
  });

  test('ignores corrupted persisted data instead of throwing', () async {
    SharedPreferences.setMockInitialValues({
      'results_history_entries_v1': 'not json at all {{{',
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(resultsHistoryProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(resultsHistoryProvider), isEmpty);
  });

  test('addEntry inserts new entries at the front (newest first)', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(resultsHistoryProvider.notifier);

    await notifier.addEntry(
      modality: HistoryModality.coin,
      resultLabel: 'HEADS',
    );
    await notifier.addEntry(
      modality: HistoryModality.dice,
      resultLabel: 'd20: 14',
    );

    final entries = container.read(resultsHistoryProvider);
    expect(entries, hasLength(2));
    expect(entries.first.modality, HistoryModality.dice);
    expect(entries.last.modality, HistoryModality.coin);
  });

  test(
    'addEntry caps the history at 50 entries, dropping the oldest',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(resultsHistoryProvider.notifier);

      for (var i = 0; i < 55; i++) {
        await notifier.addEntry(
          modality: HistoryModality.coin,
          resultLabel: 'result-$i',
        );
      }

      final entries = container.read(resultsHistoryProvider);
      expect(entries, hasLength(50));
      // Newest (result-54) is first; oldest surviving entry is result-5, since
      // results 0..4 were pushed out once the cap was exceeded.
      expect(entries.first.resultLabel, 'result-54');
      expect(entries.last.resultLabel, 'result-5');
    },
  );

  test('addEntry persists so the history survives a fresh container', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(resultsHistoryProvider.notifier);

    await notifier.addEntry(modality: HistoryModality.cards, resultLabel: 'K♠');

    final reopened = ProviderContainer();
    addTearDown(reopened.dispose);
    reopened.read(resultsHistoryProvider);
    await Future<void>.delayed(Duration.zero);

    final entries = reopened.read(resultsHistoryProvider);
    expect(entries, hasLength(1));
    expect(entries.single.resultLabel, 'K♠');
    expect(entries.single.modality, HistoryModality.cards);
  });

  test('clearHistory empties in-memory state and persisted storage', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(resultsHistoryProvider.notifier);

    await notifier.addEntry(
      modality: HistoryModality.list,
      resultLabel: 'Pizza',
    );
    expect(container.read(resultsHistoryProvider), isNotEmpty);

    await notifier.clearHistory();

    expect(container.read(resultsHistoryProvider), isEmpty);
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString('results_history_entries_v1');
    expect(stored, isNotNull);
    expect(jsonDecode(stored!), isEmpty);
  });
}
