// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'Pièce';

  @override
  String get navDice => 'Dés';

  @override
  String get navCards => 'Cartes';

  @override
  String get navLists => 'Listes';

  @override
  String get navTarot => 'Tarot';

  @override
  String get navAboutMe => 'À propos';

  @override
  String get coinEyebrow => 'Sceau Rituel';

  @override
  String get coinTitle => 'Pile ou Face';

  @override
  String get coinRitualSubtitle =>
      'Un sceau mystique s\'allume pour confirmer : le résultat vient du pur hasard.';

  @override
  String get coinHeads => 'FACE';

  @override
  String get coinTails => 'PILE';

  @override
  String get coinResultCaption => 'L\'univers a décidé — pas le processeur.';

  @override
  String get coinHint =>
      'Appuie sur le bouton ou fais glisser la pièce pour la lancer';

  @override
  String get coinHintDrag =>
      'Relâche pour lancer — tire plus loin pour plus de force';

  @override
  String get coinDragHelper =>
      'ou fais glisser et lance la pièce d\'une pichenette';

  @override
  String get coinButton => 'Lancer une pièce';

  @override
  String get diceEyebrow => 'Rituel des Dés';

  @override
  String get diceTitle => 'Dés de JDR';

  @override
  String get diceCountLabel => 'QUANTITÉ';

  @override
  String get diceSidesLabel => 'FACES';

  @override
  String get diceRollButton => 'Lancer les dés';

  @override
  String diceTotal(int total) {
    return 'Total : $total';
  }

  @override
  String get cardEyebrow => 'Rituel des Cartes';

  @override
  String get cardTitle => 'Jeu Complet';

  @override
  String get cardSubtitle => '52 cartes. Un destin par tapotement.';

  @override
  String get cardDrawButton => 'Tirer une carte';

  @override
  String get listEyebrow => 'Rituel du Choix';

  @override
  String get listTitle => 'Tirage de Liste';

  @override
  String get listSubtitle => 'Ajoute des options et laisse le hasard décider.';

  @override
  String get listAddOptionHint => 'Nouvelle option…';

  @override
  String get listChooseButton => 'Laisser l\'univers choisir';

  @override
  String get listEmptyState => 'Ajoute au moins deux options pour commencer.';

  @override
  String get listChosenByUniverse => 'Choisi par l\'univers';

  @override
  String get tarotEyebrow => 'Rituel du Tarot';

  @override
  String get tarotTitle => 'Tirage de Tarot';

  @override
  String get tarotSubtitle => 'Une carte, révélée par le pur hasard.';

  @override
  String get tarotButton => 'Révéler la carte';

  @override
  String get tarotWaiting => 'La carte attend';

  @override
  String get tarotTapReveal => 'Touche pour révéler';

  @override
  String get tarotMajorArcana => 'Arcanes Majeurs';

  @override
  String get tarotMinorArcana => 'Arcanes Mineurs';

  @override
  String tarotDeckPosition(int number) {
    return 'Carte $number sur 78';
  }

  @override
  String get aboutEyebrow => 'L\'Oracle';

  @override
  String get aboutTitle => 'À propos de moi';

  @override
  String get aboutBioFallback =>
      'Créateur de The Universe Decides — une appli de décision propulsée par le hasard réel.';

  @override
  String get aboutShortcutsTitle => 'Raccourcis rapides';

  @override
  String get aboutAddCoinButton => 'Ajouter la pièce';

  @override
  String get aboutAddDiceButton => 'Ajouter le d20';

  @override
  String get aboutDonationButton => 'Offrez-moi un café';

  @override
  String get aboutSoundEffectsTitle => 'Effets sonores';

  @override
  String get aboutSoundEffectsSubtitle =>
      'Jouer un son discret lorsqu\'une décision est prise.';

  @override
  String get aboutRandomnessCardTitle => 'Comment fonctionne le vrai hasard ?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'Pourquoi l\'appli évite les nombres pseudo-aléatoires';

  @override
  String get aboutProfileLoadError =>
      'Impossible de charger le profil pour le moment.';

  @override
  String get aboutRetryButton => 'Réessayer';

  @override
  String get quickTileCoinAdded => 'Raccourci de la pièce ajouté au panneau.';

  @override
  String get quickTileCoinAlreadyAdded =>
      'Le raccourci de la pièce est déjà dans le panneau.';

  @override
  String get quickTileCoinCancelled =>
      'Demande de raccourci de la pièce annulée.';

  @override
  String get quickTileCoinUnsupported =>
      'Ta version d\'Android ne peut pas ajouter ce raccourci depuis l\'appli.';

  @override
  String get quickTileDiceAdded => 'Raccourci du d20 ajouté au panneau.';

  @override
  String get quickTileDiceAlreadyAdded =>
      'Le raccourci du d20 est déjà dans le panneau.';

  @override
  String get quickTileDiceCancelled => 'Demande de raccourci du d20 annulée.';

  @override
  String get quickTileDiceUnsupported =>
      'Ta version d\'Android ne peut pas ajouter ce raccourci depuis l\'appli.';

  @override
  String get randomnessSheetEyebrow => 'Ce qui se cache derrière le hasard';

  @override
  String get randomnessSheetTitle => 'Vrai hasard vs pseudo-aléatoire';

  @override
  String get randomnessCard1Title =>
      'Les ordinateurs ne créent pas de vrai hasard';

  @override
  String get randomnessCard1Body =>
      'La plupart des applis utilisent des PRNG (générateurs pseudo-aléatoires) : des formules mathématiques déterministes qui partent d\'une « graine » (seed). Avec la même graine, le résultat est toujours identique — cela paraît aléatoire, mais c\'est prévisible à 100 % si l\'on connaît l\'algorithme et son état interne.';

  @override
  String get randomnessCard2Title =>
      'Quand elle est disponible, cette appli utilise l\'entropie physique';

  @override
  String get randomnessCard2Body =>
      'Quand Random.org est disponible, un tirage consomme du vrai bruit atmosphérique collecté à partir de parasites radio — un phénomène physique chaotique, pas un calcul. Il n\'y a ni graine ni formule : le résultat n\'existe qu\'à l\'instant où il est mesuré.';

  @override
  String get randomnessCard3Title => 'Pourquoi cela compte en pratique';

  @override
  String get randomnessCard3Body =>
      'Pour les décisions que tu veux justes et incontestables — tirages au sort, départages, paris amicaux — l\'entropie physique fournit un résultat issu d\'une source indépendante. Si Random.org est indisponible, l\'appli utilise le hasard pseudo-aléatoire local et affiche un avis de repli.';

  @override
  String get randomnessSheetButton => 'Compris';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org est indisponible. Utilisation du hasard local.';
}
