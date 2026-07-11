import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'The Universe Decides'**
  String get appTitle;

  /// No description provided for @navCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get navCoin;

  /// No description provided for @navDice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get navDice;

  /// No description provided for @navCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get navCards;

  /// No description provided for @navLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get navLists;

  /// No description provided for @navTarot.
  ///
  /// In en, this message translates to:
  /// **'Tarot'**
  String get navTarot;

  /// No description provided for @navAboutMe.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get navAboutMe;

  /// No description provided for @coinEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Ritual Seal'**
  String get coinEyebrow;

  /// No description provided for @coinTitle.
  ///
  /// In en, this message translates to:
  /// **'Heads or Tails'**
  String get coinTitle;

  /// No description provided for @coinRitualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A mystic seal lights up to confirm: the result comes from pure chance.'**
  String get coinRitualSubtitle;

  /// No description provided for @coinHeads.
  ///
  /// In en, this message translates to:
  /// **'HEADS'**
  String get coinHeads;

  /// No description provided for @coinTails.
  ///
  /// In en, this message translates to:
  /// **'TAILS'**
  String get coinTails;

  /// No description provided for @coinResultCaption.
  ///
  /// In en, this message translates to:
  /// **'The universe decided — not the processor.'**
  String get coinResultCaption;

  /// No description provided for @coinHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button or drag the coin to flip'**
  String get coinHint;

  /// No description provided for @coinHintDrag.
  ///
  /// In en, this message translates to:
  /// **'Release to flip — pull further for more force'**
  String get coinHintDrag;

  /// No description provided for @coinDragHelper.
  ///
  /// In en, this message translates to:
  /// **'or drag and flick the coin to throw it'**
  String get coinDragHelper;

  /// No description provided for @coinButton.
  ///
  /// In en, this message translates to:
  /// **'Flip a coin'**
  String get coinButton;

  /// No description provided for @diceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Roll your RPG dice with multiple sides and let destiny add up the final result.'**
  String get diceSubtitle;

  /// No description provided for @diceCount.
  ///
  /// In en, this message translates to:
  /// **'Number of dice'**
  String get diceCount;

  /// No description provided for @diceSides.
  ///
  /// In en, this message translates to:
  /// **'Dice sides'**
  String get diceSides;

  /// No description provided for @diceRollButton.
  ///
  /// In en, this message translates to:
  /// **'Roll dice'**
  String get diceRollButton;

  /// No description provided for @diceEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Choose your setup and roll to see each value and the final total.'**
  String get diceEmptyState;

  /// No description provided for @diceResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get diceResults;

  /// No description provided for @diceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String diceTotal(int total);

  /// No description provided for @cardDrawSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Draw a true-random playing card and let the universe reveal a modern tarot-free sign from a full 52-card deck.'**
  String get cardDrawSubtitle;

  /// No description provided for @cardDrawPrompt.
  ///
  /// In en, this message translates to:
  /// **'Draw a card from the cosmic deck'**
  String get cardDrawPrompt;

  /// No description provided for @cardDrawTapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap below to reveal your next card.'**
  String get cardDrawTapPrompt;

  /// No description provided for @cardDrawResolved.
  ///
  /// In en, this message translates to:
  /// **'The universe has revealed your card.'**
  String get cardDrawResolved;

  /// No description provided for @cardDrawButton.
  ///
  /// In en, this message translates to:
  /// **'Draw a card'**
  String get cardDrawButton;

  /// No description provided for @listSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write down possibilities, invite the universe, and highlight a single destination for your next decision.'**
  String get listSubtitle;

  /// No description provided for @listAddOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get listAddOptionLabel;

  /// No description provided for @listAddOptionHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Travel, sleep, order pizza...'**
  String get listAddOptionHint;

  /// No description provided for @listAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get listAddButton;

  /// No description provided for @listChooseButton.
  ///
  /// In en, this message translates to:
  /// **'Choose for me'**
  String get listChooseButton;

  /// No description provided for @listEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Add items to the list and let the universe decide for you.'**
  String get listEmptyState;

  /// No description provided for @listChosenByUniverse.
  ///
  /// In en, this message translates to:
  /// **'Chosen by the universe'**
  String get listChosenByUniverse;

  /// No description provided for @tarotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Draw a single Tarot card from the full 78-card deck and let true randomness reveal the archetype guiding this moment.'**
  String get tarotSubtitle;

  /// No description provided for @tarotPrompt.
  ///
  /// In en, this message translates to:
  /// **'The deck is waiting'**
  String get tarotPrompt;

  /// No description provided for @tarotTapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Draw a card to reveal the universe\'s symbol.'**
  String get tarotTapPrompt;

  /// No description provided for @tarotButton.
  ///
  /// In en, this message translates to:
  /// **'Draw a card'**
  String get tarotButton;

  /// No description provided for @tarotMajorArcana.
  ///
  /// In en, this message translates to:
  /// **'Major Arcana'**
  String get tarotMajorArcana;

  /// No description provided for @tarotMinorArcana.
  ///
  /// In en, this message translates to:
  /// **'Minor Arcana'**
  String get tarotMinorArcana;

  /// No description provided for @tarotDeckPosition.
  ///
  /// In en, this message translates to:
  /// **'Card {number} of 78'**
  String tarotDeckPosition(int number);

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A small corner with the creator profile, loading the avatar straight from the GitHub API.'**
  String get aboutSubtitle;

  /// No description provided for @aboutProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the profile right now.'**
  String get aboutProfileLoadError;

  /// No description provided for @aboutRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get aboutRetryButton;

  /// No description provided for @aboutQuickAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access in the panel'**
  String get aboutQuickAccessTitle;

  /// No description provided for @aboutQuickAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Add coin and d20 shortcuts to the Android quick settings panel to open the app and run the action immediately.'**
  String get aboutQuickAccessDescription;

  /// No description provided for @aboutAddCoinButton.
  ///
  /// In en, this message translates to:
  /// **'Add coin'**
  String get aboutAddCoinButton;

  /// No description provided for @aboutAddDiceButton.
  ///
  /// In en, this message translates to:
  /// **'Add d20'**
  String get aboutAddDiceButton;

  /// No description provided for @quickTileCoinAdded.
  ///
  /// In en, this message translates to:
  /// **'Coin shortcut added to the panel.'**
  String get quickTileCoinAdded;

  /// No description provided for @quickTileCoinAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'The coin shortcut is already in the panel.'**
  String get quickTileCoinAlreadyAdded;

  /// No description provided for @quickTileCoinCancelled.
  ///
  /// In en, this message translates to:
  /// **'Coin shortcut request cancelled.'**
  String get quickTileCoinCancelled;

  /// No description provided for @quickTileCoinUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Your Android version cannot add this shortcut from the app.'**
  String get quickTileCoinUnsupported;

  /// No description provided for @quickTileDiceAdded.
  ///
  /// In en, this message translates to:
  /// **'d20 shortcut added to the panel.'**
  String get quickTileDiceAdded;

  /// No description provided for @quickTileDiceAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'The d20 shortcut is already in the panel.'**
  String get quickTileDiceAlreadyAdded;

  /// No description provided for @quickTileDiceCancelled.
  ///
  /// In en, this message translates to:
  /// **'d20 shortcut request cancelled.'**
  String get quickTileDiceCancelled;

  /// No description provided for @quickTileDiceUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Your Android version cannot add this shortcut from the app.'**
  String get quickTileDiceUnsupported;

  /// No description provided for @randomOrgFallbackNotice.
  ///
  /// In en, this message translates to:
  /// **'Random.org is unavailable. Using local randomness.'**
  String get randomOrgFallbackNotice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
