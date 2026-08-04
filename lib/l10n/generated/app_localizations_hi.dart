// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'The Universe Decides';

  @override
  String get navCoin => 'सिक्का';

  @override
  String get navDice => 'पासा';

  @override
  String get navCards => 'कार्ड्स';

  @override
  String get navLists => 'सूचियाँ';

  @override
  String get navTarot => 'टैरो';

  @override
  String get navAboutMe => 'परिचय';

  @override
  String get coinEyebrow => 'अनुष्ठान मुहर';

  @override
  String get coinTitle => 'हेड्स या टेल्स';

  @override
  String get coinRitualSubtitle =>
      'एक रहस्यमय मुहर जलती है यह पुष्टि करने के लिए: परिणाम शुद्ध संयोग से आता है।';

  @override
  String get coinHeads => 'हेड्स';

  @override
  String get coinTails => 'टेल्स';

  @override
  String get coinResultCaption => 'ब्रह्मांड ने तय किया — प्रोसेसर ने नहीं।';

  @override
  String get coinHint => 'उछालने के लिए बटन दबाएं या सिक्के को खींचें';

  @override
  String get coinHintDrag =>
      'उछालने के लिए छोड़ें — अधिक ज़ोर के लिए और खींचें';

  @override
  String get coinDragHelper => 'या सिक्के को खींचकर फेंकें';

  @override
  String get coinButton => 'सिक्का उछालें';

  @override
  String get diceEyebrow => 'पासा अनुष्ठान';

  @override
  String get diceTitle => 'RPG पासे';

  @override
  String get diceCountLabel => 'मात्रा';

  @override
  String get diceSidesLabel => 'पहलू';

  @override
  String get diceRollButton => 'पासा फेंकें';

  @override
  String diceTotal(int total) {
    return 'कुल: $total';
  }

  @override
  String get cardEyebrow => 'कार्ड अनुष्ठान';

  @override
  String get cardTitle => 'पूरा डेक';

  @override
  String get cardSubtitle => '52 कार्ड। एक टैप, एक नियति।';

  @override
  String get cardDrawButton => 'एक कार्ड निकालें';

  @override
  String get listEyebrow => 'चयन अनुष्ठान';

  @override
  String get listTitle => 'सूची चयन';

  @override
  String get listSubtitle => 'विकल्प जोड़ें और संयोग को निर्णय लेने दें।';

  @override
  String get listAddOptionHint => 'नया विकल्प…';

  @override
  String get listChooseButton => 'ब्रह्मांड को चुनने दें';

  @override
  String get listEmptyState => 'शुरू करने के लिए कम से कम दो विकल्प जोड़ें।';

  @override
  String get listChosenByUniverse => 'ब्रह्मांड द्वारा चुना गया';

  @override
  String get listModeClassic => 'सूची';

  @override
  String get listModeWheel => 'पहिया';

  @override
  String get listWheelSpinButton => 'पहिया घुमाएं';

  @override
  String get listWheelHint => 'कम से कम दो विकल्प जोड़ें, फिर घुमाएं।';

  @override
  String get listWheelSpinAgainHint => 'फिर से आज़माने के लिए घुमाएं दबाएं।';

  @override
  String get listDuplicateItem => 'यह आइटम पहले से सूची में मौजूद है।';

  @override
  String listDuplicateItemsDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count डुप्लिकेट आइटम छोड़ दिए गए।',
      one: '1 डुप्लिकेट आइटम छोड़ दिया गया।',
    );
    return '$_temp0';
  }

  @override
  String get tarotEyebrow => 'टैरो अनुष्ठान';

  @override
  String get tarotTitle => 'टैरो रीडिंग';

  @override
  String get tarotSubtitle => 'एक कार्ड, शुद्ध संयोग से प्रकट।';

  @override
  String get tarotButton => 'कार्ड प्रकट करें';

  @override
  String get tarotWaiting => 'कार्ड प्रतीक्षा में है';

  @override
  String get tarotTapReveal => 'प्रकट करने के लिए टैप करें';

  @override
  String get tarotMajorArcana => 'मेजर आर्काना';

  @override
  String get tarotMinorArcana => 'माइनर आर्काना';

  @override
  String tarotDeckPosition(int number) {
    return 'कार्ड $number / 78';
  }

  @override
  String get aboutEyebrow => 'दैवज्ञ';

  @override
  String get aboutTitle => 'मेरे बारे में';

  @override
  String get aboutBioFallback =>
      'The Universe Decides के निर्माता — वास्तविक यादृच्छिकता से संचालित एक निर्णय ऐप।';

  @override
  String get aboutShortcutsTitle => 'त्वरित शॉर्टकट';

  @override
  String get aboutAddCoinButton => 'सिक्का जोड़ें';

  @override
  String get aboutAddDiceButton => 'd20 जोड़ें';

  @override
  String get aboutDonationButton => 'मुझे कॉफ़ी पिलाएं';

  @override
  String get aboutSoundEffectsTitle => 'ध्वनि प्रभाव';

  @override
  String get aboutSoundEffectsSubtitle =>
      'निर्णय पूरा होने पर एक हल्की ध्वनि बजाएं।';

  @override
  String get aboutRandomnessCardTitle =>
      'वास्तविक यादृच्छिकता कैसे काम करती है?';

  @override
  String get aboutRandomnessCardSubtitle =>
      'ऐप छद्म-यादृच्छिक संख्याओं से क्यों बचता है';

  @override
  String get aboutHistoryCardTitle => 'हाल के परिणाम';

  @override
  String get aboutHistoryCardSubtitle => 'अपने पिछले परिणाम देखें';

  @override
  String get aboutProfileLoadError => 'अभी प्रोफ़ाइल लोड नहीं हो सकी।';

  @override
  String get aboutRetryButton => 'फिर से प्रयास करें';

  @override
  String get historyTitle => 'हाल का इतिहास';

  @override
  String get historyEmptyState => 'आपके हाल के परिणाम यहाँ दिखेंगे।';

  @override
  String get historyClearButton => 'इतिहास साफ़ करें';

  @override
  String get historyClearDialogTitle => 'इतिहास साफ़ करें?';

  @override
  String get historyClearDialogMessage =>
      'इससे इस डिवाइस से सभी हाल के परिणाम हट जाएंगे। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get historyClearDialogCancel => 'रद्द करें';

  @override
  String get historyClearDialogConfirm => 'साफ़ करें';

  @override
  String get historyClearedSnackbar => 'इतिहास साफ़ हो गया।';

  @override
  String get quickTileCoinAdded => 'सिक्का शॉर्टकट पैनल में जोड़ा गया।';

  @override
  String get quickTileCoinAlreadyAdded =>
      'सिक्का शॉर्टकट पहले से ही पैनल में है।';

  @override
  String get quickTileCoinCancelled =>
      'सिक्का शॉर्टकट का अनुरोध रद्द किया गया।';

  @override
  String get quickTileCoinUnsupported =>
      'आपका Android संस्करण ऐप से यह शॉर्टकट नहीं जोड़ सकता।';

  @override
  String get quickTileDiceAdded => 'd20 शॉर्टकट पैनल में जोड़ा गया।';

  @override
  String get quickTileDiceAlreadyAdded => 'd20 शॉर्टकट पहले से ही पैनल में है।';

  @override
  String get quickTileDiceCancelled => 'd20 शॉर्टकट का अनुरोध रद्द किया गया।';

  @override
  String get quickTileDiceUnsupported =>
      'आपका Android संस्करण ऐप से यह शॉर्टकट नहीं जोड़ सकता।';

  @override
  String get randomnessSheetEyebrow => 'संयोग के पीछे क्या है';

  @override
  String get randomnessSheetTitle => 'वास्तविक संयोग बनाम छद्म-यादृच्छिक';

  @override
  String get randomnessCard1Title => 'कंप्यूटर सच्ची यादृच्छिकता नहीं बनाते';

  @override
  String get randomnessCard1Body =>
      'अधिकांश ऐप्स PRNG (छद्म-यादृच्छिक जनरेटर) का उपयोग करते हैं: नियतात्मक गणितीय सूत्र जो एक \"सीड\" से शुरू होते हैं। समान सीड दिए जाने पर, परिणाम हमेशा समान होता है — यह यादृच्छिक दिखता है, लेकिन यदि आप एल्गोरिदम और उसकी आंतरिक स्थिति जानते हैं तो यह 100% पूर्वानुमेय है।';

  @override
  String get randomnessCard2Title =>
      'उपलब्ध होने पर, यह ऐप भौतिक एन्ट्रॉपी का उपयोग करता है';

  @override
  String get randomnessCard2Body =>
      'जब Random.org उपलब्ध होता है, तो एक ड्रा रेडियो स्थैतिक से एकत्रित वास्तविक वायुमंडलीय शोर का उपयोग करता है — एक अराजक भौतिक घटना, गणना नहीं। कोई सीड या सूत्र नहीं है: परिणाम तब तक अस्तित्व में नहीं आता जब तक इसे मापा नहीं जाता।';

  @override
  String get randomnessCard3Title => 'व्यवहार में यह क्यों मायने रखता है';

  @override
  String get randomnessCard3Body =>
      'उन निर्णयों के लिए जिन्हें आप निष्पक्ष और निर्विवाद चाहते हैं — ड्रॉ, टाई-ब्रेक, दोस्ताना दांव — भौतिक एन्ट्रॉपी एक स्वतंत्र स्रोत से प्राप्त परिणाम प्रदान करती है। यदि Random.org अनुपलब्ध है, तो ऐप स्थानीय छद्म-यादृच्छिकता का उपयोग करता है और एक फ़ॉलबैक सूचना दिखाता है।';

  @override
  String get randomnessSheetButton => 'समझ गया';

  @override
  String get randomOrgFallbackNotice =>
      'Random.org उपलब्ध नहीं है। स्थानीय यादृच्छिकता का उपयोग किया जा रहा है।';
}
