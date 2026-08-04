import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/utils/list_item_dedup.dart';

void main() {
  group('trimListItem', () {
    test('trims outer whitespace but preserves internal spaces and casing', () {
      expect(trimListItem('  Nova York  '), 'Nova York');
      expect(trimListItem('comprar café'), 'comprar café');
    });
  });

  group('listItemComparisonKey', () {
    test('is case-insensitive', () {
      expect(listItemComparisonKey('Viagem'), listItemComparisonKey('viagem'));
      expect(listItemComparisonKey('VIAGEM'), listItemComparisonKey('viagem'));
    });

    test('ignores only leading/trailing whitespace', () {
      expect(listItemComparisonKey('Amor'), listItemComparisonKey(' Amor '));
    });

    test('treats multi-word items as a single unit, unaffected by internal spaces', () {
      expect(
        listItemComparisonKey('Nova York'),
        listItemComparisonKey('nova york'),
      );
      expect(listItemComparisonKey('Nova York'), isNot('nova'));
    });
  });

  group('dedupeListItems', () {
    test('keeps distinct multi-word items intact', () {
      final result = dedupeListItems(
        candidates: ['Viajar para Roma', 'Viajar para Paris'],
        existingItems: const [],
      );

      expect(result.items, ['Viajar para Roma', 'Viajar para Paris']);
      expect(result.duplicateCount, 0);
    });

    test('drops a candidate that duplicates an existing item, case-insensitively', () {
      final result = dedupeListItems(
        candidates: ['viagem'],
        existingItems: ['Viagem'],
      );

      expect(result.items, isEmpty);
      expect(result.duplicateCount, 1);
    });

    test('drops a candidate that duplicates an existing item, ignoring outer whitespace', () {
      final result = dedupeListItems(
        candidates: [' Amor '],
        existingItems: ['Amor'],
      );

      expect(result.items, isEmpty);
      expect(result.duplicateCount, 1);
    });

    test('treats "Nova York" and "nova york" as the same item', () {
      final result = dedupeListItems(
        candidates: ['nova york'],
        existingItems: ['Nova York'],
      );

      expect(result.items, isEmpty);
      expect(result.duplicateCount, 1);
    });

    test(
      'dedupes within a single batch, keeping the first occurrence and the original order',
      () {
        final result = dedupeListItems(
          candidates: ['Viagem', 'Roma', 'viagem', 'Paris', ' ROMA '],
          existingItems: const [],
        );

        expect(result.items, ['Viagem', 'Roma', 'Paris']);
        expect(result.duplicateCount, 2);
      },
    );

    test('drops blank candidates without counting them as duplicates', () {
      final result = dedupeListItems(
        candidates: ['Viagem', '   ', ''],
        existingItems: const [],
      );

      expect(result.items, ['Viagem']);
      expect(result.duplicateCount, 0);
    });

    test('preserves original casing and internal spacing for display', () {
      final result = dedupeListItems(
        candidates: ['  Nova   York  '],
        existingItems: const [],
      );

      expect(result.items, ['Nova   York']);
    });
  });
}
