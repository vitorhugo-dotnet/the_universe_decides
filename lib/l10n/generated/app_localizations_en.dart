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
  String get navAboutMe => 'About';

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
  String get diceEyebrow => 'Dice Ritual';

  @override
  String get diceTitle => 'RPG Dice';

  @override
  String get diceCountLabel => 'QUANTITY';

  @override
  String get diceSidesLabel => 'SIDES';

  @override
  String get diceRollButton => 'Roll dice';

  @override
  String diceTotal(int total) {
    return 'Total: $total';
  }

  @override
  String get cardEyebrow => 'Card Ritual';

  @override
  String get cardTitle => 'Full Deck';

  @override
  String get cardSubtitle => '52 cards. One fate per tap.';

  @override
  String get cardDrawButton => 'Draw a card';

  @override
  String get listEyebrow => 'Choice Ritual';

  @override
  String get listTitle => 'List Draw';

  @override
  String get listSubtitle => 'Add options and let chance decide.';

  @override
  String get listAddOptionHint => 'New option…';

  @override
  String get listChooseButton => 'Let the universe choose';

  @override
  String get listEmptyState => 'Add at least two options to begin.';

  @override
  String get listChosenByUniverse => 'Chosen by the universe';

  @override
  String get tarotEyebrow => 'Tarot Ritual';

  @override
  String get tarotTitle => 'Tarot Reading';

  @override
  String get tarotSubtitle => 'One card, revealed by pure chance.';

  @override
  String get tarotButton => 'Reveal card';

  @override
  String get tarotWaiting => 'The card awaits';

  @override
  String get tarotTapReveal => 'Tap to reveal';

  @override
  String get tarotMajorArcana => 'Major Arcana';

  @override
  String get tarotMinorArcana => 'Minor Arcana';

  @override
  String tarotDeckPosition(int number) {
    return 'Card $number of 78';
  }

  @override
  String get aboutEyebrow => 'The Oracle';

  @override
  String get aboutTitle => 'About me';

  @override
  String get aboutBioFallback =>
      'Creator of The Universe Decides — a decision app powered by real randomness.';

  @override
  String get aboutShortcutsTitle => 'Quick shortcuts';

  @override
  String get aboutAddCoinButton => 'Add coin';

  @override
  String get aboutAddDiceButton => 'Add d20';

  @override
  String get aboutRandomnessCardTitle => 'How does real randomness work?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'Why the app avoids pseudo-random numbers';

  @override
  String get aboutProfileLoadError => 'Could not load the profile right now.';

  @override
  String get aboutRetryButton => 'Try again';

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
  String get randomnessSheetEyebrow => 'What lies behind chance';

  @override
  String get randomnessSheetTitle => 'Real chance vs. pseudo-random';

  @override
  String get randomnessCard1Title => 'Computers don\'t create true randomness';

  @override
  String get randomnessCard1Body =>
      'Most apps use PRNGs (pseudo-random generators): deterministic math formulas that start from a \"seed\". Given the same seed, the result is always the same — it looks random, but it is 100% predictable if you know the algorithm and its internal state.';

  @override
  String get randomnessCard2Title =>
      'When available, this app uses physical entropy';

  @override
  String get randomnessCard2Body =>
      'When Random.org is available, a draw consumes real atmospheric noise collected from radio static — a chaotic physical phenomenon, not a calculation. There is no seed or formula: the result does not exist until the instant it is measured.';

  @override
  String get randomnessCard3Title => 'Why it matters in practice';

  @override
  String get randomnessCard3Body =>
      'For decisions you want to be fair and indisputable — draws, tie-breaks, friendly bets — physical entropy provides an independently sourced result. If Random.org is unavailable, the app uses local pseudo-randomness instead and shows a fallback notice.';

  @override
  String get randomnessSheetButton => 'Got it';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org is unavailable. Using local randomness.';
}
