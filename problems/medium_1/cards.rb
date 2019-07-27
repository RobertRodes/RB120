class Array
  def min
    if self[0].class == Card
      self.min_by { |card| card.rank_number }
    else
      super
    end
  end

  def max
    if self[0].class == Card
      self.max_by { |card| card.rank_number }
    else
      super
    end
  end
end

class Card
  RANKS = {
    Two:    2,
    Three:  3,
    Four:   4,
    Five:   5,
    Six:    6,
    Seven:  7,
    Eight:  8,
    Nine:   9,
    Ten:   10,
    Jack:  11,
    Queen: 12,
    King:  13,
    Ace:   14
  }.freeze

  SUITS = ['Hearts', 'Clubs', 'Spades', 'Diamonds'].freeze

  attr_reader :suit

  def initialize(rank, suit)
    @rank = assign_rank(rank)
    @suit = suit
  end

  def ==(other_card)
    @rank == other_card.rank_number
  end

  def rank
    return @rank if @rank < 11
    RANKS.key(@rank).to_s
  end

  def rank_number
    @rank
  end

  def to_s
    "#{RANKS.key(@rank).to_s} of #{@suit}"
  end

  private

  def assign_rank(rank)
    return rank if RANKS.values.include?(rank)
    raise ArgumentError.new("invalid rank value '#{rank}'") unless 
      RANKS.has_key?(rank.to_sym)
    RANKS[rank.to_sym]
  end

  def assign_suit(suit)
    return suit if SUITS.include?(suit)
    raise ArgumentError.new("invalid suit value '#{suit}'")
  end
end

cards = [Card.new(2, 'Hearts'),
         Card.new(10, 'Diamonds'),
         Card.new('Ace', 'Clubs')]
puts cards
puts cards.min == Card.new(2, 'Hearts')
puts cards.max == Card.new('Ace', 'Clubs')

cards = [Card.new(5, 'Hearts')]
puts cards.min == Card.new(5, 'Hearts')
puts cards.max == Card.new(5, 'Hearts')

cards = [Card.new(4, 'Hearts'),
         Card.new(4, 'Diamonds'),
         Card.new(10, 'Clubs')]
puts cards.min.rank == 4
puts cards.max == Card.new(10, 'Clubs')
puts cards.min.rank == 4
puts cards.max == Card.new(10, 'Clubs')

cards = [Card.new(7, 'Diamonds'),
         Card.new('Jack', 'Diamonds'),
         Card.new('Jack', 'Spades')]
puts cards.min == Card.new(7, 'Diamonds')
puts cards.max.rank == 'Jack'

cards = [Card.new(8, 'Diamonds'),
         Card.new(8, 'Clubs'),
         Card.new(8, 'Spades')]
puts cards.min.rank == 8
puts cards.max.rank == 8
