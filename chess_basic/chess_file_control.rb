# frozen_string_literal: true

require_relative './game_chess'
require_relative '../util/basic_serialization'
require_relative './player'
require_relative '../util/color'

require 'json/add/core'

# File control for Hangman game
class ChessFileControl < ChessGameControl
  include BasicSerializable
  def initialize
    super
    @id = ''
  end

  def save_gameplay
    @id = create_id
    save_file = File.open("./save/#{@id}.json", 'w')
    save_file.puts(serialize)
    save_file.close
    puts 'Data saved successfully'.green
  end

  def create_id
    print 'Type name of this saved data: '
    gets.chomp
  end

  def load_gameplay
    @id = create_id
    load_file = File.open("./save/#{@id}.json", 'r')
    obj = JSON.parse(load_file.readline)

    unserialize(obj)
    load_file.close
    puts 'Data loaded successfully'.green
    @chess_board.display_board
  end

  def unserialize_util(obj, key)
    case key
    when '@player_b', '@player_w'
      Player.new(obj[key])
    else
      obj[key]
    end
  end

  def serialize_util
    super do |_obj, var|
      var == :@chess_board
    end
  end

  def unserialize(obj)
    obj.each_key do |key|
      instance_variable_set(key, unserialize_util(obj, key))
    end
    @chess_board.unserialize(@player_b, @player_w)
  end
end
