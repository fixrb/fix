# frozen_string_literal: true

# A small Duck implementation.
class Duck
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def say_hi
    "Hi, my name is #{name}!"
  end

  def walks
    "Klop klop!"
  end

  def swims
    "Swoosh..."
  end

  def quacks
    puts "Quaaaaaack!"
  end

  def inspect
    "<#{name}>"
  end
end
