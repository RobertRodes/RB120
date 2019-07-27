require_relative 'deck'
require 'pry'
class PokerGame
  HAND_TYPES = {
    'Royal flush' => 9,
    'Straight flush' => 8,
    'Four of a kind' => 7,
    'Full house' => 6,
    'Flush' => 5,
    'Straight' => 4,
    'Three of a kind' => 3,
    'Two pair' => 2,
    'Pair' => 1,
    'High card' => 0
  }.freeze

  attr_reader :hands

  def initialize(deck, num_hands = 2, size_hands = 5)
    @deck = deck
    @hands = deal_hands(num_hands, size_hands)
  end

  def to_s
    @hands.map(&:to_s)
  end

  def deal_hands(num, size)
    hands = []
    num.times { hands << PokerHand.new(@deck, size) }
    hands.each do |hnd|
      hnd.hand.sort! { |a, b| b.value <=> a.value }
    end
  end

  def compare(value_1, value_2)
    case value_1 <=> value_2
    when 1  then return 0
    when -1 then return 1
    end
    nil
  end

  def best_hand_of_seven(hand)
    hands = []
    hand.hand.combination(5).each do |e| 
      hands.push(PokerHand.new(Deck.new(e))) 
    end
    best_hand = hands[0]
    hands.each do |hand|
      better_hnd = better_hand(best_hand, hand)
      next if better_hnd.nil?
      best_hand = better_hnd
    end
    best_hand
  end

  def better_hand(hand_1, hand_2)
    hands = [hand_1, hand_2]
    result = compare(HAND_TYPES[hand_1.evaluate], HAND_TYPES[hand_2.evaluate])
    return hands[result] unless result.nil?

    # Royal flush, straight flush or straight
    if hand_1.straight?
      if hand_1.low_straight? && hand_2.low_straight?
        return nil
      elsif hand_1.low_straight?
        return hands[1]
      elsif hand_2.low_straight?
        return hands[0]
      end
      result = compare(hand_1.values.max, hand_2.values.max)
      return result.nil? ? result : hands[result]
    end

    if hand_1.two_pair?
      result = compare(high_pair(hand_1), high_pair(hand_2))
      return hands[result] unless result.nil?
      result = compare(low_pair(hand_1), low_pair(hand_2))
      return hands[result] unless result.nil?
    end

    # Four of a kind, full house, three of a kind or pair
    if hand_1.rank_count.values.max > 1
      result = compare(max_rank(hand_1), max_rank(hand_2))
      return hands[result] unless result.nil?
    end

    # Flush, high card, tied two pair or tied pair
    result = compare_kickers(hand_1, hand_2)
    result.nil? ? nil: hands[result]
  end

  private

  def compare_kickers(hand_1, hand_2)
    5.times do |i|
      result = compare(hand_1.hand[i].value, hand_2.hand[i].value)
      return result unless result.nil?
    end
    nil  
  end

  def high_pair(hand)
    hand.rank_count.select { |_,v| 2 == v }.max[0]
  end

  def low_pair(hand)
    hand.rank_count.select { |_,v| 2 == v }.min[0]
  end

  def max_rank(hand)
    hand.rank_count.key(hand.rank_count.values.max)
  end
end

class PokerHand
  attr_reader :hand, :rank_count

  def initialize(cards, size_hand = 5)
    @hand = deal_hand(cards, size_hand)
    @rank_count = 
      @hand.map(&:value).group_by { |elt| elt }.map { |k,v| [k, v.size] }.to_h
  end

  def to_s
    @hand.map(&:to_s)
  end

  def deal_hand(cards, size_hand)
    size_hand.times.with_object([]) do |_, arr| 
      arr.push(cards.deal)
    end
  end

  def evaluate
    case
    when royal_flush?     then 'Royal flush'
    when straight_flush?  then 'Straight flush'
    when four_of_a_kind?  then 'Four of a kind'
    when full_house?      then 'Full house'
    when flush?           then 'Flush'
    when straight?        then 'Straight'
    when three_of_a_kind? then 'Three of a kind'
    when two_pair?        then 'Two pair'
    when pair?            then 'Pair'
    else                       'High card'
    end
  end

  def flush?
    1 == suits.uniq.size
  end

  def straight?
    5  == uniq_ranks &&
    4 == @hand.max.value - @hand.min.value ||
    low_straight?
  end

  def low_straight?
    5 == uniq_ranks && 
    ranks.include?('Ace') && 
    28 == @hand.map(&:value).sum
  end

  def two_pair?
    2 == max_count && 3 == uniq_ranks
  end

  def values
    @hand.map(&:value)
  end

  private

  def ranks
    @hand.map(&:rank)
  end

  def suits
    @hand.map(&:suit)
  end

  def max_count
    ranks.group_by { |elt| elt }.values.max_by(&:size).size
  end

  def uniq_ranks
    ranks.uniq.size
  end

  def royal_flush?
    flush? && straight? && 10 == @hand.min.value 
  end

  def straight_flush?
    flush? && straight?
  end

  def four_of_a_kind?
    4 == max_count
  end

  def full_house?
    3 == max_count && 2 == uniq_ranks
  end

  def three_of_a_kind?
    3 == max_count && 3 == uniq_ranks
  end

  def pair?
    4 == uniq_ranks
  end
end

cards = [
  Card.new(7, 'Hearts'),
  Card.new(7, 'Clubs'),
  Card.new(6, 'Diamonds'),
  Card.new(8, 'Spades'),
  Card.new(6, 'Hearts'),
  Card.new(9, 'Spades'),
  Card.new(9, 'Diamonds')
]

game = PokerGame.new(Deck.new, 1, 7)
puts game.hands.first.to_s
puts
puts game.best_hand_of_seven(game.hands.first).to_s

# cards = [
#   Card.new('Queen', 'Hearts'),
#   Card.new(2, 'Clubs'),
#   Card.new(9, 'Diamonds'),
#   Card.new(6, 'Spades'),
#   Card.new(10, 'Hearts'),
#   Card.new(6, 'Hearts'),
#   Card.new('King', 'Clubs'),
#   Card.new(5, 'Diamonds'),
#   Card.new(8, 'Spades'),
#   Card.new(2, 'Hearts')
# ]

game = PokerGame.new(Deck.new(cards))
# puts
# game.hands.map(&:to_s).each { |e| puts e, ''}
# result = game.better_hand(game.hands[0], game.hands[1])
# puts result.nil? ? 'Tied hands.' : result.hand.map(&:to_s)

