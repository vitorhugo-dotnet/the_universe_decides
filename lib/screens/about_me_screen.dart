import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/github_profile_service.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/widgets/mystic_screen_scaffold.dart';

class AboutMeScreen extends ConsumerStatefulWidget {
  const AboutMeScreen({super.key});

  static const _githubUsername = 'vitorhugo-dotnet';

  @override
  ConsumerState<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends ConsumerState<AboutMeScreen> {
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(
      githubProfileProvider(AboutMeScreen._githubUsername),
    );

    return MysticScreenScaffold(
      title: l10n.navAboutMe,
      subtitle: l10n.aboutSubtitle,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: profileAsync.when(
                data: (profile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Avatar(avatarUrl: profile.avatarUrl),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name ?? 'Vitor Hugo',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '@${profile.login}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (profile.bio case final bio?) ...[
                      const SizedBox(height: 20),
                      Text(
                        bio,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.panelBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        profile.profileUrl ??
                            'https://github.com/${profile.login}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutProfileLoadError,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('$error', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(
                          githubProfileProvider(AboutMeScreen._githubUsername),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.aboutRetryButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aboutQuickAccessTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.aboutQuickAccessDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _requestTile(QuickAccessAction.coin),
                        icon: const Icon(Icons.monetization_on),
                        label: Text(l10n.aboutAddCoinButton),
                      ),
                      FilledButton.icon(
                        onPressed: () => _requestTile(QuickAccessAction.dice),
                        icon: const Icon(Icons.casino),
                        label: Text(l10n.aboutAddDiceButton),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl.isNotEmpty;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.whiteBorder, width: 2),
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: AppColors.panelBackground,
                  child: Icon(Icons.person, size: 44),
                ),
              )
            : const ColoredBox(
                color: AppColors.panelBackground,
                child: Icon(Icons.person, size: 44),
              ),
      ),
    );
  }
}
