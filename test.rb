EXAMPLES = {
  royal_flush:
    RANKS.last(5).map { Card['S', _1] },

  straight_flush:
    RANKS.first(5).map { Card['S', _1] },

  four_of_a_kind:
    [CARDS[0], *SUITS.map { Card[_1, 'A'] }],

  full_house:
    SUITS.first(3).map { Card[_1, 'A'] } +
    SUITS.first(2).map { Card[_1, 'K'] },

  flush:
    (0..RANKS.size).step(2).first(5).map { Card['S', RANKS[_1]] },

  straight:
    [Card['H', RANKS.first], *RANKS[1..4].map { Card['S', _1] }],

  three_of_a_kind:
    CARDS.first(2) +
    SUITS.first(3).map { Card[_1, 'A'] },

  two_pair:
    CARDS.first(1) +
    SUITS.first(2).flat_map { [Card[_1, 'A'], Card[_1, 'K']] },

  one_pair:
    [CARDS[10], CARDS[15], CARDS[20], *SUITS.first(2).map { Card[_1, 'A'] }],

  high_card:
    [CARDS[10], CARDS[15], CARDS[20], CARDS[5], Card['S', 'A']]
}.freeze

SCORE_MAP = SCORES.invert

EXAMPLES.each do |hand_type, hand|
  score = hand_score(hand)
  correct_text = hand_type == SCORE_MAP[score] ? 'correct' : 'incorrect'

  puts <<~OUT
    Hand:  #{Hand[hand]} (#{hand_type})
    Score: #{score} (#{correct_text})
  OUT

  puts
end
