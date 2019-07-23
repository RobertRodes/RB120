class MinilangError < RuntimeError; end
class StackError < MinilangError; end
class TokenError < MinilangError; end

class Minilang
  TRACE = true

  def initialize(cmds, args = {})
    @reg = {ax: 0} # To support future multiple registers
    @stack = []
    @cmds = format(cmds, args)
  end

  def eval
    @cmds.split.each do |cmd|
      execute(cmd)
      if TRACE then
        puts "Instruction: #{cmd}"
        puts "AX:          #{@reg[:ax]}"
        puts "Stack:       #{@stack}"
        puts
      end
    end
  rescue MinilangError => err
    puts "#{err.class}: #{err.message}"
  end

  def popit
    raise StackError.new('Attempted to POP from empty stack.') if @stack.empty?
    @stack.pop
  end

  def execute(cmd)
    case cmd
    when 'PUSH'     then @stack.push(@reg[:ax])
    when 'ADD'      then @reg[:ax] += popit
    when 'SUB'      then @reg[:ax] -= popit
    when 'MULT'     then @reg[:ax] *= popit
    when 'DIV'      then @reg[:ax] /= popit
    when 'MOD'      then @reg[:ax] %= popit
    when 'POP'      then @reg[:ax] = popit
    when 'PRINT'    then puts @reg[:ax] unless TRACE
    else
      raise TokenError.new("Invalid token #{cmd}") if cmd !~ /^[-+]?\d+$/
      @reg[:ax] = cmd.to_i
    end
  end
end

CENTIGRADE_TO_FAHRENHEIT = '32 PUSH 5 PUSH 9 PUSH %<degrees_c>d MULT DIV ADD PRINT'
FAHRENHEIT_TO_CENTIGRADE = '9 PUSH 5 PUSH 32 PUSH %<degrees_f>d SUB MULT DIV PRINT'
AREA_RECTANGLE = '%<height>d PUSH %<width>d MULT PRINT'
MILES_TO_KM = '5 PUSH %<miles>d PUSH 8 MULT DIV PRINT'
KM_TO_MILES = '8 PUSH %<km>d PUSH 5 MULT DIV PRINT'
MODULUS = '%<divisor>d PUSH %<dividend>d MOD PRINT'
AREA_CIRCLE = '7 PUSH 22 PUSH %<radius>d PUSH MULT MULT DIV PRINT'

Minilang.new(MODULUS, dividend: 37, divisor: 12).eval
# Minilang.new('22 ADD PRINT').eval
# Minilang.new('POP PRINT').eval
# Minilang.new(CENTIGRADE_TO_FAHRENHEIT, degrees_c: 20).eval
# Minilang.new(FAHRENHEIT_TO_CENTIGRADE, degrees_f: 50).eval
# Minilang.new(AREA_RECTANGLE, height: 8, width: 7).eval
# Minilang.new(KM_TO_MILES, km: 140).eval 
# Minilang.new(MILES_TO_KM, miles: 75).eval
# Minilang.new(AREA_CIRCLE, radius: 100).eval