module MyModule
  def say_hello_back
    puts 'Hello yourself!'
  end
end

class MyClass
  include MyModule
  def say_hello
    puts 'Hello!'
  end
end

x = MyClass.new
x.say_hello
x.say_hello_back