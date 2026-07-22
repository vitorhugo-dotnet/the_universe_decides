import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The decision mode that produced a [HistoryEntry].
///
/// Tarot draws are kept distinct from playing-card draws: the app already
/// treats them as separate rituals with their own screen and identity, so
/// merging them under one "cards" bucket would make the history harder to
/// scan even though the source issue allowed either interpretation.
enum HistoryModality { coin, dice, cards, list, tarot }

/// A single recorded outcome. [resultLabel] is a plain, already-formatted
/// display string captured by the screen at the moment the decision
/// completed (screens already build these strings for their own UI, so we
/// reuse them instead of duplicating formatting/localization logic here).
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.modality,
    required this.resultLabel,
    required this.timestamp,
  });

  final String id;
  final HistoryModality modality;
  final String resultLabel;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'id': id,
    'modality': modality.name,
    'resultLabel': resultLabel,
    'timestamp': timestamp.toIso8601String(),
  };

  static HistoryEntry? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final modalityName = json['modality'];
    final resultLabel = json['resultLabel'];
    final timestampRaw = json['timestamp'];
    if (id is! String ||
        modalityName is! String ||
        resultLabel is! String ||
        timestampRaw is! String) {
      return null;
    }

    HistoryModality? modality;
    for (final candidate in HistoryModality.values) {
      if (candidate.name == modalityName) {
        modality = candidate;
        break;
      }
    }
    final timestamp = DateTime.tryParse(timestampRaw);
    if (modality == null || timestamp == null) {
      return null;
    }

    return HistoryEntry(
      id: id,
      modality: modality,
      resultLabel: resultLabel,
      timestamp: timestamp,
    );
  }
}

final resultsHistoryProvider =
    NotifierProvider<ResultsHistoryNotifier, List<HistoryEntry>>(
      ResultsHistoryNotifier.new,
    );

/// Local, on-device history of recent decision outcomes. Follows the same
/// Notifier-over-SharedPreferences shape as [EntropyDriftHighScoreNotifier]
/// and [SoundEffectsNotifier]: no account, no backend, nothing leaves the
/// device.
class ResultsHistoryNotifier extends Notifier<List<HistoryEntry>> {
  static const _key = 'results_history_entries_v1';

  /// Keeps unbounded use of the app from growing local storage forever.
  static const maxEntries = 50;

  var _sequence = 0;

  @override
  List<HistoryEntry> build() {
    unawaited(_load());
    return const [];
  }

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_key);
      if (raw == null || raw.isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }

      final entries = <HistoryEntry>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final entry = HistoryEntry.tryFromJson(item);
          if (entry != null) {
            entries.add(entry);
          }
        }
      }
      state = entries;
    } catch (_) {
      // Corrupted or unavailable storage must never crash the app; fall
      // back to an empty (but usable) history.
    }
  }

  /// Records a completed decision. Safe to call without awaiting: a failure
  /// to persist is swallowed so it can never block the draw itself.
  Future<void> addEntry({
    required HistoryModality modality,
    required String resultLabel,
  }) async {
    final entry = HistoryEntry(
      id: _nextId(),
      modality: modality,
      resultLabel: resultLabel,
      timestamp: DateTime.now(),
    );
    final updated = [entry, ...state];
    state = updated.length > maxEntries
        ? updated.sublist(0, maxEntries)
        : updated;
    await _persist();
  }

  /// Clears the entire history. Callers are expected to confirm with the
  /// user before invoking this — the screen handles that.
  Future<void> clearHistory() async {
    state = const [];
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.map((entry) => entry.toJson()).toList());
      await preferences.setString(_key, encoded);
    } catch (_) {
      // A decision must never fail just because history couldn't be saved.
    }
  }

  String _nextId() {
    _sequence++;
    return '${DateTime.now().microsecondsSinceEpoch}-$_sequence';
  }
}
