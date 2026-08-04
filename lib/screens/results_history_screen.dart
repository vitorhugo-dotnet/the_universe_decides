import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/results_history_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';

/// Full-screen list of recent decision outcomes, pushed from the About
/// screen. A dedicated route (rather than a bottom-nav tab or a sheet) gives
/// room for a scrollable list plus a "clear all" confirmation flow without
/// crowding the ritual bottom nav.
class ResultsHistoryScreen extends ConsumerWidget {
  const ResultsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final entries = ref.watch(resultsHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        foregroundColor: Colors.white,
        title: Text(l10n.historyTitle),
        actions: [
          IconButton(
            key: const Key('history-clear-button'),
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.historyClearButton,
            onPressed: entries.isEmpty
                ? null
                : () => _confirmClear(context, ref, l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: entries.isEmpty
            ? _EmptyHistory(text: l10n.historyEmptyState)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _HistoryTile(entry: entries[index], l10n: l10n),
              ),
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.panelBackground,
        title: Text(
          l10n.historyClearDialogTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.historyClearDialogMessage,
          style: const TextStyle(color: AppColors.textSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.historyClearDialogCancel),
          ),
          TextButton(
            key: const Key('history-clear-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.historyClearDialogConfirm,
              style: const TextStyle(color: Color(0xFFFFC9C9)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(resultsHistoryProvider.notifier).clearHistory();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.historyClearedSnackbar)));
  }
}

extension on HistoryModality {
  IconData get icon => switch (this) {
    HistoryModality.coin => Icons.monetization_on,
    HistoryModality.dice => Icons.casino,
    HistoryModality.cards => Icons.style,
    HistoryModality.list => Icons.list_alt,
    HistoryModality.tarot => Icons.auto_awesome,
  };

  /// Reuses the same nav labels shown in the bottom bar so the modality
  /// name never needs a separate translation.
  String label(AppLocalizations l10n) => switch (this) {
    HistoryModality.coin => l10n.navCoin,
    HistoryModality.dice => l10n.navDice,
    HistoryModality.cards => l10n.navCards,
    HistoryModality.list => l10n.navLists,
    HistoryModality.tarot => l10n.navTarot,
  };
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textDim),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.l10n});

  final HistoryEntry entry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final timestamp = DateFormat.yMMMd(
      locale,
    ).add_Hm().format(entry.timestamp.toLocal());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0x0AFFFFFF),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold2.withValues(alpha: 0.16),
            ),
            child: Icon(entry.modality.icon, size: 18, color: AppColors.gold1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.modality.label(l10n),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textCaption,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.resultLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timestamp,
            style: const TextStyle(fontSize: 11, color: AppColors.textDim),
          ),
        ],
      ),
    );
  }
}
