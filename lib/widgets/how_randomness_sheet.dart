import 'package:flutter/material.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/theme/app_colors.dart';

/// Bottom sheet explaining real (physical) randomness vs. pseudo-random,
/// matching the prototype's "Acaso real vs. pseudoaleatório" sheet.
Future<void> showHowRandomnessSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _HowRandomnessSheet(),
  );
}

class _HowRandomnessSheet extends StatelessWidget {
  const _HowRandomnessSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF15101F), Color(0xFF0D0A14)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, 14, 22, bottomInset + 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.randomnessSheetEyebrow,
              style: const TextStyle(
                fontFamily: 'serif',
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: AppColors.textDim,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.randomnessSheetTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              accent: false,
              title: l10n.randomnessCard1Title,
              body: l10n.randomnessCard1Body,
            ),
            const SizedBox(height: 14),
            _InfoCard(
              accent: true,
              title: l10n.randomnessCard2Title,
              body: l10n.randomnessCard2Body,
            ),
            const SizedBox(height: 14),
            _InfoCard(
              accent: false,
              title: l10n.randomnessCard3Title,
              body: l10n.randomnessCard3Body,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.gold1, AppColors.gold2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pop(),
                    child: Center(
                      child: Text(
                        l10n.randomnessSheetButton,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.accent,
    required this.title,
    required this.body,
  });

  final bool accent;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accent ? const Color(0x1A7A4FFF) : const Color(0x08FFFFFF),
        border: Border.all(
          color: accent ? const Color(0x4D7A4FFF) : const Color(0x14FFFFFF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent ? const Color(0xFFD9CFFF) : AppColors.gold1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: Colors.white.withValues(alpha: accent ? 0.72 : 0.68),
            ),
          ),
        ],
      ),
    );
  }
}
