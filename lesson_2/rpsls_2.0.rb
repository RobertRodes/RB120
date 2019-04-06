# RPSLS 2.0
# All extra features implemented

# Utilities module. Contains a constant with written numbers, a prompt that
# allows user input to be typed on the same line, and a #wait method that
# synchronizes #sleep with #gets, by clearing the input buffer while the
# #sleep method is running.
module Utilities
  require 'io/console'

  WRITTEN_NUMBERS = {
    1  => 'one',
    2  => 'two',
    3  => 'three',
    4  => 'four',
    5  => 'five',
    6  => 'six',
    7  => 'seven',
    8  => 'eight',
    9  => 'nine'
  }.freeze

  def prompt(message, newline = true)
    print message.to_s
    print "\n" if newline
  end

  def wait(for_time)
    if RUBY_PLATFORM =~ /win32/ then STDOUT.echo = false
    else system('stty raw -echo')
    end
    sleep for_time
    STDIN.ioflush
    if RUBY_PLATFORM =~ /win32/ then STDOUT.echo = true
    else system('stty -raw echo')
    end
  end
end

# Move classes. Move has five subclasses, one each for Rock, Paper, Scissors
# Lizard and Spock. This allows more flexibiity in customizing move-specific
# data. In particular, subclassing the moves made it easier to keep track of
# which moves beat which, and to store strings that explain why a given move
# beats another.
#
# The move class also handles the move history directly. I thought about
# abstracting this functionality into a separate History class, and
# subclassing ComputerHistory from it, but I decided against it. My reasons
# for doing so are first, that although they both involve keeping history of
# the game moves, they do so for unrelated reasons. The Move history is about
# displaying a table of the moves in a game so far, while the ComputerHistory
# class is about keeping track of computer wins and losses to support some of
# the player-specific choice algorithms. Second, the fact that there is only
# one move history in the game suggests that abstracting out the History
# class is unnecessary. (One could argue the same for the ComputerHistory
# class, and it is certainly an option to fold that functionality into the
# computer class. But that class was getting big enough, at 50 lines of code
# or so, to be unwieldy, so I opted to separate the class out.) Finally, I
# wanted to get some practice at implementing class-level functionality.
class Move
  @history = []
  @move_count = 0

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  class << self
    attr_reader :history
  end

  def self.reset_history
    @history = []
    @move_count = 0
  end

  def self.update_history(human_move, computer_move, result)
    @move_count += 1
    @history << [
      @move_count,
      human_move.class.to_s,
      computer_move.class.to_s,
      result
    ]
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
      Scissors => 'Rock smashes scissors',
      Lizard => 'Rock crushes lizard'
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
      Rock => 'Paper covers rock',
      Spock => 'Paper refutes Spock'
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
      Paper => 'Scissors cuts paper',
      Lizard => 'Scissors decapitates lizard'
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
      Paper => 'Lizard eats paper',
      Spock => 'Lizard poisons Spock'
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
      Rock => 'Spock vaporizes rock',
      Scissors => 'Spock crushes scissors'
    }
  end
end

# Player classes. Player is subclassed into Human and Computer. Since
# the behaviors and state of these two diverge widely, most of the
# implementation is in the two subclasses. However, it still makes
# sense to subclass them from Player, since they both share the
# name and wins attributes.
class Player
  attr_accessor :name, :wins

  def initialize
    @name = set_name
    @wins = 0
  end
end

class Human < Player
  include Utilities

  attr_accessor :move

  def choose
    choice = nil
    loop do
      prompt 'Enter rock, paper, scissors, lizard or Spock ' \
            '(or R, P, S, L or K): ', false
      choice = find_move_name(gets.chomp.downcase)
      break unless choice.nil?
      prompt 'Invalid choice.'
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

  def input_name(first_time)
    the_name = ''
    loop do
      prompt "#{first_time ? 'Hello. W' : 'So, w'}hat's your name? ", false
      the_name = gets.chomp
      break unless the_name.delete(' ').empty?
      first_time = false
      prompt "I'll tell you mine if you'll tell me yours. "
    end
    puts
    the_name.split.map(&:capitalize).join(' ')
  end

  def set_name
    puts
    input_name(true)
  end
end

class Computer < Player
  COMPUTERS = {
    animate: 'C-3PO',
    fewest_losses: 'R2-D2',
    inanimate: 'Chappie',
    random: 'HAL',
    top_winners: 'Wall-E'
  }.freeze

  attr_accessor :move
  attr_reader :history

  def initialize(last_player = nil)
    # prevent the same computer being selected twice in a row.
    @names = COMPUTERS.values
    @names.delete(last_player)
    super()
    @history = ComputerHistory.new
  end

  def choose
    self.move = send(COMPUTERS.key(name)).sample.new
  end

  private

  def animate
    [Lizard, Spock]
  end

  def fewest_losses
    min_val = history.list.values.map(&:last).min
    history.list.select { |_, val| val[1] == min_val }.keys
  end

  def inanimate
    [Rock, Paper, Scissors]
  end

  def random
    history.list.keys
  end

  def set_name
    @names.sample
  end

  # All moves with (wins - losses).max
  def top_winners
    max_val = history.list.values.map { |ary| ary.reduce(:-) }.max
    history.list.select { |_, val| val.reduce(:-) == max_val }.keys
  end
end

# Display class. Handles (nearly) all aspects of screen display. The exception
# is in methods that get user input: human name, number of wins, individual
# game moves, and play again logic. I wanted to restrict the behavior of this
# class entirely to displaying stuff on the screen.
class Display
  include Utilities

  def initialize(human, computer)
    @human = human
    @computer = computer
  end

  def final_winner(winner)
    if winner.class == Human
      prompt "Game over ... You win, #{winner.name}. Well played."
    else
      prompt "Game over ... And I, #{winner.name}, win!"
    end
  end

  def goodbye_message
    prompt "Thanks for playing, #{human.name}. Goodbye!"
    puts
  end

  def new_game
    prompt "Hello, #{human.name}. My name is #{computer.name}. " \
           "I'll be playing you this time."
    puts
  end

  def welcome_message
    prompt 'Welcome to Rock, Paper, Scissors, Lizard, Spock, ' \
           "#{human.name}. My name is #{computer.name}."
    puts
  end

  def winner(winner)
    puts
    show_moves
    show_winner(winner)
    puts
    show_move_history
    puts
    show_score
    puts
    wait 0.5
  end

  private

  attr_reader :human, :computer

  def calc_computer_col_size
    [
      Move.history.map { |ary| ary[2] }.max_by(&:size).size,
      computer.name.size
    ].max
  end

  def calc_human_col_size
    [
      Move.history.map { |ary| ary[1] }.max_by(&:size).size,
      human.name.size
    ].max
  end

  def calc_result_col_size
    [Move.history.map { |ary| ary[3] }.max_by(&:size).size, 6].max
  end

  def find_win_text(winner)
    h_move = human.move
    c_move = computer.move
    if winner.class == Human
      h_move.win_text[c_move.class]
    else
      c_move.win_text[h_move.class]
    end
  end

  def print_move_history(h_size, c_size)
    Move.history.each do |ary|
      print "#{ary[0].to_s.rjust(4)}    #{ary[1].ljust(h_size)}    " \
            "#{ary[2].ljust(c_size)}    #{ary[3]}\n"
    end
  end

  def print_move_history_header(h_size, c_size, r_size)
    puts
    print "Move    #{human.name.ljust(h_size)}    " \
          "#{computer.name.ljust(c_size)}    Result\n"
    print '-' * (h_size + c_size + r_size + 16) + "\n"
  end

  def show_move_history
    human_col_size    = calc_human_col_size
    computer_col_size = calc_computer_col_size
    result_col_size   = calc_result_col_size

    print_move_history_header(
      human_col_size, computer_col_size, result_col_size
    )
    print_move_history(human_col_size, computer_col_size)
  end

  def show_moves
    prompt "#{human.name}, you chose #{human.move}, " \
           "and I chose #{computer.move}."
  end

  def show_score
    prompt "Score:  #{computer.name} #{computer.wins}  " \
           "#{human.name} #{human.wins}"
  end

  def show_winner(winner)
    win_text = find_win_text(winner)
    case winner
    when Computer then prompt "#{win_text}. One for me."
    when Human    then prompt "#{win_text}. That's one for you, #{human.name}."
    else prompt "It's a tie."
    end
  end
end

# ComputerHistory class. This class stores data about the computer's move
# choices, and whether they were wins or losses. This supports the fewest
# moves and largest win difference algorithms. (See the Computer class.)
class ComputerHistory
  attr_reader :list

  def initialize
    @list = {
      Rock     => [0, 0],
      Paper    => [0, 0],
      Scissors => [0, 0],
      Lizard   => [0, 0],
      Spock    => [0, 0]
    }
  end

  def update(move, idx)
    list[move.class][idx] += 1
  end
end

# Main game class. Handles the game play logic, and manages the flow of
# the game.
class RPSGame
  include Utilities

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
    @display = Display.new(@human, @computer)
  end

  def play(first_game = true)
    play_start(first_game)
    play_games(computer, human)
    play_end
  end

  private

  attr_accessor :games
  attr_reader :display

  def input_game_count
    loop do
      prompt 'Winner is first one to win how many games (1-20)? ', false
      games = gets.chomp.to_i
      if games.between?(1, 20)
        prompt "Ok, #{games < 10 ? WRITTEN_NUMBERS[games] : games} it is. " \
               "Let's get started.\n"
        return games
      end
      prompt 'Invalid number.'
    end
  end

  def play_again?
    prompt 'Play again? (Y or yes to play, any other key to quit): ', false
    yes_or_no = gets.chomp.downcase
    puts
    %w(y yes).include?(yes_or_no)
  end

  def play_end
    display.final_winner(computer.wins == games ? computer : human)
    puts
    if play_again?
      wait 0.5
      play(false)
    else
      display.goodbye_message
    end
  end

  def play_games(computer, human)
    while computer.wins < games && human.wins < games
      human.choose
      computer.choose
      winner = process_winner
      update_history(winner)
      update_computer_history(winner)
      display.winner(winner)
    end
  end

  def play_start(first_game)
    if first_game then display.welcome_message
    else reset_game
    end
    wait 0.5
    @games = input_game_count
    wait 0.5
  end

  def process_winner
    h_move = human.move
    c_move = computer.move
    if h_move.beats?(c_move)
      human.wins += 1
      return human
    elsif c_move.beats?(h_move)
      computer.wins += 1
      return computer
    end
    nil
  end

  def reset_game
    Move.reset_history
    human.wins = 0
    @computer = Computer.new(computer.name)
    @display = Display.new(@human, @computer)
    display.new_game
  end

  def update_computer_history(winner)
    return if winner.nil?
    computer.history.update(computer.move, winner.class == Computer ? 0 : 1)
  end

  def update_history(winner)
    result = winner.nil? ? 'Tie' : winner.name
    Move.update_history(human.move, computer.move, result)
  end
end

RPSGame.new.play
