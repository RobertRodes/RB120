class Person
  attr_writer :secret

  def share_secret
    secret
  end

  private
  attr_reader :secret
end

person1 = Person.new
person1.secret = 'Shh.. this is a secret!'
puts person1.share_secret
