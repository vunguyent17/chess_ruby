# frozen_string_literal: true

require_relative '../util/basic_serialization'
# Player class to create player Black and White
class Player
  include BasicSerializable
  attr_accessor :team, :name, :king

  def initialize(name, team)
    @name = name
    @team = team
    @king = nil
  end

  def serialize_util
    super do |obj, var|
      if var == :@king
        obj[var] = @king.location
        true
      else
        false
      end
    end
  end

  def input_loc_from
    print 'Type location from: '
    process_input(gets.chomp)
  end

  def input_loc_to
    print 'To: '
    process_input(gets.chomp)
  end

  # H_AXIS = 'abcdefgh'
  # V_AXIS = [8, 7, 6, 5, 4, 3, 2, 1].freeze
  def process_input(input)
    arr = input.split('')
    row = V_AXIS.find_index(arr[1].to_i)
    col = H_AXIS.index(arr[0])
    [row, col]
  end

  def win
    puts "Player #{@name} wins"
  end
end
