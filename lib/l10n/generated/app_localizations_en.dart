// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'Coin';

  @override
  String get navDice => 'Dice';

  @override
  String get navCards => 'Cards';

  @override
  String get navLists => 'Lists';

  @override
  String get navTarot => 'Tarot';

  @override
  String get navAboutMe => 'About me';

  @override
  String get coinEyebrow => 'Ritual Seal';

  @override
  String get coinTitle => 'Heads or Tails';

  @override
  String get coinRitualSubtitle =>
      'A mystic seal lights up to confirm: the result comes from pure chance.';

  @override
  String get coinHeads => 'HEADS';

  @override
  String get coinTails => 'TAILS';

  @override
  String get coinResultCaption => 'The universe decided — not the processor.';

  @override
  String get coinHint => 'Tap the button or drag the coin to flip';

  @override
  String get coinHintDrag => 'Release to flip — pull further for more force';

  @override
  String get coinDragHelper => 'or drag and flick the coin to throw it';

  @override
  String get coinButton => 'Flip a coin';

  @override
  String get diceSubtitle =>
      'Roll your RPG dice with multiple sides and let destiny add up the final result.';

  @override
  String get diceCount => 'Number of dice';

  @override
  String get diceSides => 'Dice sides';

  @override
  String get diceRollButton => 'Roll dice';

  @override
  String get diceEmptyState =>
      'Choose your setup and roll to see each value and the final total.';

  @override
  String get diceResults => 'Results';

  @override
  String diceTotal(int total) {
    return 'Total: $total';
  }

  @override
  String get cardDrawSubtitle =>
      'Draw a true-random playing card and let the universe reveal a modern tarot-free sign from a full 52-card deck.';

  @override
  String get cardDrawPrompt => 'Draw a card from the cosmic deck';

  @override
  String get cardDrawTapPrompt => 'Tap below to reveal your next card.';

  @override
  String get cardDrawResolved => 'The universe has revealed your card.';

  @override
  String get cardDrawButton => 'Draw a card';

  @override
  String get listSubtitle =>
      'Write down possibilities, invite the universe, and highlight a single destination for your next decision.';

  @override
  String get listAddOptionLabel => 'Add option';

  @override
  String get listAddOptionHint => 'E.g. Travel, sleep, order pizza...';

  @override
  String get listAddButton => 'Add';

  @override
  String get listChooseButton => 'Choose for me';

  @override
  String get listEmptyState =>
      'Add items to the list and let the universe decide for you.';

  @override
  String get listChosenByUniverse => 'Chosen by the universe';

  @override
  String get tarotSubtitle =>
      'Draw a single Tarot card from the full 78-card deck and let true randomness reveal the archetype guiding this moment.';

  @override
  String get tarotPrompt => 'The deck is waiting';

  @override
  String get tarotTapPrompt => 'Draw a card to reveal the universe\'s symbol.';

  @override
  String get tarotButton => 'Draw a card';

  @override
  String get tarotMajorArcana => 'Major Arcana';

  @override
  String get tarotMinorArcana => 'Minor Arcana';

  @override
  String tarotDeckPosition(int number) {
    return 'Card $number of 78';
  }

  @override
  String get aboutSubtitle =>
      'A small corner with the creator profile, loading the avatar straight from the GitHub API.';

  @override
  String get aboutProfileLoadError => 'Could not load the profile right now.';

  @override
  String get aboutRetryButton => 'Try again';

  @override
  String get aboutQuickAccessTitle => 'Quick access in the panel';

  @override
  String get aboutQuickAccessDescription =>
      'Add coin and d20 shortcuts to the Android quick settings panel to open the app and run the action immediately.';

  @override
  String get aboutAddCoinButton => 'Add coin';

  @override
  String get aboutAddDiceButton => 'Add d20';

  @override
  String get quickTileCoinAdded => 'Coin shortcut added to the panel.';

  @override
  String get quickTileCoinAlreadyAdded =>
      'The coin shortcut is already in the panel.';

  @override
  String get quickTileCoinCancelled => 'Coin shortcut request cancelled.';

  @override
  String get quickTileCoinUnsupported =>
      'Your Android version cannot add this shortcut from the app.';

  @override
  String get quickTileDiceAdded => 'd20 shortcut added to the panel.';

  @override
  String get quickTileDiceAlreadyAdded =>
      'The d20 shortcut is already in the panel.';

  @override
  String get quickTileDiceCancelled => 'd20 shortcut request cancelled.';

  @override
  String get quickTileDiceUnsupported =>
      'Your Android version cannot add this shortcut from the app.';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org is unavailable. Using local randomness.';
}
