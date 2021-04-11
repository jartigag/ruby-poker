#!/usr/bin/env ruby
#
# from: https://dev.to/baweaver/ruby-3-pattern-matching-applied-poker-4b9d

#########
# Structs:
#########

Card = Struct.new(:suit, :rank) do
  # Structs are kind of classes, but without initialize(suit, rank).

  include Comparable

  def precedence()      = [SUITS_SCORES[self.suit], RANKS_SCORES[self.rank]]
                          # Sorted by suit first, then by rank:
                          # Example:
                          # Spades outrank Hearts, Aces outrank other ranks
  def rank_precedence() = RANKS_SCORES[self.rank]
  def suit_precedence() = SUITS_SCORES[self.rank]

  # Comparator (if x<y: return -1, =: return 0, >: return 1, not comparable: return nil):
  def <=>(other) = self.precedence <=> other.precedence

  def to_s() = "#{self.suit}#{self.rank}"
end

Hand = Struct.new(:cards) do
  def sort()         = Hand[self.cards.sort]
  def sort_by_rank() = Hand[self.cards.sort_by(&:rank_precedence)]

  def to_s() = self.cards.map(&:to_s).join(', ')
end

###########
# Constants:
###########

SUITS        = %w(S H D C).freeze # Spades, Hearts, Diamonds, Clubs
SUITS_SCORES = SUITS.each_with_index.to_h

# Array#to_h: returns an array of key-value pairs. Example in interactive console:
# $ irb
# irb(main):001:0> [[:S, 0], [:H, 1], [:D, 2], [:C, 3]].to_h
# => {"S"=>0, "H"=>1, "D"=>2, "C"=>3}

RANKS        = [*2..10, *%w(J Q K A)].map(&:to_s).freeze
RANKS_SCORES = RANKS.each_with_index.to_h

SCORES = %i(
  royal_flush
  straight_flush
  four_of_a_kind
  full_house
  flush
  straight
  three_of_a_kind
  two_pair
  one_pair
  high_card
).reverse_each.with_index(1).to_h.freeze

# Product of all the SUITS applied to all of the card RANKS:
CARDS = SUITS.flat_map { |s| RANKS.map { |r| Card[s, r] } }.freeze

def hand_score(unsorted_hand)
  hand = Hand[unsorted_hand].sort_by_rank.cards

  # Lambda function:
  is_straight = -> hand {
    hand                             # To check if this is a straight,
      .map { RANKS_SCORES[_1.rank] } # we don't care about the suit.
      .sort
      .each_cons(2)                  # Getting cards as pairs, we check that
      .all? { |a, b| b - a == 1 }    # every card is only one rank apart, that is,
                                     # every pair is part of a straight.
  }

#################
# Pattern Matches:
#################

  return SCORES[:royal_flush] if hand in [
    Card[s, '10'], Card[^s, 'J'], Card[^s, 'Q'], Card[^s, 'K'], Card[^s, 'A']
    #    s: capture the first suit we see
    #   ^s: we expect all the following suits to be the same
  ]

  return SCORES[:straight_flush] if is_straight[hand] && hand in [
    Card[s, *], Card[^s, *], Card[^s, *], Card[^s, *], Card[^s, *]
  ]

  return SCORES[:four_of_a_kind] if hand in [
    *, Card[*, r], Card[*, ^r], Card[*, ^r], Card[*, ^r], *
    #                                                     *: four_of_a_king could be anywhere
    #                                                        in the middle of our hand. Here,
    #                                                        both at the front or back of the hand
    #                                                        (AAAAK and KAAAA) are valid.
  ]

  # We can't use named captures and pins if we use | for an "OR" pattern,
  # so we have to break :full_house into two matches:

  return SCORES[:full_house] if hand in [
    # AAABB
    Card[*, r1], Card[*, ^r1], Card[*, ^r1], Card[*, r2], Card[*, ^r2]
  ]

  return SCORES[:full_house] if hand in [
    # AABBB
    Card[*, r1], Card[*, ^r1], Card[*, r2], Card[*, ^r2], Card[*, ^r2]
  ]

  return SCORES[:flush] if hand in [
    Card[s, *], Card[^s, *], Card[^s, *], Card[^s, *], Card[^s, *]
  ]

  return SCORES[:straight] if is_straight[hand]

  return SCORES[:three_of_a_kind] if hand in [
    *, Card[*, r], Card[*, ^r], Card[*, ^r], *
  ]

  # Similar issue with :two_pair as with :full_house:

  return SCORES[:two_pair] if hand in [
    *, Card[*, r1], Card[*, ^r1], Card[*, r2], Card[*, ^r2], *
  ]

  return SCORES[:two_pair] if hand in [
    Card[*, r1], Card[*, ^r1], *, Card[*, r2], Card[*, ^r2]
  ]

  return SCORES[:one_pair] if hand in [
    *, Card[*, r], Card[*, ^r], *
  ]

  SCORES[:high_card]
end
