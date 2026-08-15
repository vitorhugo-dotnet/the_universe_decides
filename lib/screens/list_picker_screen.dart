import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/controllers/list_picker_controller.dart';
import 'package:theuniversedecides/layout/ritual_breakpoint.dart';
import 'package:theuniversedecides/layout/ritual_screen_frame.dart';
import 'package:theuniversedecides/screens/list_picker_wheel_view.dart';
import 'package:theuniversedecides/services/results_history_service.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';
import 'package:theuniversedecides/widgets/ritual_header.dart';
import 'package:theuniversedecides/widgets/snack_bar_custom.dart';

/// Which reveal mode List Draw is currently showing. Both modes share the
/// same item list and state ([listPickerProvider]) — this only toggles the
/// widget used to draw and reveal the winner.
enum _ListPickerMode { classic, wheel }

class ListPickerScreen extends ConsumerStatefulWidget {
  const ListPickerScreen({super.key});

  @override
  ConsumerState<ListPickerScreen> createState() => _ListPickerScreenState();
}

class _ListPickerScreenState extends ConsumerState<ListPickerScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  _ListPickerMode _mode = _ListPickerMode.classic;

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
      // The wheel mode plays its own haptic/sound once its spin animation
      // visually settles (see ListPickerWheelView), since its result arrives
      // from the service well before the animation finishes.
      if (_mode == _ListPickerMode.classic &&
          next.selectedIndex != null &&
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

    // Everything that precedes the ritual object — the field, the toggle,
    // and (classic only) the pick button that triggers the reveal — lives in
    // `header`, exactly as the dice screen's controls precede its arena.
    // Classic's own trailing gap (20 after the button; 16 after the toggle
    // for wheel, which has no button of its own) is folded into `header` too,
    // so `stageSpacing` stays 0 for both modes and never doubles it up.
    final header = Column(
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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
        _ModeToggle(
          mode: _mode,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        const SizedBox(height: 16),
        if (_mode == _ListPickerMode.classic) ...[
          RitualButton(
            label: l10n.listChooseButton,
            onPressed: canPick
                ? () => controller.pickItem(reduceMotion: reduceMotion)
                : null,
            maxWidth: double.infinity,
          ),
          const SizedBox(height: 20),
        ],
      ],
    );

    // Whether the loading indicator is standing in for the reveal right now
    // (classic mode only; the wheel owns its own spin animation and never
    // hides the item list beneath it).
    final showsLoadingStage =
        _mode == _ListPickerMode.classic &&
        state.isLoading &&
        !state.isScanning;
    final showsSelectedBanner =
        _mode == _ListPickerMode.classic &&
        !showsLoadingStage &&
        state.items.isNotEmpty &&
        state.selectedIndex != null;
    // Only `expanded` has a reveal pane to fill; compact and medium share the
    // stacked layout the original screen always used, where this in-between
    // state (items added, nothing drawn yet) rendered nothing at all.
    final isExpandedBand = ritualBandOf(context).isExpanded;

    return RitualScreenFrame(
      header: header,
      // Both modes already fold their own leading gap into `header` above,
      // so the frame must not add a second one in front of the stage.
      stageSpacing: 0,
      // Wheel's gap before its item list only exists when there is a list to
      // show; classic's gap before its item list only exists when the banner
      // that precedes them is showing. Neither is the frame's default 24.
      stageSpacingAfter: _mode == _ListPickerMode.wheel
          ? (state.items.isNotEmpty ? 22 : 0)
          : (showsSelectedBanner ? 16 : 0),
      // Unlike dice's arena, every classic-mode stage widget here already
      // reports the same width the frame would center it in (the spinner's
      // own `Center` fills the available width before deciding where to put
      // the indicator; the empty-state and banner cards are explicitly
      // `width: double.infinity`) — confirmed against the pre-refactor
      // screen, whose spinner sat at the identical x-offset. So the default
      // `stageAlignment` (center) already reproduces the original exactly
      // and needs no override.
      stage: _buildStage(
        l10n,
        state,
        showsLoadingStage,
        showsSelectedBanner,
        isExpandedBand,
      ),
      body: _mode == _ListPickerMode.classic
          ? _buildClassicItems(state, controller, showsLoadingStage)
          : _buildWheelItems(state, controller),
    );
  }

  /// The ritual object for the current mode.
  ///
  /// Wheel mode has a real visual object (the wheel, which already carries
  /// its own spin button and hint/result banner). Classic mode has none in
  /// the original screen — the loading spinner, the "add two options" empty
  /// state, and the drawn-result banner are the only candidates. The
  /// remaining case — items already added but nothing picked yet — has no
  /// original widget to reuse either, but review established it is not a
  /// transient gap to leave blank: it is a normal steady state a user sits
  /// in while building their list, and the wheel's own hint container
  /// (`list_picker_wheel_view.dart`) already sets the app's convention for
  /// it — show a "ready to draw" hint rather than nothing. That hint only
  /// belongs in `expanded`, which is the only band with a reveal pane to
  /// fill; compact and medium keep rendering nothing here, exactly as the
  /// original always did (it had no concept of a reveal pane at all).
  Widget _buildStage(
    AppLocalizations l10n,
    ListPickerState state,
    bool showsLoadingStage,
    bool showsSelectedBanner,
    bool isExpandedBand,
  ) {
    if (_mode == _ListPickerMode.wheel) {
      return const ListPickerWheelView();
    }

    final selectedIndex = state.selectedIndex;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: showsLoadingStage
          ? const Padding(
              key: ValueKey('loading'),
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            )
          : state.items.isEmpty
          ? _EmptyState(key: const ValueKey('empty'), text: l10n.listEmptyState)
          : showsSelectedBanner
          ? _SelectedBanner(
              key: ValueKey('banner-$selectedIndex'),
              label: l10n.listChosenByUniverse,
              value: state.items[selectedIndex!],
            )
          : isExpandedBand
          ? _EmptyState(key: const ValueKey('ready'), text: l10n.listReadyHint)
          : const SizedBox.shrink(key: ValueKey('none')),
    );
  }

  /// Classic mode's item rows, moved out of the switcher above them so the
  /// reveal banner can live in the stage pane on its own in `expanded`. The
  /// original hid the whole item list — not just the banner — while the
  /// spinner stood in for it, so this stays hidden under the same guard.
  ///
  /// The original crossfaded the banner *and* the item rows as one unit on
  /// every add, remove and pick — keyed on
  /// `'${items.length}-${selectedIndex}'`. Splitting the banner into `stage`
  /// makes a single shared switcher impossible (the two now live in
  /// different frame slots), but wrapping this Column in its own
  /// `AnimatedSwitcher` with the identical key formula restores a crossfade
  /// for list changes — independent of the banner's fade rather than
  /// combined with it, but present instead of silently lost.
  Widget _buildClassicItems(
    ListPickerState state,
    ListPickerController controller,
    bool showsLoadingStage,
  ) {
    if (showsLoadingStage) {
      return const SizedBox.shrink();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Column(
        key: ValueKey('${state.items.length}-${state.selectedIndex ?? -1}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < state.items.length; i++) ...[
            if (i > 0) const SizedBox(height: 9),
            _ItemRow(
              index: i,
              label: state.items[i],
              selected: state.selectedIndex == i,
              scanning: state.isScanning && state.scanIndex == i,
              onRemove: state.isLoading ? null : () => controller.removeItem(i),
            ),
          ],
        ],
      ),
    );
  }

  /// Wheel mode's item rows: full, untruncated labels always stay available
  /// here — the wheel itself may need to shorten long labels to fit a slice.
  Widget _buildWheelItems(
    ListPickerState state,
    ListPickerController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < state.items.length; i++) ...[
          if (i > 0) const SizedBox(height: 9),
          _ItemRow(
            index: i,
            label: state.items[i],
            selected: false,
            scanning: false,
            onRemove: state.isLoading ? null : () => controller.removeItem(i),
          ),
        ],
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _ListPickerMode mode;
  final ValueChanged<_ListPickerMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0x0AFFFFFF),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeToggleButton(
              label: l10n.listModeClassic,
              selected: mode == _ListPickerMode.classic,
              onTap: () => onChanged(_ListPickerMode.classic),
            ),
          ),
          Expanded(
            child: _ModeToggleButton(
              label: l10n.listModeWheel,
              selected: mode == _ListPickerMode.wheel,
              onTap: () => onChanged(_ListPickerMode.wheel),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: selected
                ? const LinearGradient(
                    colors: [AppColors.gold1, AppColors.gold2],
                  )
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.goldText : AppColors.textSoft,
            ),
          ),
        ),
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
  const _EmptyState({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  const _SelectedBanner({super.key, required this.label, required this.value});

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
