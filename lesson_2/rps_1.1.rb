# Rock, Paper, Scissors v.1.1
# Added Move class, removed WINS constant
#   I didn't handle the move class quite the way Chris did. While I found his
#   demonstration of overloading the > and < methods very interesting, I
#   thought it would be simpler to use a single #beats? method instead.
# Pulled display logic into its own Display class
# Implemented multi-game functionality

class Move
  VALUES = %w(rock paper scissors).freeze
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def beats?(other_move)
    rock? && other_move.scissors? ||
      paper? && other_move.rock? ||
      scissors? && other_move.paper?
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
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
      print 'Enter rock, paper or scissors (or R, P or S): '
      choice = gets.chomp.downcase
      break if Move::VALUES.include?(choice) || Move::VALUES.include?(
        choice = Move::VALUES.find { |word| word[0] == choice }
      )
      puts 'Invalid choice.'
    end
    self.move = Move.new(choice)
  end

  private

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
