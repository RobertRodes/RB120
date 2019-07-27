class GuessingGame
  RESULT_MSG = {
    high: "That's too high.",
    low:  "That's too low.",
    win:  "That's the number!"
  }

  FINAL_RESULT_MSG = {
    win:  'You win!',
    lose: "Sorry, you're out of guesses. You lose."
  }

  def initialize(low, high)
    @range = low..high
    @answer = rand(@range)
    @guesses = Math.log2(high - low).to_i + 1
  end

  def play
    result = nil
    @guesses.downto(1) do |guess|
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
      print "Enter a number between #{@range.first} and #{@range.last}: "
      num = gets.chomp
      return num.to_i if num.to_i.to_s == num && 
        (@low..@high).cover?(num.to_i)
      print 'Invalid guess. '
    end
  end

  def final_result(result)
    FINAL_RESULT_MSG[result == :win ? :win : :lose]
  end

  def remaining_guesses(guess)
    return "You have #{@guesses} guesses." if guess == @guesses
    "You have #{guess} guess#{guess == 1 ? '' : 'es'} left."
  end
end

game = GuessingGame.new(100,1000)
game.play
