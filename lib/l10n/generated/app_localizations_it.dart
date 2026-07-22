// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'Moneta';

  @override
  String get navDice => 'Dadi';

  @override
  String get navCards => 'Carte';

  @override
  String get navLists => 'Liste';

  @override
  String get navTarot => 'Tarocchi';

  @override
  String get navAboutMe => 'Info';

  @override
  String get coinEyebrow => 'Sigillo Rituale';

  @override
  String get coinTitle => 'Testa o Croce';

  @override
  String get coinRitualSubtitle =>
      'Un sigillo mistico si illumina per confermare: il risultato viene dal puro caso.';

  @override
  String get coinHeads => 'TESTA';

  @override
  String get coinTails => 'CROCE';

  @override
  String get coinResultCaption => 'L\'universo ha deciso — non il processore.';

  @override
  String get coinHint => 'Tocca il pulsante o trascina la moneta per lanciarla';

  @override
  String get coinHintDrag =>
      'Rilascia per lanciare — trascina più lontano per più forza';

  @override
  String get coinDragHelper =>
      'oppure trascina e lancia la moneta con un colpetto';

  @override
  String get coinButton => 'Lancia una moneta';

  @override
  String get diceEyebrow => 'Rituale dei Dadi';

  @override
  String get diceTitle => 'Dadi RPG';

  @override
  String get diceCountLabel => 'QUANTITÀ';

  @override
  String get diceSidesLabel => 'FACCE';

  @override
  String get diceRollButton => 'Tira i dadi';

  @override
  String diceTotal(int total) {
    return 'Totale: $total';
  }

  @override
  String get cardEyebrow => 'Rituale delle Carte';

  @override
  String get cardTitle => 'Mazzo Completo';

  @override
  String get cardSubtitle => '52 carte. Un destino per tocco.';

  @override
  String get cardDrawButton => 'Pesca una carta';

  @override
  String get listEyebrow => 'Rituale della Scelta';

  @override
  String get listTitle => 'Estrazione da Lista';

  @override
  String get listSubtitle => 'Aggiungi opzioni e lascia decidere il caso.';

  @override
  String get listAddOptionHint => 'Nuova opzione…';

  @override
  String get listChooseButton => 'Lascia scegliere l\'universo';

  @override
  String get listEmptyState => 'Aggiungi almeno due opzioni per iniziare.';

  @override
  String get listChosenByUniverse => 'Scelto dall\'universo';

  @override
  String get listDuplicateItem => 'Questo elemento è già presente nella lista.';

  @override
  String listDuplicateItemsDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sono stati ignorati $count elementi duplicati.',
      one: 'È stato ignorato 1 elemento duplicato.',
    );
    return '$_temp0';
  }

  @override
  String get tarotEyebrow => 'Rituale dei Tarocchi';

  @override
  String get tarotTitle => 'Lettura dei Tarocchi';

  @override
  String get tarotSubtitle => 'Una carta, rivelata dal puro caso.';

  @override
  String get tarotButton => 'Rivela la carta';

  @override
  String get tarotWaiting => 'La carta attende';

  @override
  String get tarotTapReveal => 'Tocca per rivelare';

  @override
  String get tarotMajorArcana => 'Arcani Maggiori';

  @override
  String get tarotMinorArcana => 'Arcani Minori';

  @override
  String tarotDeckPosition(int number) {
    return 'Carta $number di 78';
  }

  @override
  String get aboutEyebrow => 'L\'Oracolo';

  @override
  String get aboutTitle => 'Chi sono';

  @override
  String get aboutBioFallback =>
      'Creatore di The Universe Decides — un\'app di decisioni basata su casualità reale.';

  @override
  String get aboutShortcutsTitle => 'Scorciatoie rapide';

  @override
  String get aboutAddCoinButton => 'Aggiungi moneta';

  @override
  String get aboutAddDiceButton => 'Aggiungi d20';

  @override
  String get aboutDonationButton => 'Offrimi un caffè';

  @override
  String get aboutSoundEffectsTitle => 'Effetti sonori';

  @override
  String get aboutSoundEffectsSubtitle =>
      'Riproduci un suono discreto al termine di una decisione.';

  @override
  String get aboutRandomnessCardTitle => 'Come funziona la casualità reale?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'Perché l\'app evita i numeri pseudocasuali';

  @override
  String get aboutProfileLoadError =>
      'Al momento non è stato possibile caricare il profilo.';

  @override
  String get aboutRetryButton => 'Riprova';

  @override
  String get quickTileCoinAdded =>
      'Scorciatoia della moneta aggiunta al pannello.';

  @override
  String get quickTileCoinAlreadyAdded =>
      'La scorciatoia della moneta è già nel pannello.';

  @override
  String get quickTileCoinCancelled =>
      'Richiesta della scorciatoia della moneta annullata.';

  @override
  String get quickTileCoinUnsupported =>
      'La tua versione di Android non può aggiungere questa scorciatoia dall\'app.';

  @override
  String get quickTileDiceAdded => 'Scorciatoia del d20 aggiunta al pannello.';

  @override
  String get quickTileDiceAlreadyAdded =>
      'La scorciatoia del d20 è già nel pannello.';

  @override
  String get quickTileDiceCancelled =>
      'Richiesta della scorciatoia del d20 annullata.';

  @override
  String get quickTileDiceUnsupported =>
      'La tua versione di Android non può aggiungere questa scorciatoia dall\'app.';

  @override
  String get randomnessSheetEyebrow => 'Cosa c\'è dietro il caso';

  @override
  String get randomnessSheetTitle => 'Caso reale vs. pseudocasuale';

  @override
  String get randomnessCard1Title => 'I computer non creano una vera casualità';

  @override
  String get randomnessCard1Body =>
      'La maggior parte delle app usa PRNG (generatori pseudocasuali): formule matematiche deterministiche che partono da un \"seed\". Dato lo stesso seed, il risultato è sempre lo stesso — sembra casuale, ma è prevedibile al 100% se si conosce l\'algoritmo e il suo stato interno.';

  @override
  String get randomnessCard2Title =>
      'Quando disponibile, questa app usa l\'entropia fisica';

  @override
  String get randomnessCard2Body =>
      'Quando Random.org è disponibile, ogni estrazione consuma rumore atmosferico reale raccolto dall\'elettricità statica radio — un fenomeno fisico caotico, non un calcolo. Non c\'è seed né formula: il risultato non esiste finché non viene misurato.';

  @override
  String get randomnessCard3Title => 'Perché questo conta nella pratica';

  @override
  String get randomnessCard3Body =>
      'Per le decisioni che vuoi siano eque e incontestabili — estrazioni, spareggi, scommesse amichevoli — l\'entropia fisica fornisce un risultato da fonte indipendente. Se Random.org non è disponibile, l\'app usa la casualità pseudocasuale locale e mostra un avviso di fallback.';

  @override
  String get randomnessSheetButton => 'Capito';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org non è disponibile. Uso della casualità locale.';
}
