// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'Moneda';

  @override
  String get navDice => 'Dados';

  @override
  String get navCards => 'Cartas';

  @override
  String get navLists => 'Listas';

  @override
  String get navTarot => 'Tarot';

  @override
  String get navAboutMe => 'Acerca';

  @override
  String get coinEyebrow => 'Sello Ritual';

  @override
  String get coinTitle => 'Cara o Cruz';

  @override
  String get coinRitualSubtitle =>
      'Un sello místico se enciende para confirmar: el resultado viene del azar puro.';

  @override
  String get coinHeads => 'CARA';

  @override
  String get coinTails => 'CRUZ';

  @override
  String get coinResultCaption => 'El universo decidió — no el procesador.';

  @override
  String get coinHint => 'Toca el botón o arrastra la moneda para lanzarla';

  @override
  String get coinHintDrag =>
      'Suelta para lanzar — tira más lejos para más fuerza';

  @override
  String get coinDragHelper => 'o arrastra y suelta la moneda para lanzarla';

  @override
  String get coinButton => 'Lanzar moneda';

  @override
  String get diceEyebrow => 'Ritual de los Dados';

  @override
  String get diceTitle => 'Dados de RPG';

  @override
  String get diceCountLabel => 'CANTIDAD';

  @override
  String get diceSidesLabel => 'CARAS';

  @override
  String get diceRollButton => 'Tirar dados';

  @override
  String diceTotal(int total) {
    return 'Total: $total';
  }

  @override
  String get cardEyebrow => 'Ritual de las Cartas';

  @override
  String get cardTitle => 'Baraja Completa';

  @override
  String get cardSubtitle => '52 cartas. Un destino por toque.';

  @override
  String get cardDrawButton => 'Sacar una carta';

  @override
  String get listEyebrow => 'Ritual de la Elección';

  @override
  String get listTitle => 'Sorteo de Lista';

  @override
  String get listSubtitle => 'Agrega opciones y deja que el azar decida.';

  @override
  String get listAddOptionHint => 'Nueva opción…';

  @override
  String get listChooseButton => 'Dejar que el universo elija';

  @override
  String get listEmptyState => 'Agrega al menos dos opciones para comenzar.';

  @override
  String get listChosenByUniverse => 'Elegido por el universo';

  @override
  String get listModeClassic => 'Lista';

  @override
  String get listModeWheel => 'Ruleta';

  @override
  String get listWheelSpinButton => 'Girar la ruleta';

  @override
  String get listWheelHint => 'Agrega al menos dos opciones y gira.';

  @override
  String get listWheelSpinAgainHint => 'Toca girar para intentarlo de nuevo.';

  @override
  String get listDuplicateItem => 'Este elemento ya existe en la lista.';

  @override
  String listDuplicateItemsDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se omitieron $count elementos duplicados.',
      one: 'Se omitió 1 elemento duplicado.',
    );
    return '$_temp0';
  }

  @override
  String get tarotEyebrow => 'Ritual del Tarot';

  @override
  String get tarotTitle => 'Lectura de Tarot';

  @override
  String get tarotSubtitle => 'Una carta, revelada por el azar puro.';

  @override
  String get tarotButton => 'Revelar carta';

  @override
  String get tarotWaiting => 'La carta espera';

  @override
  String get tarotTapReveal => 'Toca para revelar';

  @override
  String get tarotMajorArcana => 'Arcanos Mayores';

  @override
  String get tarotMinorArcana => 'Arcanos Menores';

  @override
  String tarotDeckPosition(int number) {
    return 'Carta $number de 78';
  }

  @override
  String get aboutEyebrow => 'El Oráculo';

  @override
  String get aboutTitle => 'Acerca de mí';

  @override
  String get aboutBioFallback =>
      'Creador de The Universe Decides — una app de decisiones impulsada por aleatoriedad real.';

  @override
  String get aboutShortcutsTitle => 'Accesos rápidos';

  @override
  String get aboutAddCoinButton => 'Añadir moneda';

  @override
  String get aboutAddDiceButton => 'Añadir d20';

  @override
  String get aboutDonationButton => 'Invítame un café';

  @override
  String get aboutSoundEffectsTitle => 'Efectos de sonido';

  @override
  String get aboutSoundEffectsSubtitle =>
      'Reproducir un sonido sutil cuando se complete una decisión.';

  @override
  String get aboutRandomnessCardTitle => '¿Cómo funciona el azar real?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'Por qué la app evita los números pseudoaleatorios';

  @override
  String get aboutHistoryCardTitle => 'Resultados recientes';

  @override
  String get aboutHistoryCardSubtitle => 'Revisa tus últimos resultados';

  @override
  String get aboutProfileLoadError =>
      'No se pudo cargar el perfil en este momento.';

  @override
  String get aboutRetryButton => 'Reintentar';

  @override
  String get historyTitle => 'Historial Reciente';

  @override
  String get historyEmptyState => 'Tus resultados recientes aparecerán aquí.';

  @override
  String get historyClearButton => 'Borrar historial';

  @override
  String get historyClearDialogTitle => '¿Borrar historial?';

  @override
  String get historyClearDialogMessage =>
      'Esto elimina todos los resultados recientes de este dispositivo. Esta acción no se puede deshacer.';

  @override
  String get historyClearDialogCancel => 'Cancelar';

  @override
  String get historyClearDialogConfirm => 'Borrar';

  @override
  String get historyClearedSnackbar => 'Historial borrado.';

  @override
  String get quickTileCoinAdded =>
      'Acceso directo de la moneda añadido al panel.';

  @override
  String get quickTileCoinAlreadyAdded =>
      'El acceso directo de la moneda ya está en el panel.';

  @override
  String get quickTileCoinCancelled =>
      'Solicitud del acceso directo de la moneda cancelada.';

  @override
  String get quickTileCoinUnsupported =>
      'Tu versión de Android no puede añadir este acceso directo desde la app.';

  @override
  String get quickTileDiceAdded => 'Acceso directo del d20 añadido al panel.';

  @override
  String get quickTileDiceAlreadyAdded =>
      'El acceso directo del d20 ya está en el panel.';

  @override
  String get quickTileDiceCancelled =>
      'Solicitud del acceso directo del d20 cancelada.';

  @override
  String get quickTileDiceUnsupported =>
      'Tu versión de Android no puede añadir este acceso directo desde la app.';

  @override
  String get randomnessSheetEyebrow => 'Qué hay detrás del azar';

  @override
  String get randomnessSheetTitle => 'Azar real vs. pseudoaleatorio';

  @override
  String get randomnessCard1Title =>
      'Las computadoras no crean aleatoriedad verdadera';

  @override
  String get randomnessCard1Body =>
      'La mayoría de las apps usan PRNG (generadores pseudoaleatorios): fórmulas matemáticas deterministas que parten de una \"semilla\". Dada la misma semilla, el resultado es siempre el mismo — parece aleatorio, pero es 100% predecible si conoces el algoritmo y su estado interno.';

  @override
  String get randomnessCard2Title =>
      'Cuando está disponible, esta app usa entropía física';

  @override
  String get randomnessCard2Body =>
      'Cuando Random.org está disponible, cada sorteo consume ruido atmosférico real, captado de la estática de radio — un fenómeno físico caótico, no un cálculo. No hay semilla ni fórmula: el resultado no existe hasta el instante en que se mide.';

  @override
  String get randomnessCard3Title => 'Por qué esto importa en la práctica';

  @override
  String get randomnessCard3Body =>
      'Para decisiones que quieres que sean justas e indiscutibles — sorteos, desempates, apuestas amistosas — la entropía física ofrece un resultado de origen independiente. Si Random.org no está disponible, la app usa aleatoriedad pseudoaleatoria local y muestra un aviso de respaldo.';

  @override
  String get randomnessSheetButton => 'Entendido';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org no está disponible. Usando aleatoriedad local.';
}
