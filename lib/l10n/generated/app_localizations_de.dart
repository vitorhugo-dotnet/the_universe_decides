// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'Münze';

  @override
  String get navDice => 'Würfel';

  @override
  String get navCards => 'Karten';

  @override
  String get navLists => 'Listen';

  @override
  String get navTarot => 'Tarot';

  @override
  String get navAboutMe => 'Über';

  @override
  String get coinEyebrow => 'Ritualsiegel';

  @override
  String get coinTitle => 'Kopf oder Zahl';

  @override
  String get coinRitualSubtitle =>
      'Ein mystisches Siegel leuchtet auf, um zu bestätigen: Das Ergebnis kommt aus reinem Zufall.';

  @override
  String get coinHeads => 'KOPF';

  @override
  String get coinTails => 'ZAHL';

  @override
  String get coinResultCaption =>
      'Das Universum hat entschieden — nicht der Prozessor.';

  @override
  String get coinHint =>
      'Tippe auf die Schaltfläche oder ziehe die Münze, um sie zu werfen';

  @override
  String get coinHintDrag =>
      'Loslassen zum Werfen — weiter ziehen für mehr Kraft';

  @override
  String get coinDragHelper =>
      'oder ziehe und schnippe die Münze, um sie zu werfen';

  @override
  String get coinButton => 'Münze werfen';

  @override
  String get diceEyebrow => 'Würfelritual';

  @override
  String get diceTitle => 'RPG-Würfel';

  @override
  String get diceCountLabel => 'ANZAHL';

  @override
  String get diceSidesLabel => 'SEITEN';

  @override
  String get diceRollButton => 'Würfeln';

  @override
  String diceTotal(int total) {
    return 'Gesamt: $total';
  }

  @override
  String get cardEyebrow => 'Kartenritual';

  @override
  String get cardTitle => 'Volles Deck';

  @override
  String get cardSubtitle => '52 Karten. Ein Schicksal pro Tippen.';

  @override
  String get cardDrawButton => 'Karte ziehen';

  @override
  String get listEyebrow => 'Auswahlritual';

  @override
  String get listTitle => 'Listenlosung';

  @override
  String get listSubtitle =>
      'Füge Optionen hinzu und lass den Zufall entscheiden.';

  @override
  String get listAddOptionHint => 'Neue Option…';

  @override
  String get listChooseButton => 'Das Universum entscheiden lassen';

  @override
  String get listEmptyState =>
      'Füge mindestens zwei Optionen hinzu, um zu beginnen.';

  @override
  String get listChosenByUniverse => 'Vom Universum gewählt';

  @override
  String get listDuplicateItem => 'Dieser Eintrag ist bereits in der Liste.';

  @override
  String listDuplicateItemsDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doppelte Einträge wurden übersprungen.',
      one: '1 doppelter Eintrag wurde übersprungen.',
    );
    return '$_temp0';
  }

  @override
  String get tarotEyebrow => 'Tarot-Ritual';

  @override
  String get tarotTitle => 'Tarot-Lesung';

  @override
  String get tarotSubtitle => 'Eine Karte, enthüllt durch reinen Zufall.';

  @override
  String get tarotButton => 'Karte aufdecken';

  @override
  String get tarotWaiting => 'Die Karte wartet';

  @override
  String get tarotTapReveal => 'Zum Aufdecken tippen';

  @override
  String get tarotMajorArcana => 'Große Arkana';

  @override
  String get tarotMinorArcana => 'Kleine Arkana';

  @override
  String tarotDeckPosition(int number) {
    return 'Karte $number von 78';
  }

  @override
  String get aboutEyebrow => 'Das Orakel';

  @override
  String get aboutTitle => 'Über mich';

  @override
  String get aboutBioFallback =>
      'Schöpfer von The Universe Decides — einer Entscheidungs-App, die auf echtem Zufall basiert.';

  @override
  String get aboutShortcutsTitle => 'Schnellzugriffe';

  @override
  String get aboutAddCoinButton => 'Münze hinzufügen';

  @override
  String get aboutAddDiceButton => 'd20 hinzufügen';

  @override
  String get aboutDonationButton => 'Spendiere mir einen Kaffee';

  @override
  String get aboutSoundEffectsTitle => 'Soundeffekte';

  @override
  String get aboutSoundEffectsSubtitle =>
      'Einen dezenten Ton abspielen, wenn eine Entscheidung abgeschlossen ist.';

  @override
  String get aboutRandomnessCardTitle => 'Wie funktioniert echter Zufall?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'Warum die App pseudozufällige Zahlen vermeidet';

  @override
  String get aboutProfileLoadError =>
      'Das Profil konnte gerade nicht geladen werden.';

  @override
  String get aboutRetryButton => 'Erneut versuchen';

  @override
  String get quickTileCoinAdded => 'Münz-Verknüpfung zum Panel hinzugefügt.';

  @override
  String get quickTileCoinAlreadyAdded =>
      'Die Münz-Verknüpfung ist bereits im Panel.';

  @override
  String get quickTileCoinCancelled =>
      'Anfrage für die Münz-Verknüpfung abgebrochen.';

  @override
  String get quickTileCoinUnsupported =>
      'Deine Android-Version kann diese Verknüpfung nicht aus der App hinzufügen.';

  @override
  String get quickTileDiceAdded => 'd20-Verknüpfung zum Panel hinzugefügt.';

  @override
  String get quickTileDiceAlreadyAdded =>
      'Die d20-Verknüpfung ist bereits im Panel.';

  @override
  String get quickTileDiceCancelled =>
      'Anfrage für die d20-Verknüpfung abgebrochen.';

  @override
  String get quickTileDiceUnsupported =>
      'Deine Android-Version kann diese Verknüpfung nicht aus der App hinzufügen.';

  @override
  String get randomnessSheetEyebrow => 'Was hinter dem Zufall steckt';

  @override
  String get randomnessSheetTitle => 'Echter Zufall vs. Pseudozufall';

  @override
  String get randomnessCard1Title => 'Computer erzeugen keinen echten Zufall';

  @override
  String get randomnessCard1Body =>
      'Die meisten Apps verwenden PRNGs (Pseudozufallsgeneratoren): deterministische mathematische Formeln, die von einem \"Seed\" ausgehen. Bei gleichem Seed ist das Ergebnis immer dasselbe — es wirkt zufällig, ist aber zu 100 % vorhersagbar, wenn man den Algorithmus und seinen internen Zustand kennt.';

  @override
  String get randomnessCard2Title =>
      'Wenn verfügbar, nutzt diese App physikalische Entropie';

  @override
  String get randomnessCard2Body =>
      'Wenn Random.org verfügbar ist, verbraucht ein Wurf echtes, aus Radiorauschen gesammeltes atmosphärisches Rauschen — ein chaotisches physikalisches Phänomen, keine Berechnung. Es gibt keinen Seed und keine Formel: Das Ergebnis existiert erst in dem Moment, in dem es gemessen wird.';

  @override
  String get randomnessCard3Title => 'Warum das in der Praxis wichtig ist';

  @override
  String get randomnessCard3Body =>
      'Für Entscheidungen, die fair und unbestreitbar sein sollen — Auslosungen, Stichentscheide, freundschaftliche Wetten — liefert physikalische Entropie ein unabhängig ermitteltes Ergebnis. Ist Random.org nicht verfügbar, nutzt die App stattdessen lokale Pseudozufälligkeit und zeigt einen Fallback-Hinweis.';

  @override
  String get randomnessSheetButton => 'Verstanden';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org ist nicht verfügbar. Lokaler Zufall wird verwendet.';
}
