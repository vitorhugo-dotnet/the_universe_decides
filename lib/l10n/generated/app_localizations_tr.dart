// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'Para';

  @override
  String get navDice => 'Zar';

  @override
  String get navCards => 'Kartlar';

  @override
  String get navLists => 'Listeler';

  @override
  String get navTarot => 'Tarot';

  @override
  String get navAboutMe => 'Hakkında';

  @override
  String get coinEyebrow => 'Ritüel Mührü';

  @override
  String get coinTitle => 'Yazı Tura';

  @override
  String get coinRitualSubtitle =>
      'Mistik bir mühür yanar ve şunu doğrular: sonuç saf şanstan gelir.';

  @override
  String get coinHeads => 'YAZI';

  @override
  String get coinTails => 'TURA';

  @override
  String get coinResultCaption => 'Evren karar verdi — işlemci değil.';

  @override
  String get coinHint => 'Çevirmek için düğmeye dokun ya da parayı sürükle';

  @override
  String get coinHintDrag =>
      'Çevirmek için bırak — daha fazla güç için daha çok çek';

  @override
  String get coinDragHelper => 'ya da parayı sürükleyip fırlatarak at';

  @override
  String get coinButton => 'Parayı çevir';

  @override
  String get diceEyebrow => 'Zar Ritüeli';

  @override
  String get diceTitle => 'RPG Zarları';

  @override
  String get diceCountLabel => 'ADET';

  @override
  String get diceSidesLabel => 'YÜZEY';

  @override
  String get diceRollButton => 'Zar at';

  @override
  String diceTotal(int total) {
    return 'Toplam: $total';
  }

  @override
  String get cardEyebrow => 'Kart Ritüeli';

  @override
  String get cardTitle => 'Tam Deste';

  @override
  String get cardSubtitle => '52 kart. Her dokunuşta bir kader.';

  @override
  String get cardDrawButton => 'Kart çek';

  @override
  String get listEyebrow => 'Seçim Ritüeli';

  @override
  String get listTitle => 'Liste Çekilişi';

  @override
  String get listSubtitle =>
      'Seçenekler ekle ve şansın karar vermesine izin ver.';

  @override
  String get listAddOptionHint => 'Yeni seçenek…';

  @override
  String get listChooseButton => 'Evrenin seçmesine izin ver';

  @override
  String get listEmptyState => 'Başlamak için en az iki seçenek ekle.';

  @override
  String get listChosenByUniverse => 'Evren tarafından seçildi';

  @override
  String get listModeClassic => 'Liste';

  @override
  String get listModeWheel => 'Çark';

  @override
  String get listWheelSpinButton => 'Çarkı çevir';

  @override
  String get listWheelHint => 'En az iki seçenek ekle, sonra çevir.';

  @override
  String get listWheelSpinAgainHint => 'Tekrar denemek için çevire dokun.';

  @override
  String get listDuplicateItem => 'Bu öğe listede zaten var.';

  @override
  String listDuplicateItemsDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yinelenen öğe atlandı.',
      one: '1 yinelenen öğe atlandı.',
    );
    return '$_temp0';
  }

  @override
  String get tarotEyebrow => 'Tarot Ritüeli';

  @override
  String get tarotTitle => 'Tarot Falı';

  @override
  String get tarotSubtitle => 'Saf şansla açığa çıkan tek bir kart.';

  @override
  String get tarotButton => 'Kartı aç';

  @override
  String get tarotWaiting => 'Kart bekliyor';

  @override
  String get tarotTapReveal => 'Açmak için dokun';

  @override
  String get tarotMajorArcana => 'Büyük Arkana';

  @override
  String get tarotMinorArcana => 'Küçük Arkana';

  @override
  String tarotDeckPosition(int number) {
    return 'Kart $number / 78';
  }

  @override
  String get aboutEyebrow => 'Kâhin';

  @override
  String get aboutTitle => 'Hakkımda';

  @override
  String get aboutBioFallback =>
      'The Universe Decides\'ın yaratıcısı — gerçek rastgelelikle çalışan bir karar uygulaması.';

  @override
  String get aboutShortcutsTitle => 'Hızlı kısayollar';

  @override
  String get aboutAddCoinButton => 'Para ekle';

  @override
  String get aboutAddDiceButton => 'd20 ekle';

  @override
  String get aboutDonationButton => 'Bana bir kahve ısmarla';

  @override
  String get aboutSoundEffectsTitle => 'Ses efektleri';

  @override
  String get aboutSoundEffectsSubtitle =>
      'Bir karar tamamlandığında hafif bir ses çal.';

  @override
  String get aboutRandomnessCardTitle => 'Gerçek rastgelelik nasıl çalışır?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'Uygulama neden sözde rastgele sayılardan kaçınır';

  @override
  String get aboutProfileLoadError => 'Profil şu anda yüklenemedi.';

  @override
  String get aboutRetryButton => 'Tekrar dene';

  @override
  String get quickTileCoinAdded => 'Para kısayolu panele eklendi.';

  @override
  String get quickTileCoinAlreadyAdded => 'Para kısayolu zaten panelde.';

  @override
  String get quickTileCoinCancelled => 'Para kısayolu isteği iptal edildi.';

  @override
  String get quickTileCoinUnsupported =>
      'Android sürümün bu kısayolu uygulamadan ekleyemiyor.';

  @override
  String get quickTileDiceAdded => 'd20 kısayolu panele eklendi.';

  @override
  String get quickTileDiceAlreadyAdded => 'd20 kısayolu zaten panelde.';

  @override
  String get quickTileDiceCancelled => 'd20 kısayolu isteği iptal edildi.';

  @override
  String get quickTileDiceUnsupported =>
      'Android sürümün bu kısayolu uygulamadan ekleyemiyor.';

  @override
  String get randomnessSheetEyebrow => 'Şansın arkasında ne var';

  @override
  String get randomnessSheetTitle => 'Gerçek şans ile sözde rastgelelik';

  @override
  String get randomnessCard1Title => 'Bilgisayarlar gerçek rastgelelik üretmez';

  @override
  String get randomnessCard1Body =>
      'Çoğu uygulama PRNG (sözde rastgele üreteçler) kullanır: bir \"seed\"den başlayan deterministik matematiksel formüller. Aynı seed verildiğinde sonuç her zaman aynıdır — rastgele görünür ama algoritmayı ve iç durumunu bilirseniz %100 tahmin edilebilir.';

  @override
  String get randomnessCard2Title =>
      'Mevcut olduğunda bu uygulama fiziksel entropi kullanır';

  @override
  String get randomnessCard2Body =>
      'Random.org mevcut olduğunda, bir çekiliş radyo parazitinden toplanan gerçek atmosferik gürültüyü kullanır — kaotik bir fiziksel olgu, bir hesaplama değil. Seed veya formül yoktur: sonuç ölçüldüğü ana kadar var olmaz.';

  @override
  String get randomnessCard3Title => 'Bu pratikte neden önemli';

  @override
  String get randomnessCard3Body =>
      'Adil ve tartışılmaz olmasını istediğiniz kararlar için — çekilişler, beraberlik bozma, dostane bahisler — fiziksel entropi bağımsız kaynaklı bir sonuç sağlar. Random.org kullanılamıyorsa uygulama yerel sözde rastgeleliği kullanır ve bir yedek bildirimi gösterir.';

  @override
  String get randomnessSheetButton => 'Anladım';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org kullanılamıyor. Yerel rastgelelik kullanılıyor.';
}
