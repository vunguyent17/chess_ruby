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
    # player_b, player_w, chess_piece
    @chess_board = create_empty_board
    if args.size == 2
      add_chess_pieces(args[0], args[1])
    else
      unserialize(args[0], args[1], args[2])
    end
  end

  def serialize_util
    super do |obj, var|
      obj[var] = @chess_board.map do |row|
        row.filter do |node|
          !node.chess_piece.nil?
        end.map(&:serialize_util)
      end
      true
    end
  end

  def unserialize_update_player(player_b, player_w, chess_piece)
    return if chess_piece.name != 'King'

    if chess_piece.player.zero?
      player_w.king = chess_piece
    else
      player_b.king = chess_piece
    end
  end

  def unserialize(player_b, player_w, obj)
    data = obj['@chess_board']
    data.each do |row|
      row.each do |node|
        import_node_data(player_b, player_w, node)
      end
    end
  end

  def import_node_data(player_b, player_w, node)
    loc = node['@current_loc']
    piece_class = Object.const_get(node['@chess_piece']['@name'])
    target_node = @chess_board[loc[0]][loc[1]]
    target_node.chess_piece = piece_class.new(nil, loc)
    target_piece = target_node.chess_piece
    target_piece.unserialize(node['@chess_piece'])
    unserialize_update_player(player_b, player_w, target_piece)
    player_num = target_piece.player
    target_piece.player = player_num.zero? ? player_w : player_b
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

  def add_chess_pieces_row(row, arr)
    0.upto(7) do |y|
      @chess_board[row][y].chess_piece = arr[y]
    end
  end

  def add_chess_pieces(player_b, player_w)
    add_chess_pieces_row(0, create_king_row(player_b, 0))
    add_chess_pieces_row(1, create_pawn_row(player_b, 1))
    add_chess_pieces_row(6, create_pawn_row(player_w, 6))
    add_chess_pieces_row(7, create_king_row(player_w, 7))
  end

  def create_pawn_row(player, row)
    result = []
    0.upto(7) do |y|
      result.push(Pawn.new(player, [row, y]))
    end
    result
  end

  def create_king_row(player, row)
    king = King.new(player, [row, 4])
    part_one = [Rook.new(player, [row, 0]), Knight.new(player, [row, 1]), Bishop.new(player, [row, 2])]
    part_two = [Queen.new(player, [row, 3]), king]
    part_three = [Bishop.new(player, [row, 5]), Knight.new(player, [row, 6]), Rook.new(player, [row, 7])]
    player.king = king
    part_one + part_two + part_three
  end

  def display_board
    @chess_board.each_with_index do |row, idx_row|
      print "#{V_AXIS[idx_row]} ".brown
      row.each_with_index do |node, idx_col|
        symbol = node.display_node
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
