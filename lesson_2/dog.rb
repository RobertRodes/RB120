class Pet
  def speak
    'You hear a strange noise, and wonder what it is.'
  end

  def swim
    'swimming!'
  end

  def run
    'running!'
  end

  def jump
    'jumping!'
  end

end

class Dog < Pet
  def speak
    'bark!'
  end

  def fetch
    'fetching!'
  end
end

class BullDog < Dog
  def swim
    "Can't swim!"
  end
end

class Cat < Pet
  def speak
    'Meow!'
  end

  def swim
    'Water. Ick.'
  end
end


pete = Pet.new
kitty = Cat.new
dave = Dog.new
bud = BullDog.new

p pete.run                # => "running!"
p pete.speak              # => NoMethodError 

p kitty.run               # => "running!"
p kitty.speak             # => "meow!"
p kitty.swim 

p dave.speak              # => "bark!"

p bud.run                 # => "running!"
p bud.swim  
