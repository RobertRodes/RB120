# RPSLS 1.0
# Expansion of RPS 1.1
# Implements additional Lizard-Spock game rules

class Move
  VALUES = %w(rock paper scissors lizard spock).freeze
  # WINS constant added back in from RPS 1.0, (as a hash this time)
  # with the extra game rules.
  WINS = {
    rock:     %w(scissors lizard),
    paper:    %w(rock spock),
    scissors: %w(paper lizard),
    lizard:   %w(spock paper),
    spock:    %w(rock scissors)
  }.freeze
  attr_reader :value

  def initialize(value)
    @value = value
  end

  # This implementation of #beats?, which expands the implementation of v1.1
  # to include lizard and Spock choices, demonstrates the lack of scalability
  # of this approach to determining the winner. ABC, cyclomatic and perceived
  # complexity are all too high here. Breaking the possible moves up into
  # their own classes is one way to resolve this, which I will do in the next
  # version.
  #
  # Meanwhile, this version reverts to an implementation similar to the one
  # in RPS 1.0, looking up the winning moves in a hash (a hash this time
  # instead of an array). Although it can hardly be considered an OO solution,
  # it does implement the requirement, and in a significantly simpler way than
  # the OO alternative. That said, it isn't particularly flexible; for example,
  # it doesn't make it easy to display a line of text explaining why the
  # winning move is the winning move (one of the enhancements I'm planning for
  # the next version).
  #
  # def beats?(other_move)
  #   rock? && (other_move.scissors? || other_move.lizard?) ||
  #     paper?    && (other_move.rock?     || other_move.spock?)   ||
  #     scissors? && (other_move.paper?    || other_move.lizard?)  ||
  #     lizard?   && (other_move.spock?    || other_move.paper?)   ||
  #     spock?    && (other_move.rock?     || other_move.scissors?)
  # end

  # def rock?
  #   @value == 'rock'
  # end

  # def paper?
  #   @value == 'paper'
  # end

  # def scissors?
  #   @value == 'scissors'
  # end

  # def lizard?
  #   @value == 'lizard'
  # end

  # def spock?
  #   @value == 'spock'
  # end

  def beats?(other_move)
    WINS[@value.to_sym].include?(other_move.to_s)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :name, :wins

  def initialize
    @name = set_name
    @wins = 0
  end
end

class Human < Player
  attr_accessor :move

  def choose
    choice = nil
    loop do
      print 'Enter rock, paper, scissors, lizard or Spock ' \
            '(or R, P, S, L or K): '
      choice = find_choice(gets.chomp.downcase)
      break unless choice.nil?
      puts 'Invalid choice.'
    end
    self.move = Move.new(choice)
  end

  private

  def find_choice(choice)
    return 'spock' if choice == 'k'
    Move::VALUES.find { |word| (1 == choice.size ? word[0] : word) == choice }
  end

  def set_name
    n = ''
    loop do
      print "What's your name? "
      n = gets.chomp
      break unless n.empty?
      print "C'mon. You can tell me. "
    end
    n.capitalize
  end
end

class Computer < Player
  attr_accessor :move

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end

  private

  def set_name
    %w(R2D2 C-3PO Chappie HAL Wall-E).sample
  end
end

class Display
  def initialize(human, computer)
    @human = human
    @computer = computer
  end

  def final_winner(who_won)
    if who_won == :computer
      puts "Game over ... And the great #{computer.name} wins!"
    else
      puts "Game over ... You win, #{human.name}. Well played."
    end
  end

  def goodbye_message
    puts 'Thanks for playing. Goodbye!'
  end

  def new_game
    puts "Hello, #{human.name}. My name is #{computer.name}."
  end

  def welcome_message
    puts "Hello, #{human.name}. My name is #{computer.name}."
    puts 'Welcome to Rock, Paper, Scissors.'
  end

  def winner(who_won)
    show_moves
    case who_won
    when :computer then puts "That's one for me."
    when :human then puts "One for you, #{human.name}."
    else puts "It's a tie."
    end
    show_score
  end

  private

  attr_reader :human, :computer

  def show_moves
    puts "#{human.name}, you chose #{human.move}."
    puts "I chose #{computer.move}."
  end

  def show_score
    puts "Score: #{computer.name} #{computer.wins} #{human.name} #{human.wins}"
  end
end

class RPSGame
  WINS = [%w(paper rock), %w(rock scissors), %w(scissors paper)].freeze
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
    @display = Display.new(@human, @computer)
  end

  def play(first_game = true)
    if first_game then display.welcome_message
    else reset_game
    end

    @games = input_game_count
    play_games
    display.final_winner(computer.wins == @games ? :computer : :human)

    if play_again? then play(false)
    else display.goodbye_message
    end
  end

  private

  attr_accessor :games
  attr_reader :display

  def input_game_count
    loop do
      puts 'Winner is first one to how many games (1-25)?'
      games = gets.chomp.to_i
      return games if games.between?(1, 25)
      puts 'Invalid number.'
    end
  end

  def play_again?
    print 'Play again (Y to play, any other key to quit)? '
    return true if gets.chomp.casecmp('y').zero?
    false
  end

  def play_games
    while computer.wins < @games && human.wins < @games
      human.choose
      computer.choose
      display.winner(process_winner)
    end
  end

  def process_winner
    h_move = human.move
    c_move = computer.move
    if h_move.beats?(c_move)
      human.wins += 1
      return :human
    elsif c_move.beats?(h_move)
      computer.wins += 1
      return :computer
    end
    :tie
  end

  def reset_game
    human.wins = 0
    @computer = Computer.new
    @display = Display.new(@human, @computer)
    display.new_game
  end
end

RPSGame.new.play
