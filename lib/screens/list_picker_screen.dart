import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/list_picker_controller.dart';
import 'package:theuniversedecides/services/results_history_service.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';
import 'package:theuniversedecides/widgets/ritual_header.dart';
import 'package:theuniversedecides/widgets/snack_bar_custom.dart';

class ListPickerScreen extends ConsumerStatefulWidget {
  const ListPickerScreen({super.key});

  @override
  ConsumerState<ListPickerScreen> createState() => _ListPickerScreenState();
}

class _ListPickerScreenState extends ConsumerState<ListPickerScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    if (ref.read(listPickerProvider).isLoading) {
      return;
    }
    final outcome = ref
        .read(listPickerProvider.notifier)
        .addItem(_controller.text);
    _controller.clear();
    _focusNode.requestFocus();

    if (outcome.hasDuplicates) {
      final l10n = AppLocalizations.of(context)!;
      final message = outcome.isSingleCandidate
          ? l10n.listDuplicateItem
          : l10n.listDuplicateItemsDiscarded(outcome.duplicateCount);
      SnackBarCustom.buildErrorMessage(message, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(listPickerProvider);
    final controller = ref.read(listPickerProvider.notifier);
    final canPick = state.items.length >= 2 && !state.isLoading;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    ref.listen<ListPickerState>(listPickerProvider, (previous, next) {
      if (next.selectedIndex != null &&
          next.selectedIndex != previous?.selectedIndex) {
        HapticFeedback.mediumImpact();
        ref.read(soundEffectsProvider.notifier).playDecision();
        unawaited(
          ref
              .read(resultsHistoryProvider.notifier)
              .addEntry(
                modality: HistoryModality.list,
                resultLabel: next.items[next.selectedIndex!],
              ),
        );
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RitualHeader(
            eyebrow: l10n.listEyebrow,
            title: l10n.listTitle,
            subtitle: l10n.listSubtitle,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addItem(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l10n.listAddOptionHint,
                      hintStyle: const TextStyle(color: AppColors.textDim),
                      filled: true,
                      fillColor: const Color(0x0DFFFFFF),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0x24FFFFFF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0x24FFFFFF)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _AddButton(onTap: state.isLoading ? null : _addItem),
            ],
          ),
          const SizedBox(height: 16),
          RitualButton(
            label: l10n.listChooseButton,
            onPressed: canPick
                ? () => controller.pickItem(reduceMotion: reduceMotion)
                : null,
            maxWidth: double.infinity,
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: state.isLoading && !state.isScanning
                ? const Padding(
                    key: ValueKey('loading'),
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : state.items.isEmpty
                ? _EmptyState(text: l10n.listEmptyState)
                : Column(
                    key: ValueKey(
                      '${state.items.length}-${state.selectedIndex ?? -1}',
                    ),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.selectedIndex != null) ...[
                        _SelectedBanner(
                          label: l10n.listChosenByUniverse,
                          value: state.items[state.selectedIndex!],
                        ),
                        const SizedBox(height: 16),
                      ],
                      for (var i = 0; i < state.items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 9),
                        _ItemRow(
                          index: i,
                          label: state.items[i],
                          selected: state.selectedIndex == i,
                          scanning: state.isScanning && state.scanIndex == i,
                          onRemove: state.isLoading
                              ? null
                              : () => controller.removeItem(i),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [AppColors.gold1, AppColors.gold2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text(
              '+',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.goldText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x0AFFFFFF),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13.5, color: AppColors.textDim),
      ),
    );
  }
}

class _SelectedBanner extends StatelessWidget {
  const _SelectedBanner({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppColors.listResultGradientStart,
            AppColors.listResultGradientEnd,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.whiteMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.index,
    required this.label,
    required this.selected,
    required this.scanning,
    required this.onRemove,
  });

  final int index;
  final String label;
  final bool selected;
  final bool scanning;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: selected
            ? const LinearGradient(
                colors: [
                  AppColors.listResultGradientStart,
                  AppColors.listResultGradientEnd,
                ],
              )
            : null,
        color: selected
            ? null
            : (scanning ? AppColors.runeAmberFaint : const Color(0x0AFFFFFF)),
        border: Border.all(
          color: selected
              ? AppColors.runePurple
              : (scanning
                    ? AppColors.gold2.withValues(alpha: 0.5)
                    : const Color(0x14FFFFFF)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? const Color(0x38FFFFFF)
                  : const Color(0x14FFFFFF),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(13),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(
                Icons.close,
                size: 18,
                color: onRemove == null
                    ? AppColors.textDim.withValues(alpha: 0.4)
                    : AppColors.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
