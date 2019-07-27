class Card
  include Comparable
  attr_reader :rank, :suit

  VALUES = { 'Jack' => 11, 'Queen' => 12, 'King' => 13, 'Ace' => 14 }

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def value
    VALUES.fetch(rank, rank)
  end

  def <=>(other_card)
    value <=> other_card.value
  end
end

class Deck
  RANKS = ((2..10).to_a + %w(Jack Queen King Ace)).freeze
  SUITS = %w(Hearts Clubs Diamonds Spades).freeze

  def initialize(cards = nil)
    @deck = cards.nil? ? new_deck : cards
  end

  def deal(count = 1)
    return @deck.pop if 1 == count
    count.times.with_object([]) { |_, arr| arr.push(@deck.pop) }
  end

  def draw
    new_deck if @deck.empty?
    the_card = @deck.sample
    @deck.delete_if do |card|
      card.rank == the_card.rank && card.suit == the_card.suit 
    end
    the_card
  end

  def new_deck
    RANKS.product(SUITS).shuffle.map do |rank, suit| 
      Card.new(rank, suit)
    end
  end
end

# deck = Deck.new
# drawn = []
# 52.times { drawn << deck.draw }
# puts drawn.count { |card| card.rank == 5 } == 4
# puts drawn.count { |card| card.suit == 'Hearts' } == 13

# drawn2 = []
# 52.times { drawn2 << deck.draw }
# puts drawn != drawn2 # Almost always.