# frozen_string_literal: true

H_AXIS = 'abcdefgh'
V_AXIS = [8, 7, 6, 5, 4, 3, 2, 1].freeze

require_relative './node'
require_relative '../../util/color'
require_relative '../../util/basic_serialization'
require_relative '../chess_pieces/bishop'
require_relative '../chess_pieces/king'
require_relative '../chess_pieces/knight'
require_relative '../chess_pieces/pawn'
require_relative '../chess_pieces/queen'
require_relative '../chess_pieces/rook'

# Class ChessBoard for chess
class ChessBoard
  include BasicSerializable
  attr_accessor :chess_board

  def initialize(*args)
    # player_b, player_w
    @chess_board = create_empty_board
    add_chess_pieces(*args)
  end

  def unserialize_update_player(player_b, player_w, chess_piece)
    return if chess_piece.name != 'King'

    if chess_piece.player.zero?
      player_w.chess_pieces['King0'] = chess_piece
    else
      player_b.chess_pieces['King0'] = chess_piece
    end
  end

  def clear
    @chess_board.each do |row|
      row.each do |node|
        node.chess_piece = nil
      end
    end
  end

  def unserialize(player_b, player_w)
    clear
    data = player_b.chess_pieces.values + player_w.chess_pieces.values
    data.each do |piece|
      loc = piece.location
      target_node = @chess_board[loc[0]][loc[1]]
      target_node.chess_piece = piece
    end
  end

  def create_empty_board
    matrix = Array.new(8) { Array.new(8) }
    0.upto(7) do |x|
      0.upto(7) do |y|
        matrix[x][y] = Node.new([x, y], H_AXIS[y] + V_AXIS[x].to_s)
      end
    end
    matrix
  end

  def add_chess_pieces(player_b, player_w)
    add_chess_pieces_row(0, create_king_row(player_b, 0))
    add_chess_pieces_row(1, create_pawn_row(player_b, 1))
    add_chess_pieces_row(6, create_pawn_row(player_w, 6))
    add_chess_pieces_row(7, create_king_row(player_w, 7))
  end

  def add_chess_pieces_row(row, arr)
    0.upto(7) do |y|
      @chess_board[row][y].chess_piece = arr[y]
    end
  end

  def create_pawn_row(player, row)
    pawn_row = []
    0.upto(7) do |y|
      pawn_row.push(player.chess_pieces["Pawn#{y}"])
    end
    pawn_row.each_with_index { |chess_piece, index| chess_piece.location = [row, index] }
    pawn_row
  end

  def create_king_row(player, row)
    king_row = %w[Rook0 Knight0 Bishop0 Queen0 King0 Bishop1 Knight1 Rook1]
    king_row.map.with_index do |piece_id, index|
      chess_piece = player.chess_pieces[piece_id]
      chess_piece.location = [row, index]
      chess_piece
    end
  end

  def display_board
    @chess_board.each_with_index do |row, idx_row|
      print "#{V_AXIS[idx_row]} ".brown
      row.each_with_index do |node, idx_col|
        symbol = node.display_node
        # symbol = node.chess_piece.nil? ? "" : node.chess_piece.location.to_s
        symbol = symbol.bold.bg_gray if (idx_row + idx_col).odd?
        print symbol
      end
      puts ''
    end
    puts "    a     b     c     d     e     f     g     h   \n ".brown
  end

  def display_board_possible_moves_util(loc, possible_moves)
    @chess_board.each_with_index do |row, idx_row|
      print "#{V_AXIS[idx_row]} ".brown
      row.each_with_index do |node, idx_col|
        symbol = node.display_node
        if loc == [idx_row, idx_col]
          symbol = symbol.bold.bg_green
        elsif possible_moves.include?([idx_row, idx_col])
          symbol = symbol.bold.bg_brown
        elsif (idx_row + idx_col).odd?
          symbol = symbol.bold.bg_gray
        end
        print symbol
      end
      puts ''
    end
  end

  def display_board_possible_moves(current_loc)
    puts ''
    possible_moves = get_node(current_loc).chess_piece.possible_moves(self)
    display_board_possible_moves_util(current_loc, possible_moves)
    puts '    a     b     c     d     e     f     g     h   '.brown
    puts ''
  end

  def get_node(loc)
    @chess_board[loc[0]][loc[1]]
  end

  def empty?(loc)
    @chess_board[loc[0]][loc[1]].chess_piece.nil?
  end

  def set_chess_piece(loc, chess_piece)
    @chess_board[loc[0]][loc[1]].chess_piece = chess_piece
  end

  # def find_loc_chess_piece(name, player)
  #   result = []
  #   @chess_board.each do |row|
  #     row.each do |node|
  #       chess_piece = node.chess_piece
  #       next if chess_piece.nil?

  #       result.push(chess_piece) if chess_piece.class.to_s == name && chess_piece.player.team == player.team
  #     end
  #   end
  #   result
  # end
end
