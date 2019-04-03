# RPS 1.0
# I wrote an implementation of this without looking at Chris's videos, to 
# see what I came up with. My original version had this rather more 
# streamlined way of determining the winner than the one Chris used in his 
# initial version, so I opted to keep it in v1.0 rather than abstracting 
# the Move process into its own class. The means used here is to use a 
# constant with an array of sub-arrays, each sub-array containing one of 
# the three winner-loser combinations. It works fine here, but doesn't 
# scale particularly well. The next version (1.1) uses Chris's Move class.

class Player
  MOVES = %w(rock paper scissors).freeze
  attr_accessor :move, :name

  def initialize
    @name = set_name
  end
end

class Human < Player
  def choose
    char = nil
    loop do
      print 'Pick rock, paper or scissors (R, P or S): '
      char = gets.chomp.downcase
      break if %w(r p s).include?(char)
      puts "Invalid choice. Please enter R, P or S."
    end
    self.move = MOVES.find { |word| word[0] == char }
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
  def choose
    self.move = MOVES.sample
  end

  private

  def set_name
    %w(R2D2 C-3PO Chappie HAL Wall-E).sample
  end
end

class RPSGame
  WINS = [%w(paper rock), %w(rock scissors), %w(scissors paper)]
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_goodbye_message
    puts 'Thanks for playing. Goodbye!'
  end

  def display_welcome_message
    puts "Hello, #{human.name}. My name is #{computer.name}."
    puts 'Welcome to Rock, Paper, Scissors.'
  end

  def display_winner
    # Assigning often-accessed object attributes to variables and
    # then accessing to the variables instead reduces the ABC size.
    h_move = human.move
    c_move = computer.move
    puts "#{human.name}, you chose #{h_move}."
    puts "I chose #{c_move}."
    if c_move == h_move then puts "It's a tie."
    elsif WINS.include?([h_move, c_move])
      puts "You won, #{human.name}!"
    else puts "And the great #{computer.name} wins!"
    end
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end

  private

  def play_again?
    print 'Play again (Y to play, any other key to quit)? '
    return true if 'y' == gets.chomp.downcase
    false
  end
end

RPSGame.new.play
