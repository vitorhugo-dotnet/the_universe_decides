// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'Moeda';

  @override
  String get navDice => 'Dados';

  @override
  String get navCards => 'Cartas';

  @override
  String get navLists => 'Lista';

  @override
  String get navTarot => 'Tarot';

  @override
  String get navAboutMe => 'Sobre';

  @override
  String get coinEyebrow => 'Selo Ritual';

  @override
  String get coinTitle => 'Cara ou Coroa';

  @override
  String get coinRitualSubtitle =>
      'Um selo místico se acende para confirmar: o resultado vem do acaso puro.';

  @override
  String get coinHeads => 'CARA';

  @override
  String get coinTails => 'COROA';

  @override
  String get coinResultCaption => 'O universo decidiu — não o processador.';

  @override
  String get coinHint => 'Toque no botão ou arraste a moeda para lançar';

  @override
  String get coinHintDrag => 'Solte para lançar — puxe mais para mais força';

  @override
  String get coinDragHelper => 'ou arraste e solte a moeda para lançar';

  @override
  String get coinButton => 'Lançar a moeda';

  @override
  String get diceEyebrow => 'Ritual dos Dados';

  @override
  String get diceTitle => 'Dados RPG';

  @override
  String get diceCountLabel => 'QUANTIDADE';

  @override
  String get diceSidesLabel => 'LADOS';

  @override
  String get diceRollButton => 'Rolar os dados';

  @override
  String diceTotal(int total) {
    return 'Total: $total';
  }

  @override
  String get cardEyebrow => 'Ritual das Cartas';

  @override
  String get cardTitle => 'Baralho Completo';

  @override
  String get cardSubtitle => '52 cartas. Um destino por toque.';

  @override
  String get cardDrawButton => 'Sacar carta';

  @override
  String get listEyebrow => 'Ritual da Escolha';

  @override
  String get listTitle => 'Sorteio de Lista';

  @override
  String get listSubtitle => 'Adicione opções e deixe o acaso decidir.';

  @override
  String get listAddOptionHint => 'Nova opção…';

  @override
  String get listChooseButton => 'Deixar o universo escolher';

  @override
  String get listEmptyState => 'Adicione ao menos duas opções para começar.';

  @override
  String get listChosenByUniverse => 'Escolhido pelo universo';

  @override
  String get listDuplicateItem => 'Este item já existe na lista.';

  @override
  String listDuplicateItemsDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens duplicados foram ignorados.',
      one: '1 item duplicado foi ignorado.',
    );
    return '$_temp0';
  }

  @override
  String get tarotEyebrow => 'Ritual do Tarot';

  @override
  String get tarotTitle => 'Leitura do Tarot';

  @override
  String get tarotSubtitle => 'Uma carta, revelada pelo acaso puro.';

  @override
  String get tarotButton => 'Revelar carta';

  @override
  String get tarotWaiting => 'A carta aguarda';

  @override
  String get tarotTapReveal => 'Toque em revelar';

  @override
  String get tarotMajorArcana => 'Arcano Maior';

  @override
  String get tarotMinorArcana => 'Arcano Menor';

  @override
  String tarotDeckPosition(int number) {
    return 'Carta $number de 78';
  }

  @override
  String get aboutEyebrow => 'O Oráculo';

  @override
  String get aboutTitle => 'Sobre mim';

  @override
  String get aboutBioFallback =>
      'Criador de The Universe Decides — um app de decisões movido a aleatoriedade real.';

  @override
  String get aboutShortcutsTitle => 'Atalhos rápidos';

  @override
  String get aboutAddCoinButton => 'Adicionar moeda';

  @override
  String get aboutAddDiceButton => 'Adicionar d20';

  @override
  String get aboutDonationButton => 'Compre-me um café';

  @override
  String get aboutSoundEffectsTitle => 'Efeitos sonoros';

  @override
  String get aboutSoundEffectsSubtitle =>
      'Reproduzir um som sutil quando uma decisão terminar.';

  @override
  String get aboutRandomnessCardTitle => 'Como funciona o acaso real?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'Por que o app não usa números pseudoaleatórios';

  @override
  String get aboutHistoryCardTitle => 'Resultados recentes';

  @override
  String get aboutHistoryCardSubtitle => 'Reveja seus últimos resultados';

  @override
  String get aboutProfileLoadError =>
      'Não foi possível carregar o perfil agora.';

  @override
  String get aboutRetryButton => 'Tentar novamente';

  @override
  String get historyTitle => 'Histórico Recente';

  @override
  String get historyEmptyState => 'Seus resultados recentes vão aparecer aqui.';

  @override
  String get historyClearButton => 'Limpar histórico';

  @override
  String get historyClearDialogTitle => 'Limpar histórico?';

  @override
  String get historyClearDialogMessage =>
      'Isso remove todos os resultados recentes deste dispositivo. Essa ação não pode ser desfeita.';

  @override
  String get historyClearDialogCancel => 'Cancelar';

  @override
  String get historyClearDialogConfirm => 'Limpar';

  @override
  String get historyClearedSnackbar => 'Histórico limpo.';

  @override
  String get quickTileCoinAdded => 'Atalho da moeda adicionado ao painel.';

  @override
  String get quickTileCoinAlreadyAdded =>
      'O atalho da moeda ja estava no painel.';

  @override
  String get quickTileCoinCancelled => 'Adicao da moeda cancelada.';

  @override
  String get quickTileCoinUnsupported =>
      'Seu Android nao permite pedir esse atalho pelo app.';

  @override
  String get quickTileDiceAdded => 'Atalho do d20 adicionado ao painel.';

  @override
  String get quickTileDiceAlreadyAdded =>
      'O atalho do d20 ja estava no painel.';

  @override
  String get quickTileDiceCancelled => 'Adicao do d20 cancelada.';

  @override
  String get quickTileDiceUnsupported =>
      'Seu Android nao permite pedir esse atalho pelo app.';

  @override
  String get randomnessSheetEyebrow => 'O que há por trás do acaso';

  @override
  String get randomnessSheetTitle => 'Acaso real vs. pseudoaleatório';

  @override
  String get randomnessCard1Title => 'Computadores não geram acaso de verdade';

  @override
  String get randomnessCard1Body =>
      'A maioria dos apps usa PRNGs (geradores pseudoaleatórios): fórmulas matemáticas determinísticas que partem de uma \"semente\" (seed). Dado o mesmo seed, o resultado é sempre o mesmo — parece aleatório, mas é 100% previsível se você souber o algoritmo e o estado interno.';

  @override
  String get randomnessCard2Title =>
      'Quando disponível, este app usa entropia física';

  @override
  String get randomnessCard2Body =>
      'Quando o Random.org está disponível, cada lançamento consome ruído atmosférico real, coletado a partir de rádio-estática — um fenômeno físico caótico, não um cálculo. Não há semente nem fórmula: o resultado não existe até o instante em que é medido.';

  @override
  String get randomnessCard3Title => 'Por que isso importa na prática';

  @override
  String get randomnessCard3Body =>
      'Em decisões que você quer que sejam justas e incontestáveis — sorteios, desempates, apostas amistosas — a entropia física fornece um resultado de fonte independente. Se o Random.org estiver indisponível, o app usa aleatoriedade pseudoaleatória local e mostra um aviso de fallback.';

  @override
  String get randomnessSheetButton => 'Entendi';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org indisponivel. Usando aleatoriedade local.';
}
