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
  String get navLists => 'Listas';

  @override
  String get navTarot => 'Tarô';

  @override
  String get navAboutMe => 'Sobre mim';

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
  String get diceSubtitle =>
      'Role seus dados de RPG com multiplos lados e deixe o destino somar o resultado final.';

  @override
  String get diceCount => 'Quantidade de dados';

  @override
  String get diceSides => 'Lados do dado';

  @override
  String get diceRollButton => 'Rolar os dados';

  @override
  String get diceEmptyState =>
      'Escolha a combinacao e role para ver cada valor e a soma final.';

  @override
  String get diceResults => 'Resultados';

  @override
  String diceTotal(int total) {
    return 'Total: $total';
  }

  @override
  String get cardDrawSubtitle =>
      'Sorteie uma carta com aleatoriedade real e deixe o universo revelar um sinal moderno em um baralho completo de 52 cartas.';

  @override
  String get cardDrawPrompt => 'Sorteie uma carta do baralho cósmico';

  @override
  String get cardDrawTapPrompt =>
      'Toque abaixo para revelar sua próxima carta.';

  @override
  String get cardDrawResolved => 'O universo revelou a sua carta.';

  @override
  String get cardDrawButton => 'Sortear carta';

  @override
  String get listSubtitle =>
      'Escreva possibilidades, convide o universo e destaque um unico destino para a sua proxima decisao.';

  @override
  String get listAddOptionLabel => 'Adicionar opcao';

  @override
  String get listAddOptionHint => 'Ex.: Viajar, dormir, pedir pizza...';

  @override
  String get listAddButton => 'Adicionar';

  @override
  String get listChooseButton => 'Escolher por mim';

  @override
  String get listEmptyState =>
      'Adicione itens a lista para deixar a escolha nas mãos do universo.';

  @override
  String get listChosenByUniverse => 'Escolhido pelo universo';

  @override
  String get tarotSubtitle =>
      'Tirar uma única carta do baralho completo de 78 cartas e deixar a aleatoriedade real revelar o arquétipo que guia este momento.';

  @override
  String get tarotPrompt => 'O baralho está esperando';

  @override
  String get tarotTapPrompt =>
      'Tirar uma carta para revelar o símbolo escolhido pelo universo.';

  @override
  String get tarotButton => 'Tirar uma carta';

  @override
  String get tarotMajorArcana => 'Arcano Maior';

  @override
  String get tarotMinorArcana => 'Arcano Menor';

  @override
  String tarotDeckPosition(int number) {
    return 'Carta $number de 78';
  }

  @override
  String get aboutSubtitle =>
      'Um cantinho com o perfil do criador, puxando o avatar direto da API do GitHub.';

  @override
  String get aboutProfileLoadError =>
      'Não foi possível carregar o perfil agora.';

  @override
  String get aboutRetryButton => 'Tentar novamente';

  @override
  String get aboutQuickAccessTitle => 'Acesso rapido no painel';

  @override
  String get aboutQuickAccessDescription =>
      'Adicione atalhos da moeda e do d20 ao painel rapido do Android para abrir o app e executar a acao direto.';

  @override
  String get aboutAddCoinButton => 'Adicionar moeda';

  @override
  String get aboutAddDiceButton => 'Adicionar d20';

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
  String get randomOrgFallbackNotice =>
      'Random.org indisponivel. Usando aleatoriedade local.';
}
