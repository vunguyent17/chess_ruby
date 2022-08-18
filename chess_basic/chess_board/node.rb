# frozen_string_literal: true

require_relative '../../util/basic_serialization'
# Node class for ChessBoard
class Node
  include BasicSerializable
  attr_accessor :current_loc, :name, :chess_piece

  def initialize(loc, name, chess_piece = nil)
    @current_loc = loc
    @name = name
    @chess_piece = chess_piece
  end

  def location?(loc)
    @current_loc[0] == loc[0] && @current_loc[1] == loc[1]
  end

  def display_node
    @chess_piece.nil? ? '      ' : @chess_piece.display_symbol
  end
end
