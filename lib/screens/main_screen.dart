import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/services/quick_access_service.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/screens/about_me_screen.dart';
import 'package:theuniversedecides/screens/card_draw_screen.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/screens/dice_roll_screen.dart';
import 'package:theuniversedecides/screens/list_picker_screen.dart';
import 'package:theuniversedecides/screens/tarot_draw_screen.dart';
import 'package:theuniversedecides/widgets/ritual_background.dart';
import 'package:theuniversedecides/widgets/ritual_bottom_nav.dart';
import 'package:theuniversedecides/widgets/snack_bar_custom.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  late final StreamSubscription<QuickAccessAction> _quickAccessSubscription;
  late final StreamSubscription<RandomOrgFallbackEvent>
  _randomOrgFallbackSubscription;

  static const _screens = [
    CoinFlipScreen(),
    DiceRollScreen(),
    CardDrawScreen(),
    ListPickerScreen(),
    TarotDrawScreen(),
    AboutMeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final quickAccessService = ref.read(quickAccessServiceProvider);
    final randomOrgService = ref.read(randomOrgServiceProvider);
    _quickAccessSubscription = quickAccessService.actions.listen(
      _handleQuickAccessAction,
    );
    _randomOrgFallbackSubscription = randomOrgService.fallbackEvents.listen((
      _,
    ) {
      if (!mounted) {
        return;
      }

      SnackBarCustom.buildErrorMessage(
        AppLocalizations.of(context)!.randomOrgFallbackNotice,
        context: context,
      );
    });
    _loadInitialQuickAccessAction(quickAccessService);
  }

  Future<void> _loadInitialQuickAccessAction(
    QuickAccessService quickAccessService,
  ) async {
    final action = await quickAccessService.getInitialAction();
    if (!mounted || action == null) {
      return;
    }

    _handleQuickAccessAction(action);
  }

  void _handleQuickAccessAction(QuickAccessAction action) {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = action.tabIndex;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      switch (action) {
        case QuickAccessAction.coin:
          ref.read(coinQuickAccessTriggerProvider.notifier).trigger();
        case QuickAccessAction.dice:
          ref.read(diceQuickAccessTriggerProvider.notifier).trigger();
      }
    });
  }

  @override
  void dispose() {
    _quickAccessSubscription.cancel();
    _randomOrgFallbackSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final navItems = <RitualNavItem>[
      (id: 'coin', label: l10n.navCoin),
      (id: 'dice', label: l10n.navDice),
      (id: 'cards', label: l10n.navCards),
      (id: 'lists', label: l10n.navLists),
      (id: 'tarot', label: l10n.navTarot),
      (id: 'about', label: l10n.navAboutMe),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RitualBackground(
        child: Stack(
          children: [
            const ShellRuneRings(),
            Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _screens,
                    ),
                  ),
                ),
                RitualBottomNav(
                  items: navItems,
                  selectedIndex: _selectedIndex,
                  onSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
