class Cat
  COLOR = 'purple'
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def greet
    puts "Meow! My name is #{self.name} and I'm a #{COLOR} cat."
  end
end

kitty = Cat.new('Sophie')
kitty.greet