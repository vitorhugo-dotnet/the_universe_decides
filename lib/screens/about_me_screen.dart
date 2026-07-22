import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/results_history_screen.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/how_randomness_sheet.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';
import 'package:theuniversedecides/widgets/ritual_header.dart';

class AboutMeScreen extends ConsumerStatefulWidget {
  const AboutMeScreen({super.key});

  static const _githubUsername = 'vitorhugo-dotnet';

  @override
  ConsumerState<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends ConsumerState<AboutMeScreen> {
  static final _donationUri = Uri.parse(
    'https://www.buymeacoffee.com/vitorhugo1207',
  );
  static final _privacyPolicyUri = Uri.parse(
    'https://hugodotnet.dev/the-universe-decides/privacy-policy',
  );

  Future<void> _openDonationPage() async {
    await launchUrl(_donationUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openPrivacyPolicy() async {
    await launchUrl(_privacyPolicyUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _requestTile(QuickAccessAction action) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final result = await ref
        .read(quickAccessServiceProvider)
        .requestTile(action);
    if (!mounted) {
      return;
    }

    final message = switch ((action, result)) {
      (QuickAccessAction.coin, QuickAccessTileRequestResult.added) =>
        l10n.quickTileCoinAdded,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.alreadyAdded) =>
        l10n.quickTileCoinAlreadyAdded,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.cancelled) =>
        l10n.quickTileCoinCancelled,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.unsupported) =>
        l10n.quickTileCoinUnsupported,
      (QuickAccessAction.dice, QuickAccessTileRequestResult.added) =>
        l10n.quickTileDiceAdded,
      (QuickAccessAction.dice, QuickAccessTileRequestResult.alreadyAdded) =>
        l10n.quickTileDiceAlreadyAdded,
      (QuickAccessAction.dice, QuickAccessTileRequestResult.cancelled) =>
        l10n.quickTileDiceCancelled,
      (QuickAccessAction.dice, QuickAccessTileRequestResult.unsupported) =>
        l10n.quickTileDiceUnsupported,
    };

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final privacyPolicyLabel =
        Localizations.localeOf(context).languageCode == 'pt'
        ? 'Política de Privacidade'
        : 'Privacy Policy';
    final profileAsync = ref.watch(
      githubProfileProvider(AboutMeScreen._githubUsername),
    );
    final soundEffectsEnabled = ref.watch(soundEffectsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RitualHeader(eyebrow: l10n.aboutEyebrow, title: l10n.aboutTitle),
          const SizedBox(height: 20),
          profileAsync.when(
            data: (profile) => _ProfileBlock(profile: profile, l10n: l10n),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _ErrorBlock(
              message: l10n.aboutProfileLoadError,
              detail: '$error',
              retryLabel: l10n.aboutRetryButton,
              onRetry: () => ref.invalidate(
                githubProfileProvider(AboutMeScreen._githubUsername),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _DonationButton(
            label: l10n.aboutDonationButton,
            onPressed: _openDonationPage,
          ),
          const SizedBox(height: 24),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.aboutSoundEffectsTitle),
            subtitle: Text(l10n.aboutSoundEffectsSubtitle),
            value: soundEffectsEnabled,
            onChanged: ref.read(soundEffectsProvider.notifier).setEnabled,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.aboutShortcutsTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ShortcutButton(
                  icon: Icons.monetization_on,
                  label: l10n.aboutAddCoinButton,
                  onTap: () => _requestTile(QuickAccessAction.coin),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShortcutButton(
                  icon: Icons.casino,
                  label: l10n.aboutAddDiceButton,
                  onTap: () => _requestTile(QuickAccessAction.dice),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _RandomnessCard(
            icon: Icons.history,
            title: l10n.aboutHistoryCardTitle,
            subtitle: l10n.aboutHistoryCardSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const ResultsHistoryScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _RandomnessCard(
            icon: Icons.auto_awesome,
            title: l10n.aboutRandomnessCardTitle,
            subtitle: l10n.aboutRandomnessCardSubtitle,
            onTap: () => showHowRandomnessSheet(context),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _openPrivacyPolicy,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textCaption,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: Text(privacyPolicyLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationButton extends StatelessWidget {
  const _DonationButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF5F7FFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('☕', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.favorite, color: Color(0xFFFFDD00), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.profile, required this.l10n});

  final GitHubProfile profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final bio = profile.bio ?? l10n.aboutBioFallback;
    final link = (profile.profileUrl ?? 'https://github.com/${profile.login}')
        .replaceFirst('https://', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(avatarUrl: profile.avatarUrl, login: profile.login),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name ?? 'Vitor Hugo',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${profile.login}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB7A6FF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          bio,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.55,
            color: AppColors.textSoft,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0x0AFFFFFF),
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: Text(
            link,
            style: const TextStyle(fontSize: 13, color: AppColors.textCaption),
          ),
        ),
      ],
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({
    required this.message,
    required this.detail,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String detail;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(detail, style: const TextStyle(color: AppColors.textSoft)),
        const SizedBox(height: 16),
        RitualButton(
          label: retryLabel,
          onPressed: onRetry,
          maxWidth: 220,
          height: 46,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl, required this.login});

  final String avatarUrl;
  final String login;

  @override
  Widget build(BuildContext context) {
    final initials = login.isNotEmpty
        ? login.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.listResultGradientStart,
            AppColors.listResultGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x24FFFFFF), width: 2),
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _InitialsFallback(initials: initials),
              )
            : _InitialsFallback(initials: initials),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.gold2.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.gold2.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.gold1),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RandomnessCard extends StatelessWidget {
  const _RandomnessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0x1A7A4FFF),
            border: Border.all(color: const Color(0x597A4FFF)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.runePurple.withValues(alpha: 0.7),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textDim),
            ],
          ),
        ),
      ),
    );
  }
}
