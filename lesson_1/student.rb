class Student
  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(student_instance)
    grade.downcase < student_instance.grade.downcase
  end

  protected

  attr_accessor :name, :grade
end

joe = Student.new('Joe', 'A')
pete = Student.new('Pete', 'b')

puts 'Well done!' if joe.better_grade_than?(pete)

puts pete.grade