class Vehicle
  @@instance_count = 0

  attr_accessor(:color, :speed)
  attr_reader(:year, :model)

  def initialize(year, model, color)
    @speed = 0
    @@instance_count += 1
    @year = year
    @model = model
    @color = color
  end

  def self.instance_count
    @@instance_count
  end

  def self.gas_mileage(miles, gallons, instance)
    puts "Mileage for the #{instance.year} #{instance.model} is #{miles/gallons} mpg."
  end

  def current_speed
    puts "Current speed is #{self.speed} mph."
  end

  def brake(how_much)
    self.speed -= how_much
    puts "Speed is now #{self.speed} mph."
  end

  def shut_down
    puts 'Parking...'
    @speed = 0
  end

  def speed_up(how_much)
    self.speed += how_much
    puts "Speed is now #{self.speed} mph."
  end

  def spray_paint(color)
    self.color = color
    puts "New color is #{self.color}."
  end

  def age
    "This #{self.model} is #{calc_age} years old."
  end

  private

  def calc_age
    Time.now.year - self.year
  end
end

module CarStuff
  def open_trunk
    puts 'Trunk opened'
  end
end

class MyTruck < Vehicle
  WHEELS = 18
end

class MyCar < Vehicle
  include CarStuff

  WHEELS = 4

  def initialize(year, model, color)
    super
  end

  def to_s
    "This car is a #{self.model}, year #{self.year}, color #{self.color}."
  end
end

lumina = MyCar.new(1997, 'chevy lumina', 'white')
lumina2 = MyCar.new(1985, 'Mercedes 300 SD', 'tan')
peterbilt = MyTruck.new(2003, 'Peterbilt 567 UltraLoft', 'blue')
puts lumina.age
puts lumina2.age
puts peterbilt.age

# puts lumina.methods
# puts
# puts peterbilt.methods
# puts
puts Vehicle.ancestors
puts
puts MyCar.ancestors
puts
puts MyTruck.ancestors
puts

puts Vehicle.instance_count
lumina.open_trunk
puts 'Year is ' + peterbilt.year.to_s + '.'
peterbilt.class.gas_mileage(1024, 20, peterbilt)
puts
puts peterbilt
puts lumina
puts
peterbilt.speed_up(20)
peterbilt.current_speed
peterbilt.speed_up(20)
peterbilt.current_speed
peterbilt.brake(20)
peterbilt.current_speed
peterbilt.brake(20)
peterbilt.current_speed
peterbilt.shut_down
peterbilt.current_speed


puts peterbilt.model
puts peterbilt.color
peterbilt.spray_paint('green')
puts peterbilt.color
puts peterbilt.year