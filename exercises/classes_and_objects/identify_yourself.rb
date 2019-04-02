class Cat
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def to_s
    "I'm #{name}!"
  end

  def identify
    self
  end
end

kitty = Cat.new('Sophie')
p kitty.identify
puts kitty