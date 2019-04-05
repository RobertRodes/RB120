# RPSLS 1.1
# Adds the five moves as Move subclasses

# Move classes
class Move
  include ObjectSpace

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def beats?(other_move)
    wins.include?(other_move.class)
  end

  def to_s
    self.class.name
  end
end

class Rock < Move
  def self.name
    'rock'
  end

  attr_reader :wins, :win_text

  def initialize
    @wins = [Scissors, Lizard]
    @win_text = {
      Scissors => 'Rock smashes scissors.',
      Lizard => 'Rock crushes lizard.'
    }
  end
end

class Paper < Move
  def self.name
    'paper'
  end

  attr_reader :wins, :win_text

  def initialize
    @wins = [Rock, Spock]
    @win_text = {
      Rock => 'Paper covers rock.',
      Spock => 'Paper refutes Spock.'
    }
  end
end

class Scissors < Move
  def self.name
    'scissors'
  end

  attr_reader :wins, :win_text

  def initialize
    @wins = [Paper, Lizard]
    @win_text = {
      Paper => 'Scissors cuts paper.',
      Lizard => 'Scissors decapitates lizard.'
    }
  end
end

class Lizard < Move
  def self.name
    'lizard'
  end

  attr_reader :wins, :win_text

  def initialize
    @wins = [Paper, Spock]
    @win_text = {
      Paper => 'Lizard eats paper.',
      Spock => 'Lizard poisons Spock.'
    }
  end
end

class Spock < Move
  def self.name
    'Spock'
  end

  attr_reader :wins, :win_text

  def initialize
    @wins = [Rock, Scissors]
    @win_text = {
      Rock => 'Spock vaporizes rock.',
      Scissors => 'Spock crushes scissors.'
    }
  end
end

# Player classes
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
      choice = find_move_name(gets.chomp.downcase)
      break unless choice.nil?
      puts 'Invalid choice.'
    end
    self.move = Move.descendants.find { |klass| klass.name == choice }.new
  end

  private

  def find_move_name(choice)
    return 'Spock' if %w(k spock).include?(choice)
    %w(rock paper scissors lizard).find do |word|
      (1 == choice.size ? word[0] : word) == choice
    end
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
    self.move = Move.descendants.sample.new
  end

  private

  def set_name
    %w(R2D2 C-3PO Chappie HAL Wall-E).sample
  end
end

# Display class
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

  def winner(who_won, win_text)
    show_moves
    case who_won
    when :computer then print "#{win_text}\nThat's one for me.\n"
    when :human then print "#{win_text}\nOne for you, #{human.name}.\n"
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

# Main game class

class RPSGame
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

  def find_win_text(winner)
    h_move = human.move
    c_move = computer.move
    if winner == :human
      h_move.win_text[c_move.class]
    else
      c_move.win_text[h_move.class]
    end
  end

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
      winner = process_winner
      display.winner(winner, find_win_text(winner))
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
