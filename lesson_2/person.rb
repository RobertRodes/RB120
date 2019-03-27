class Person
  attr_accessor :first_name, :last_name

  def initialize(full_name)
    build_name(full_name)
  end

  def name=(full_name)
    build_name(full_name)
  end

  def name
    "#{self.first_name} #{self.last_name}".strip
  end

  def to_s
    name
  end
  
  private

  def build_name(full_name)
    names = full_name.split
    @first_name = names[0]
    @last_name = 1 == names ? '' : names[-1]
  end


end

bob = Person.new('Robert Emmet Rodes')
p bob.name 
p bob.first_name            # => 'Robert'
p bob.last_name             # => ''
bob.last_name = 'Winnamucker'
p bob.name 

bob = Person.new('Robert Smith')
rob = Person.new('Robert Smith')
p bob.name == rob.name

p bob.to_s