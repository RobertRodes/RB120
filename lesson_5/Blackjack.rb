# Application-wide constants
module App
  BUST_VALUE = 21
  DEALER_STAND_VALUE = 17
  SCREEN_WIDTH = 60
  HEADER = "\n#{'General Rodes Black Jack'.center(SCREEN_WIDTH)}\n\n"
  SLEEP_TIME = 1 # How long to wait between dealer cards dealt, etc.
end

module Utilities
  require 'io/console'

  KEY_ONLY = true # Key + enter or key only

  def getchar
    if KEY_ONLY
      char = STDIN.getch
      if char == "\u0003" # Ctrl-C
        puts
        exit
      end
    else
      char = gets.chomp[0]
    end
    char
  end

  def cls
    system('clear') || system('cls')
  end

  def say(message, new_lines = 0)
    print message.to_s
    print "\n" * new_lines
  end

  # This disables keyboard input while #sleep is running. Necessary in
  # key_only mode because otherwise key inputs will echo on the screen.
  def wait(for_time)
    system('stty raw -echo')
    sleep for_time
    system('stty -raw echo')
  end

  # Assumes "space plus \n\n" for new paragraph.
  def word_wrap(str, width = App::SCREEN_WIDTH)
    char_count = 0
    lastchar = str.end_with?(' ') ? ' ' : ''
    str.split(/ /).each do |word|
      char_count += word.size + 1
      if char_count > width
        word.prepend("\n") unless word.start_with?("\n\n")
        char_count = word.size + 1
      end
      char_count = word.size - 1 if word.include?("\n\n")
    end.join(' ') << lastchar
  end
end

class Deck
  # Used for calculating score
  CARD_VALUES = {
    '2'  => 2,
    '3'  => 3,
    '4'  => 4,
    '5'  => 5,
    '6'  => 6,
    '7'  => 7,
    '8'  => 8,
    '9'  => 9,
    '10' => 10,
    'J'  => 10,
    'Q'  => 10,
    'K'  => 10,
    'A'  => 11
  }.freeze

  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A).freeze

  # UTF codes for suit symbols
  SUITS = ["\u2660", "\u2661", "\u2662", "\u2663"].freeze

  attr_reader :cards

  def initialize
    new_deck
  end

  def new_deck
    @cards = RANKS.product(SUITS).shuffle
  end
end

# This is equivalent to "Participant" in the reference. I opted for "Gambler"
# for the player.
class Player
  include Utilities
  attr_reader :hand, :score

  def initialize(deck)
    @deck = deck
  end

  def new_hand
    @hand = []
    2.times { hit }
    calc_score
  end

  def calc_score
    total = 0

    hand.each do |card|
      total += Deck::CARD_VALUES[card[0]]
    end

    aces = hand.count { |a| a[0] == 'A' }
    while total > App::BUST_VALUE && aces > 0
      total -= 10
      aces -= 1
    end

    @score = total
  end

  private

  def hit
    @hand.push(@deck.cards.pop)
  end
end

class Gambler < Player
  attr_accessor :cash
  attr_reader :name

  def initialize(deck, cash)
    super(deck)
    @cash = cash
    @name = choose_name
  end

  def turn(table)
    loop do
      play = play_decision

      if play == 'h'
        hit
        calc_score
        table.show
      end

      break if score > App::BUST_VALUE || play == 's'
    end
  end

  private

  def choose_name
    first_time = true
    the_name = ''
    cls
    welcome = "\nWelcome to General Rodes Black Jack! "
    loop do
      say word_wrap("#{first_time ? welcome + 'W' : 'So, w'}hat's your name? ")
      the_name = gets.chomp
      break unless the_name.delete(' ').empty?
      first_time = false
      say word_wrap("Sorry, only The Man With No Name is allowed to play " \
        "without a name. "), 1
    end
    puts
    the_name.split.map(&:capitalize).join(' ')
  end

  def play_decision
    loop do
      say 'Hit or stand (H or S)? '
      play = getchar.downcase
      return play if 'hs'.chars.include?(play)
      say "\nInvalid value. Please try again.", 1
    end
  end
end

class Dealer < Player
  attr_accessor :hide_hand

  def initialize(deck)
    super
    @hide_hand = true
  end

  def turn(table)
    @hide_hand = false
    wait App::SLEEP_TIME

    loop do
      table.show
      wait App::SLEEP_TIME
      break if score >= App::DEALER_STAND_VALUE
      hit
      calc_score
    end
  end
end

# Displays the table. The table shows the header, the player's and dealer's
# hands, the scores, and the player's cash.
class Table
  include Utilities

  def initialize(dealer, gambler)
    @dealer = dealer
    @gambler = gambler
  end

  def show
    cls
    print "#{App::HEADER}" \
          "#{'Dealer'.center(App::SCREEN_WIDTH)}\n" \
          "#{create_hand_view(@dealer).center(App::SCREEN_WIDTH)}\n\n" \
          "#{Deck::SUITS.join('    ').center(App::SCREEN_WIDTH)}\n\n" \
          "#{create_hand_view(@gambler).center(App::SCREEN_WIDTH)}\n" \
          "#{@gambler.name.center(App::SCREEN_WIDTH)}\n\n" \
          "Player score: #{@gambler.score}\n" \
          "Dealer score: #{@dealer.hide_hand ? '??' : @dealer.score}\n\n" \
          "Player cash:  $#{@gambler.cash}\n\n"
  end

  private

  def create_hand_view(player)
    return player.hand[0].join if player.class == Dealer && player.hide_hand
    hand_view = ''
    player.hand.each_with_index do |card, i|
      hand_view << card.join
      hand_view << '  ' unless i + 1 == player.hand.size
    end
    hand_view
  end
end

# Handles a single round of play, from dealing the hands to figuring the result.
class Round
  include Utilities

  NATURAL_YES = 'Got one!'
  NATURAL_NO = 'Not this time.'

  attr_reader :result

  def initialize(dealer, gambler, table)
    @dealer = dealer
    @gambler = gambler
    @table = table
    @result = nil
  end

  def play
    @gambler.new_hand
    @dealer.new_hand
    @table.show
    dealer_check_natural
    @table.show
    @result = calc_natural_result
    return unless @result.nil?
    @gambler.turn(@table)
    @result = calc_result
    return unless @result.nil?
    @dealer.turn(@table)
    @result = calc_result
  end

  private

  def calc_natural_result
    return :natural_push    if @dealer.score == App::BUST_VALUE &&
                               @gambler.score == App::BUST_VALUE
    return :dealer_natural  if @dealer.score == App::BUST_VALUE
    return :gambler_natural if @gambler.score == App::BUST_VALUE
    nil
  end

  def calc_result
    return :gambler_bust if @gambler.score > App::BUST_VALUE
    return nil if @dealer.hide_hand
    return :dealer_bust if @dealer.score > App::BUST_VALUE
    case @gambler.score <=> @dealer.score
    when 1
      :gambler
    when -1
      :dealer
    else
      :push
    end
  end

  def dealer_check_natural
    return unless Deck::CARD_VALUES[@dealer.hand[0][0]] >= 10
    print word_wrap("Dealer is checking for a natural #{App::BUST_VALUE} ... ")
    wait App::SLEEP_TIME
    print "#{@dealer.score == App::BUST_VALUE ? NATURAL_YES : NATURAL_NO}\n"
    wait App::SLEEP_TIME
  end
end

class BlackJack
  include Utilities

  BET = 1
  NATURAL_MULTIPLIER = 10

  APPLY_BET = {
    gambler_natural: BET * NATURAL_MULTIPLIER,
    dealer_bust:     BET,
    gambler:         BET,
    natural_push:    0,
    push:            0,
    dealer:          -BET,
    gambler_bust:    -BET,
    dealer_natural:  -BET
  }.freeze

  GAMBLER_STAKE = 50

  HAND_RESULT_PROMPT = {
    gambler_natural: "Player holds a natural #{App::BUST_VALUE}! Player " \
                     "wins $#{APPLY_BET[:gambler_natural]}.",
    dealer_bust:     'Dealer busted. Player wins.',
    gambler:         'Player wins.',
    natural_push:    "Dealer and player both hold a natural " \
                     "#{App::BUST_VALUE}! That's a push.",
    push:            'Push.',
    dealer:          'Dealer wins.',
    gambler_bust:    'Player busted. Dealer wins.',
    dealer_natural:  "Dealer holds a natural #{App::BUST_VALUE}. Dealer wins."
  }.freeze

  # Increasing App::BUST_VALUE requires that NEW_DECK_COUNT be increased as
  # well. To avoid the possibility of an error from trying to deal from an
  # empty deck, NEW_DECK_COUNT has to be at least as high as the maximum
  # possible number of cards for both hands.
  NEW_DECK_COUNT = 18

  SPACE = ' '

  def initialize
    @deck = Deck.new
    @dealer = Dealer.new(@deck)
    @gambler = Gambler.new(@deck, GAMBLER_STAKE)
    @table = Table.new(@dealer, @gambler)
  end

  def play
    show_opening_screen
    loop do
      round = Round.new(@dealer, @gambler, @table)
      round.play
      @dealer.hide_hand = false
      @gambler.cash += APPLY_BET[round.result]
      @table.show
      say HAND_RESULT_PROMPT[round.result], 2
      break unless play_again?
      reset
    end
    show_closing_screen
  end

  private

  def closing_screen_message
    <<~BLOCK
      Thank you for playing at General Rodes Black Jack, \
      #{@gambler.name}!#{SPACE}

      #{closing_screen_message_which}
    BLOCK
  end

  def closing_screen_message_which
    case @gambler.cash <=> GAMBLER_STAKE
    when -1 then  closing_screen_message_lose
    when  1 then  closing_screen_message_win
    else          "You have broken even. Oh well, maybe next time.\n"
    end
  end

  def closing_screen_message_lose
    <<~BLOCK
      You have lost $#{GAMBLER_STAKE - @gambler.cash}.#{SPACE}

      But not to worry. Just spend a year washing dishes in our kitchen and \
      we'll call it even.#{SPACE}

      See you tomorrow at 5 a.m. Don't be late!#{SPACE}
    BLOCK
  end

  def closing_screen_message_win
    <<~BLOCK
      You have won $#{@gambler.cash - GAMBLER_STAKE}. We'll be keeping the \
      money, of course. After all, it was ours to begin with.#{SPACE}

      Stop back and see us again!#{SPACE}
    BLOCK
  end

  def opening_screen_message
    <<~BLOCK
      Welcome #{@gambler.name}!

      You have been awarded a gambling spree at General Rodes Black Jack, \
      our favorite casino!#{SPACE}

      Black Jack is the game we play ... sort of. No doubling down, and no \
      splitting pairs.#{SPACE}

      You have $#{GAMBLER_STAKE} to play with. Bet is $#{BET} per hand.#{SPACE}

      Black Jack (natural #{App::BUST_VALUE}) pays #{NATURAL_MULTIPLIER} \
      to 1. Good luck!#{SPACE}

      Please hit #{KEY_ONLY ? 'any key' : '"Enter"'} when you are ready to \
      begin:#{SPACE}
    BLOCK
  end

  def play_again?
    say word_wrap("Please #{KEY_ONLY ? 'hit' : 'enter'} Q to quit, or " \
    'anything else to play again: ')
    char = getchar
    print "\n"
    return false if !char.nil? && char.casecmp('q').zero?
    true
  end

  def reset
    @dealer.hide_hand = true
    return if @deck.cards.count > NEW_DECK_COUNT
    say 'Reshuffling ... ', 1
    wait App::SLEEP_TIME * 2
    @deck.new_deck
  end

  def show_closing_screen
    cls
    print App::HEADER
    print word_wrap(closing_screen_message)
    print "Please hit #{KEY_ONLY ? 'any key' : '"Enter"'} to leave ... "
    getchar
    print "Bye now.\n\n"
  end

  def show_opening_screen
    cls
    print App::HEADER
    print word_wrap(opening_screen_message)
    getchar
  end
end

game = BlackJack.new
game.play
