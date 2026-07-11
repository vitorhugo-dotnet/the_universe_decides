import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/services/random_org_service.dart';

const _unset = Object();

final tarotDrawProvider = NotifierProvider<TarotDrawController, TarotDrawState>(
  TarotDrawController.new,
);

class TarotDrawState {
  const TarotDrawState({this.card, this.isLoading = false, this.drawCount = 0});

  final TarotCard? card;
  final bool isLoading;
  final int drawCount;

  TarotDrawState copyWith({
    Object? card = _unset,
    bool? isLoading,
    int? drawCount,
  }) {
    return TarotDrawState(
      card: identical(card, _unset) ? this.card : card as TarotCard?,
      isLoading: isLoading ?? this.isLoading,
      drawCount: drawCount ?? this.drawCount,
    );
  }
}

class TarotDrawController extends Notifier<TarotDrawState> {
  late final RandomOrgService _randomOrgService;

  @override
  TarotDrawState build() {
    _randomOrgService = ref.read(randomOrgServiceProvider);
    return const TarotDrawState();
  }

  Future<void> drawCard() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final values = await _randomOrgService.fetchIntegers(
      count: 1,
      min: 1,
      max: 78,
    );
    final rawDeckNumber = values.isEmpty ? 1 : values.first;
    final deckNumber = rawDeckNumber < 1
        ? 1
        : rawDeckNumber > 78
        ? 78
        : rawDeckNumber;

    state = state.copyWith(
      isLoading: false,
      drawCount: state.drawCount + 1,
      card: TarotCard.fromDeckNumber(deckNumber),
    );
  }
}

enum TarotSuit { wands, cups, swords, pentacles }

class TarotCard {
  const TarotCard._({
    required this.deckNumber,
    required this.title,
    required this.isMajorArcana,
    this.suit,
    this.rank,
  });

  factory TarotCard.fromDeckNumber(int deckNumber) {
    final normalizedDeckNumber = deckNumber < 1
        ? 1
        : deckNumber > 78
        ? 78
        : deckNumber;

    if (normalizedDeckNumber <= _majorArcana.length) {
      // Random.org gives us a 1-based deck position. Keeping the major arcana
      // in a 22-item list lets us translate 1-22 directly into their matching
      // cards without any extra offsets or special cases.
      return TarotCard._(
        deckNumber: normalizedDeckNumber,
        title: _majorArcana[normalizedDeckNumber - 1],
        isMajorArcana: true,
      );
    }

    // Positions 23-78 belong to the 56-card minor arcana block. Subtracting 23
    // shifts that block to zero-based math, then `/ 14` picks the suit and
    // `% 14` picks the rank inside that suit because each suit contains exactly
    // 14 cards from Ace through King.
    final minorArcanaIndex = normalizedDeckNumber - 23;
    final suit = TarotSuit.values[minorArcanaIndex ~/ _minorArcanaRanks.length];
    final rank = _minorArcanaRanks[minorArcanaIndex % _minorArcanaRanks.length];

    return TarotCard._(
      deckNumber: normalizedDeckNumber,
      title: '$rank of ${_suitLabels[suit]!}',
      isMajorArcana: false,
      suit: suit,
      rank: rank,
    );
  }

  final int deckNumber;
  final String title;
  final bool isMajorArcana;
  final TarotSuit? suit;
  final String? rank;

  static const _majorArcana = [
    'The Fool',
    'The Magician',
    'The High Priestess',
    'The Empress',
    'The Emperor',
    'The Hierophant',
    'The Lovers',
    'The Chariot',
    'Strength',
    'The Hermit',
    'Wheel of Fortune',
    'Justice',
    'The Hanged Man',
    'Death',
    'Temperance',
    'The Devil',
    'The Tower',
    'The Star',
    'The Moon',
    'The Sun',
    'Judgement',
    'The World',
  ];

  static const _minorArcanaRanks = [
    'Ace',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Page',
    'Knight',
    'Queen',
    'King',
  ];

  static const _suitLabels = {
    TarotSuit.wands: 'Wands',
    TarotSuit.cups: 'Cups',
    TarotSuit.swords: 'Swords',
    TarotSuit.pentacles: 'Pentacles',
  };
}
