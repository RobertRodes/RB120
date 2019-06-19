# TTT 1.1 changes
# 1. Removed Constants module. Moved WINNING_LINES to Board, INITIAL_MARKER
#    to Square and UNBEATABLE to Computer.
# 2. Removed Choosable and Displayable modules, moved their contents to the
#    TTTGame class.
# 3. Added a `markers_at` attribute to Board, which takes an array of keys
#    as an argument and returns an array containing the markers at those
#    key positions.
# 4. Rewrote Computer's `find_at_risk_square` and `corner_play` methods to
#    use the `markers_at` attribute.
# 5. Added the CORNERS and NON_CORNERS constants to Computer, which are the
#    keys of the corner squares and non-corner squares (except the center
#    square), respectively.
# 6. Renamed @match_games to @match_wins, since that's what the variable
#    really is (there can be any number of games that end in draws).
# 7. Renamed `choose_number_of_games` to `choose_number_of_wins` for the same
#    reason.
# 8. Added `display_number_of_wins`, which displays the number of wins to 
#    take the match when displaying the board.
# 9. Removed explanatory notes having to do with design decisions.

# TTT 1.1.1 change
# 1. Removed attr_reader for `squares` attribute in Board, and changed all the
#    references to it to reference the @squares instance variable instead.

module Utilities
  require 'io/console'
  def cls
    system('clear') || system('cls')
  end

  def getchar
    char = STDIN.getch
    exit if "\u0003" == char
  end

  def say(message, new_lines = 0)
    print message.to_s
    print "\n" * new_lines
  end
end

class Board
  WINNING_LINES = [
    [1, 2, 3], [4, 5, 6], [7, 8, 9],
    [1, 4, 7], [2, 5, 8], [3, 6, 9],
    [1, 5, 9], [3, 5, 7]
  ]

  # attr_reader :squares

  def initialize
    @squares = {}
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def draw
    print "     |     |\n"      \
          "#{board_line(0)}\n"  \
          "     |     |\n"      \
          "-----+-----+-----\n" \
          "     |     |\n"      \
          "#{board_line(1)}\n"  \
          "     |     |\n"      \
          "-----+-----+-----\n" \
          "     |     |\n"      \
          "#{board_line(2)}\n"  \
          "     |     |\n"
  end

  def full?
    unmarked_keys.empty?
  end

  def markers_at(key_list)
    @squares.slice(*key_list).values.map(&:marker)
  end

  def someone_won?
    !!winning_marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def winning_marker
    WINNING_LINES.each do |line|
      line_squares = @squares.values_at(*line)
      next if line_squares.any?(&:unmarked?)
      markers = line_squares.map(&:marker)
      return markers.first if winner?(markers)
    end
    nil
  end

  private

  def board_line(the_line)
    left_square = the_line * 3 + 1
    "  #{@squares[left_square]}  |"     \
    "  #{@squares[left_square + 1]}  |" \
    "  #{@squares[left_square + 2]}"
  end

  def winner?(markers)
    1 == markers.uniq.count
  end
end

class Square
  INITIAL_MARKER = ' '.freeze

  attr_accessor :marker

  def initialize
    @marker = INITIAL_MARKER
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_accessor :board, :mark, :name

  def initialize(mark, board, name = '')
    @mark = mark
    @board = board
    @name = name
  end
end

class Computer < Player
  UNBEATABLE = true
  CORNERS = [1, 3, 7, 9]
  NON_CORNERS = [2, 4, 6, 8]

  def initialize(mark, board, name, human)
    super(mark, board, name)
    @human = human
  end

  def move
    board[best_move] = mark
  end

  private

  # Take a win if it's there, then block an opponent's win threat, then
  # take the center, then take a corner unless the opponent has selected
  # opposing corners (this can be disabled to allow it as a winning
  # strategy), then take a random square.
  def best_move
    find_at_risk_square(mark)          ||
      find_at_risk_square(@human.mark) ||
      center_square                    ||
      corner_play                      ||
      board.unmarked_keys.sample
  end

  def center_square
    5 if board.unmarked_keys.include?(5)
  end

  # This tactic selects a non-corner square if the human has selected
  # opposing corners for the first two moves, and a corner square if
  # not.
  #
  # This neutralizes a couple of winning tactics that the player
  # who goes first can otherwise do: if player plays 1, computer plays
  # 5, player plays 9, and computer plays a corner square, playing to
  # the remaining corner gives two winners. Also, if player plays 5 and
  # computer plays a non-corner square, then player plays any corner,
  # computer blocks in the opposite corner, and player plays the corner
  # not adjacent to the computer's non-corner play, that will also give
  # two winners.
  #
  # I haven't found a way to beat the computer without disabling this,
  # so I put an UNBEATABLE constant in to make the computer beatable
  # by one of these tactics.
  def corner_play
    return unless UNBEATABLE
    if board.markers_at([1, 9]).all?(@human.mark) ||
       board.markers_at([3, 7]).all?(@human.mark)
      choices = NON_CORNERS
    else
      choices = CORNERS
    end
    selection = board.markers_at(choices).index(Square::INITIAL_MARKER)
    choices[selection] if selection
  end

  def find_at_risk_square(check_which)
    Board::WINNING_LINES.each do |line|
      line_markers = board.markers_at(line)
      if line_markers.count(check_which) == 2
         open_square_index = line_markers.index(Square::INITIAL_MARKER)
        return line[open_square_index] if open_square_index 
      end
    end
    nil
  end
end

class Human < Player
  include Utilities

  def move
    choice = nil
    loop do
      say "Choose a square (#{join_or(board.unmarked_keys)}): "
      choice = gets.chomp.to_i
      break if board.unmarked_keys.include?(choice)
      say 'Invalid choice.', 1
    end
    board[choice] = mark
  end

  private

  def join_or(arr, join_delim = ', ', last_join_word = 'or')
    return arr.join if arr.size <= 1
    last_char = arr.pop.to_s
    arr.join(join_delim) << ' ' << last_join_word << ' ' << last_char
  end
end

class TTTGame
  include Utilities

  CHOOSE_PLAYER = 'choose'.freeze
  CLEAR_SCREEN = true
  COMPUTER_MARKER = 'O'.freeze
  COMPUTER_NAME = 'Wall-E'.freeze
  COMPUTER_PLAYER = 'computer'.freeze
  FIRST_GAME = true
  HUMAN_MARKER = 'X'.freeze
  HUMAN_PLAYER = 'human'.freeze
  # FIRST_TO_MOVE is not in alphabetical order because it has to be declared
  # after HUMAN_PLAYER if we want to be able to assign HUMAN_PLAYER to it.
  FIRST_TO_MOVE = CHOOSE_PLAYER
  NUMBER_TEXT = {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    4 => 'four',
    5 => 'five',
    6 => 'six',
    7 => 'seven',
    8 => 'eight',
    9 => 'nine'
  }.freeze

  attr_reader :board, :human, :computer

  def initialize
    @human = Human.new(HUMAN_MARKER, @board)
    @computer = Computer.new(COMPUTER_MARKER, @board, COMPUTER_NAME, @human)
    @match_wins = nil
    @on_move = nil
    @first_player = nil
    @alternate_starters = nil
    @score = { human: 0, computer: 0 }
  end

  def play
    initial_setup
    loop do
      play_moves
      game_result
      if match_winner?
        display_match_end
        break unless play_again?
        new_match
      else
        break unless keep_playing?
        new_game
      end
      display_new_game_screen
    end
    display_goodbye_message
  end

  private

  ### Player choice methods ###

  def choose_first_alternating_player
    loop do
      say 'Who will start the first game (h/human or c/comp)? '
      case gets.chomp.downcase
      when 'c', 'comp'
        return COMPUTER_PLAYER
      when 'h', 'human'
        return HUMAN_PLAYER
      else
        say "Sorry, I can't recognize your input. Please try again.", 1
      end
    end
  end

  def choose_first_player
    @alternate_starters = false
    loop do
      say 'Who goes first: you, I or switch each game ' \
          '(h/human, c/comp or s/switch)? '
      case gets.chomp.downcase
      when 'c', 'comp'
        return COMPUTER_PLAYER
      when 's', 'switch'
        @alternate_starters = true
        return choose_first_alternating_player
      when 'h', 'human'
        return HUMAN_PLAYER
      else say "Sorry, I can't recognize your input. Please try again.", 1
      end
    end
  end

  def choose_first_to_move
    FIRST_TO_MOVE == CHOOSE_PLAYER ? choose_first_player : FIRST_TO_MOVE
  end

  def choose_human_name
    first_time = true
    the_name = ''
    loop do
      say "#{first_time ? 'W' : 'So, w'}hat's your name? "
      the_name = gets.chomp
      break unless the_name.delete(' ').empty?
      first_time = false
      say "I'll tell you mine if you'll tell me yours. ", 1
    end
    puts
    the_name.split.map(&:capitalize).join(' ')
  end

  def choose_marker(player)
    loop do
      say "#{Human == player.class ? 'Your' : 'My'} marker (A-Z)? "
      the_marker = gets.chomp.upcase
      if !(the_marker =~ /\A[A-Z]\z/)
        say "Give me a single character from A to Z, please.", 1
      elsif player.class == Computer && human.mark == the_marker
        say "You've already chosen #{the_marker} for yourself. Please " \
            "choose something different.", 1
      else return the_marker
      end
    end
  end

  def choose_markers
    say "You are #{HUMAN_MARKER}, and I am #{COMPUTER_MARKER}. " \
        "Would you like to choose different markers (y or yes \n" \
        "to change, any other key to keep them as they are)? "
    if %w(y yes).include?(gets.chomp.downcase)
      human.mark = choose_marker(human)
      computer.mark = choose_marker(computer)
      say "Ok, you are now #{human.mark}, and I am now #{computer.mark}.", 2
    else say "Ok, we'll keep them as they are.", 2
    end
  end

  # An additional feature; why not?
  def choose_number_of_wins
    win_count = nil
    loop do
      say 'First to how many wins takes the match (1-10)? '
      win_count = gets.chomp
      break if win_count =~ /\A([1-9]|10)\z/
      say 'Enter a whole number between one and 10, please.', 1
    end
    win_count = win_count.to_i
    match_wins_text =
      1 == win_count ? 'win' : match_count_text(win_count) + ' wins'
    say "Ok, first #{match_wins_text} takes the match.", 2
    win_count
  end

  ### Display methods ###

  def display_board(clear = false)
    cls if clear
    say "You are #{human.mark}, and I am #{computer.mark}.", 1
    display_number_of_wins
    board.draw
    puts
  end

  def display_goodbye_message
    cls
    puts
    say "Thank you for playing Tic-Tac-Toe, #{human.name}. Goodbye!", 2
  end

  def display_match_end
    winner = {}
    if @score[:computer] == @match_wins
      winner[:subject] = 'I'
      winner[:object] = 'me'
    else
      winner[:subject] = 'You'
      winner[:object] = 'you'
    end
    say "That's #{match_count_text(@match_wins)} win" \
        "#{1 == @match_wins ? '' : 's'} for " \
        "#{winner[:object]}. #{winner[:subject]} win the match!", 2
  end

  def display_new_game_screen
    display_starter(CLEAR_SCREEN)
    display_board
    display_score
  end

  def display_number_of_wins
    say "First #{1 == @match_wins ? 'win' : 'to ' + match_count_text(@match_wins) + ' wins'} takes the match.", 2
  end

  def display_result(winner)
    display_board(CLEAR_SCREEN)
    if winner == human.mark
      say 'You win!', 2
    elsif winner == computer.mark
      say 'I win!', 2
    else
      say "It's a tie.", 2
    end
    display_score
  end

  def display_score
    say "Score: #{human.name}  #{@score[:human]}    " \
        "#{computer.name}  #{@score[:computer]}", 2
  end

  def display_starter(clear_screen = false)
    cls if clear_screen
    if @alternate_starters
      variable_text = @first_player == HUMAN_PLAYER ? 'Your' : "My"
      say "Alternating starters. #{variable_text} turn to go first.", 1
    else
      say "#{@first_player == HUMAN_PLAYER ? 'You' : 'I'} go first.", 1
    end
  end

  def display_starter_initial
    say 'Ok. ' if FIRST_TO_MOVE == CHOOSE_PLAYER
    @alternate_starters ? say('Got it.', 1) : display_starter
  end

  ### Game play methods ###

  def current_player_move
    @on_move == HUMAN_PLAYER ? human.move : computer.move
  end

  def first_move
    computer.move if @first_player == COMPUTER_PLAYER
    @on_move = HUMAN_PLAYER
  end

  def game_result
    winner = board.winning_marker
    update_score(winner)
    display_result(winner)
  end

  def initial_setup
    cls
    say 'Welcome to Tic-Tac-Toe!', 2
    human.name = choose_human_name
    say "Hello, #{human.name}. My name is #{computer.name}.", 2
    @match_wins = choose_number_of_wins
    choose_markers
    @first_player = choose_first_to_move
    display_starter_initial
    initial_setup_pause
    new_game(FIRST_GAME)
    display_new_game_screen
  end

  def initial_setup_pause
    puts
    say "Thanks, #{human.name}, I have everything I need to get started.\n" \
        "Please hit any key when you are ready to begin."
    getchar
  end

  def keep_playing?
    say 'Keep playing (Y or yes, any other key to quit)? '
    return false unless %w(y yes).include?(gets.chomp.downcase)
    true
  end

  def match_count_text(win_count)
    NUMBER_TEXT[win_count].nil? ? win_count.to_s : NUMBER_TEXT[win_count]
  end

  def match_winner?
    @score[:computer] == @match_wins || @score[:human] == @match_wins
  end

  def new_match
    reset_score
    cls
    say "Ok, #{human.name}, let's play another.", 2
    @match_wins = choose_number_of_wins
    @first_player = choose_first_to_move
    new_game(FIRST_GAME)
  end

  def new_game(first_game = false)
    @board = Board.new
    computer.board = @board
    human.board = @board
    @first_player = swap_first_player if @alternate_starters && !first_game
    first_move
  end

  def play_again?
    say 'Play again (Y or yes, any other key to quit)? '
    return false unless %w(y yes).include?(gets.chomp.downcase)
    true
  end

  def play_moves
    loop do
      current_player_move
      toggle_on_move
      display_board(CLEAR_SCREEN) if @on_move == HUMAN_PLAYER
      display_score
      break if board.someone_won? || board.full?
    end
  end

  def reset_score
    @score.each { |k, _| @score[k] = 0 }
  end

  def swap_first_player
    @first_player == HUMAN_PLAYER ? COMPUTER_PLAYER : HUMAN_PLAYER
  end

  def toggle_on_move
    @on_move = @on_move == HUMAN_PLAYER ? COMPUTER_PLAYER : HUMAN_PLAYER
  end

  def update_score(winner)
    if winner == human.mark
      @score[:human] += 1
    elsif winner == computer.mark
      @score[:computer] += 1
    end
  end
end

game = TTTGame.new
game.play
