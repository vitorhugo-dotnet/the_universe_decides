// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'Монета';

  @override
  String get navDice => 'Кістки';

  @override
  String get navCards => 'Карти';

  @override
  String get navLists => 'Списки';

  @override
  String get navTarot => 'Таро';

  @override
  String get navAboutMe => 'Про додаток';

  @override
  String get coinEyebrow => 'Ритуальна печатка';

  @override
  String get coinTitle => 'Орел чи Решка';

  @override
  String get coinRitualSubtitle =>
      'Містична печатка спалахує, підтверджуючи: результат походить із чистого випадку.';

  @override
  String get coinHeads => 'ОРЕЛ';

  @override
  String get coinTails => 'РЕШКА';

  @override
  String get coinResultCaption => 'Рішення прийняв всесвіт — не процесор.';

  @override
  String get coinHint =>
      'Натисніть кнопку або перетягніть монету, щоб підкинути';

  @override
  String get coinHintDrag =>
      'Відпустіть, щоб підкинути — тягніть далі для більшої сили';

  @override
  String get coinDragHelper => 'або перетягніть і кидком підкиньте монету';

  @override
  String get coinButton => 'Підкинути монету';

  @override
  String get diceEyebrow => 'Ритуал Кісток';

  @override
  String get diceTitle => 'Кістки RPG';

  @override
  String get diceCountLabel => 'КІЛЬКІСТЬ';

  @override
  String get diceSidesLabel => 'ГРАНІ';

  @override
  String get diceRollButton => 'Кинути кістки';

  @override
  String diceTotal(int total) {
    return 'Разом: $total';
  }

  @override
  String get cardEyebrow => 'Ритуал Карт';

  @override
  String get cardTitle => 'Повна Колода';

  @override
  String get cardSubtitle => '52 карти. Одна доля на дотик.';

  @override
  String get cardDrawButton => 'Витягнути карту';

  @override
  String get listEyebrow => 'Ритуал Вибору';

  @override
  String get listTitle => 'Жеребкування Списку';

  @override
  String get listSubtitle => 'Додайте варіанти та дозвольте випадку вирішити.';

  @override
  String get listAddOptionHint => 'Новий варіант…';

  @override
  String get listChooseButton => 'Дозволити всесвіту обрати';

  @override
  String get listEmptyState => 'Додайте щонайменше два варіанти, щоб почати.';

  @override
  String get listChosenByUniverse => 'Обрано всесвітом';

  @override
  String get listModeClassic => 'Список';

  @override
  String get listModeWheel => 'Колесо';

  @override
  String get listWheelSpinButton => 'Крутити колесо';

  @override
  String get listWheelHint =>
      'Додайте щонайменше два варіанти, а тоді крутіть.';

  @override
  String get listWheelSpinAgainHint =>
      'Натисніть «крутити», щоб спробувати ще раз.';

  @override
  String get listDuplicateItem => 'Цей елемент вже є у списку.';

  @override
  String listDuplicateItemsDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пропущено $count дубльованого елемента.',
      many: 'Пропущено $count дубльованих елементів.',
      few: 'Пропущено $count дубльовані елементи.',
      one: 'Пропущено 1 дубльований елемент.',
    );
    return '$_temp0';
  }

  @override
  String get tarotEyebrow => 'Ритуал Таро';

  @override
  String get tarotTitle => 'Розклад Таро';

  @override
  String get tarotSubtitle => 'Одна карта, розкрита чистим випадком.';

  @override
  String get tarotButton => 'Розкрити карту';

  @override
  String get tarotWaiting => 'Карта чекає';

  @override
  String get tarotTapReveal => 'Торкніться, щоб розкрити';

  @override
  String get tarotMajorArcana => 'Старші Аркани';

  @override
  String get tarotMinorArcana => 'Молодші Аркани';

  @override
  String tarotDeckPosition(int number) {
    return 'Карта $number із 78';
  }

  @override
  String get aboutEyebrow => 'Оракул';

  @override
  String get aboutTitle => 'Про мене';

  @override
  String get aboutBioFallback =>
      'Творець The Universe Decides — застосунку для рішень на основі справжньої випадковості.';

  @override
  String get aboutShortcutsTitle => 'Швидкі ярлики';

  @override
  String get aboutAddCoinButton => 'Додати монету';

  @override
  String get aboutAddDiceButton => 'Додати d20';

  @override
  String get aboutDonationButton => 'Пригостіть мене кавою';

  @override
  String get aboutSoundEffectsTitle => 'Звукові ефекти';

  @override
  String get aboutSoundEffectsSubtitle =>
      'Відтворювати тихий звук, коли рішення прийнято.';

  @override
  String get aboutRandomnessCardTitle => 'Як працює справжня випадковість?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'Чому застосунок уникає псевдовипадкових чисел';

  @override
  String get aboutProfileLoadError => 'Наразі не вдалося завантажити профіль.';

  @override
  String get aboutRetryButton => 'Спробувати ще раз';

  @override
  String get quickTileCoinAdded => 'Ярлик монети додано на панель.';

  @override
  String get quickTileCoinAlreadyAdded => 'Ярлик монети вже є на панелі.';

  @override
  String get quickTileCoinCancelled => 'Запит на ярлик монети скасовано.';

  @override
  String get quickTileCoinUnsupported =>
      'Ваша версія Android не може додати цей ярлик із застосунку.';

  @override
  String get quickTileDiceAdded => 'Ярлик d20 додано на панель.';

  @override
  String get quickTileDiceAlreadyAdded => 'Ярлик d20 вже є на панелі.';

  @override
  String get quickTileDiceCancelled => 'Запит на ярлик d20 скасовано.';

  @override
  String get quickTileDiceUnsupported =>
      'Ваша версія Android не може додати цей ярлик із застосунку.';

  @override
  String get randomnessSheetEyebrow => 'Що стоїть за випадковістю';

  @override
  String get randomnessSheetTitle =>
      'Справжній випадок проти псевдовипадковості';

  @override
  String get randomnessCard1Title =>
      'Комп\'ютери не створюють справжню випадковість';

  @override
  String get randomnessCard1Body =>
      'Більшість застосунків використовують PRNG (генератори псевдовипадкових чисел): детерміновані математичні формули, що починаються із \"зерна\" (seed). За того самого зерна результат завжди однаковий — це виглядає випадковим, але на 100% передбачуване, якщо відомий алгоритм і його внутрішній стан.';

  @override
  String get randomnessCard2Title =>
      'Коли доступно, цей застосунок використовує фізичну ентропію';

  @override
  String get randomnessCard2Body =>
      'Коли Random.org доступний, жеребкування використовує справжній атмосферний шум, зібраний із радіоперешкод — хаотичне фізичне явище, а не обчислення. Немає ні зерна, ні формули: результат не існує до моменту, коли його виміряно.';

  @override
  String get randomnessCard3Title => 'Чому це важливо на практиці';

  @override
  String get randomnessCard3Body =>
      'Для рішень, які мають бути чесними й незаперечними — жеребкування, визначення переможця за нічиєї, дружні парі — фізична ентропія дає результат із незалежного джерела. Якщо Random.org недоступний, застосунок використовує локальну псевдовипадковість і показує повідомлення про резервний режим.';

  @override
  String get randomnessSheetButton => 'Зрозуміло';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org недоступний. Використовується локальна випадковість.';
}
