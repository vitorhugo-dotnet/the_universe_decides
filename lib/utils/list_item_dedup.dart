/// Pure helpers for validating and de-duplicating custom list items.
///
/// See GitHub issue #23. Comparison rules:
/// - Leading and trailing whitespace is trimmed before comparing or storing.
/// - Comparison is case-insensitive.
/// - Internal whitespace and the original casing are preserved for display.
/// - Content is never split on spaces; only the caller may split on commas
///   to accept multiple items at once.
library;

/// Trims [raw] for storage/display, preserving internal spacing and casing.
String trimListItem(String raw) => raw.trim();

/// The case-insensitive, whitespace-trimmed key used to compare two list
/// items. Internal spacing is preserved so multi-word items (e.g. "Nova
/// York") are never confused with a different item that merely shares a
/// prefix (e.g. "Nova").
String listItemComparisonKey(String raw) => trimListItem(raw).toLowerCase();

/// Result of running [dedupeListItems].
class DedupedListItems {
  const DedupedListItems({required this.items, required this.duplicateCount});

  /// The candidates to add: trimmed, in their original order, with only the
  /// first occurrence of each duplicate kept.
  final List<String> items;

  /// How many non-blank candidates were dropped because they matched an
  /// existing item or an earlier candidate within the same batch.
  final int duplicateCount;
}

/// Filters [candidates] against [existingItems] and against each other,
/// removing duplicates (trimmed, case-insensitive) while keeping the first
/// occurrence of each and preserving the original order of the survivors.
///
/// Blank candidates (empty after trimming) are dropped silently and are not
/// counted towards [DedupedListItems.duplicateCount].
DedupedListItems dedupeListItems({
  required Iterable<String> candidates,
  required Iterable<String> existingItems,
}) {
  final seen = existingItems.map(listItemComparisonKey).toSet();
  final items = <String>[];
  var duplicateCount = 0;

  for (final candidate in candidates) {
    final trimmed = trimListItem(candidate);
    if (trimmed.isEmpty) {
      continue;
    }

    final key = listItemComparisonKey(trimmed);
    if (!seen.add(key)) {
      duplicateCount++;
      continue;
    }

    items.add(trimmed);
  }

  return DedupedListItems(items: items, duplicateCount: duplicateCount);
}
