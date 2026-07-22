import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/utils/list_item_dedup.dart';

const _unset = Object();

final listPickerProvider =
    NotifierProvider<ListPickerController, ListPickerState>(
      ListPickerController.new,
    );

class ListPickerState {
  const ListPickerState({
    this.items = const [],
    this.isLoading = false,
    this.isScanning = false,
    this.scanIndex,
    this.selectedIndex,
  });

  final List<String> items;
  final bool isLoading;
  final bool isScanning;
  final int? scanIndex;
  final int? selectedIndex;

  ListPickerState copyWith({
    List<String>? items,
    bool? isLoading,
    bool? isScanning,
    Object? scanIndex = _unset,
    Object? selectedIndex = _unset,
  }) {
    return ListPickerState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isScanning: isScanning ?? this.isScanning,
      scanIndex: identical(scanIndex, _unset)
          ? this.scanIndex
          : scanIndex as int?,
      selectedIndex: identical(selectedIndex, _unset)
          ? this.selectedIndex
          : selectedIndex as int?,
    );
  }
}

/// Outcome of a call to [ListPickerController.addItem], used by the UI to
/// decide whether (and how) to surface duplicate-item feedback.
class AddItemOutcome {
  const AddItemOutcome({
    required this.addedCount,
    required this.duplicateCount,
    required this.candidateCount,
  });

  /// How many items were actually inserted.
  final int addedCount;

  /// How many candidates were dropped because they duplicated an existing
  /// item or an earlier candidate in the same batch.
  final int duplicateCount;

  /// How many non-blank candidates were parsed from the raw input (before
  /// deduplication). One candidate means the user was adding a single item
  /// (no comma-separated batch).
  final int candidateCount;

  bool get hasDuplicates => duplicateCount > 0;

  bool get isSingleCandidate => candidateCount == 1;
}

class ListPickerController extends Notifier<ListPickerState> {
  /// Mirrors the reveal cadence from the Claude Design prototype: quick
  /// ticks that quadratically slow down before landing on the result.
  static const int _extraScanSteps = 8;
  static const int _minStepDelayMs = 45;
  static const int _maxExtraDelayMs = 260;

  late final RandomOrgService _randomOrgService;
  final math.Random _scanRandom = math.Random();

  @override
  ListPickerState build() {
    _randomOrgService = ref.read(randomOrgServiceProvider);
    return const ListPickerState();
  }

  /// Parses [value] into one or more comma-separated items (the input is
  /// never split on spaces, so multi-word items like "Nova York" stay
  /// intact), then appends only the ones that aren't already present —
  /// comparing trimmed and case-insensitively while preserving the original
  /// casing/spacing for display and the original order of survivors.
  static const _noOpOutcome = AddItemOutcome(
    addedCount: 0,
    duplicateCount: 0,
    candidateCount: 0,
  );

  AddItemOutcome addItem(String value) {
    if (state.isLoading) {
      return _noOpOutcome;
    }

    final candidates = value
        .split(',')
        .map(trimListItem)
        .where((item) => item.isNotEmpty)
        .toList();
    if (candidates.isEmpty) {
      return _noOpOutcome;
    }

    final deduped = dedupeListItems(
      candidates: candidates,
      existingItems: state.items,
    );

    if (deduped.items.isNotEmpty) {
      state = state.copyWith(
        items: [...state.items, ...deduped.items],
        selectedIndex: null,
      );
    }

    return AddItemOutcome(
      addedCount: deduped.items.length,
      duplicateCount: deduped.duplicateCount,
      candidateCount: candidates.length,
    );
  }

  void removeItem(int index) {
    if (state.isLoading) {
      return;
    }
    final updatedItems = [...state.items]..removeAt(index);
    int? selectedIndex = state.selectedIndex;

    if (selectedIndex == index) {
      selectedIndex = null;
    } else if (selectedIndex != null && selectedIndex > index) {
      selectedIndex = selectedIndex - 1;
    }

    state = state.copyWith(items: updatedItems, selectedIndex: selectedIndex);
  }

  /// Fetches the real result, then reveals it through a roulette-style scan
  /// that cycles the highlighted item faster than it settles — matching the
  /// Claude Design prototype's reveal timing. Pass [reduceMotion] to skip
  /// straight to the result for users who disabled animations.
  Future<void> pickItem({bool reduceMotion = false}) async {
    if (state.items.isEmpty || state.isLoading || state.isScanning) {
      return;
    }

    final itemCount = state.items.length;
    state = state.copyWith(
      isLoading: true,
      isScanning: !reduceMotion,
      scanIndex: null,
      selectedIndex: null,
    );

    final fetchFuture = _randomOrgService.fetchIntegers(
      count: 1,
      min: 0,
      max: itemCount - 1,
    );

    if (!reduceMotion) {
      final totalSteps = itemCount * 2 + _extraScanSteps;
      for (var step = 1; step <= totalSteps; step++) {
        final progress = step / totalSteps;
        final delayMs =
            _minStepDelayMs +
            (progress * progress * _maxExtraDelayMs).round();
        await Future.delayed(Duration(milliseconds: delayMs));
        state = state.copyWith(scanIndex: _scanRandom.nextInt(itemCount));
      }
    }

    final values = await fetchFuture;
    state = state.copyWith(
      isLoading: false,
      isScanning: false,
      scanIndex: null,
      selectedIndex: values.isEmpty ? 0 : values.first,
    );
  }
}
