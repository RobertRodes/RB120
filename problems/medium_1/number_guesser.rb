class GuessingGame
  GUESSES = 7
  RESULT_MSG = {
    high: "That's too high.",
    low:  "That's too low.",
    win:  "That's the number!"
  }

  FINAL_RESULT_MSG = {
    win:  'You win!',
    lose: "Sorry, you're out of guesses. You lose."
  }

  def initialize
    @answer = rand(1..100)
  end

  def play
    result = nil
    GUESSES.downto(1) do |guess|
      puts remaining_guesses(guess)
      num = choose_number
      result = compare(num)
      print "#{RESULT_MSG[result]}\n\n"
      break if result == :win
    end
    print "#{final_result(result)}\n\n"
  end

  private

  def compare(num)
    return :high if num > @answer
    return :low  if num < @answer
    :win
  end

  def choose_number
    loop do
      print 'Enter a number between 1 and 100: '
      num = gets.chomp
      return num.to_i if num =~ /^[1-9][0-9]?$|^100$/
      print 'Invalid guess. '
    end
  end

  def final_result(result)
    FINAL_RESULT_MSG[result == :win ? :win : :lose]
  end

  def remaining_guesses(guess)
    return "You have #{GUESSES} guesses." if guess == GUESSES
    "You have #{guess} guess#{guess == 1 ? '' : 'es'} left."
  end
end

game = GuessingGame.new
game.play
