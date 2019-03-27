module Walkable
  def walk
    puts 'Walking from here to there.'
  end
end

class Animal
  def move
    puts 'Going from here to there.'
  end

  def method_missing(method)
    if method.id2name == 'walk'
      puts "Method '#{method.id2name}' is missing from your ##{self.class} class instance."
      puts 'You probably forgot to include the Walkable module in the class definition.'
    else
      super
    end
  end
end

class Bear < Animal
  include Walkable

  def speak
    puts 'GrOOOWWwwllll'
  end
end

class Dog < Animal
  def speak
    puts 'Woof woof'
  end
end

rex = Dog.new
rex.speak
rex.move
rex.walk
puts

pooh = Bear.new
pooh.speak
pooh.move
pooh.walk
puts Bear.ancestors
# pooh.run

puts 'Doing other stuff'

