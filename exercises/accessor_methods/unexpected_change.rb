class Person
  def name
    "#{@first} #{@last}"
  end

  def name=(name)
    names = name.split
    @first = names[0]
    @last = names[1]
  end
end

person1 = Person.new
person1.name = 'John Doe'
puts person1.name