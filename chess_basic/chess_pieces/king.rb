# frozen_string_literal: true

# King class for Chess
class King < ChessPiece
  attr_accessor :checked

  def initialize(player, location)
    super(player, location)
    @checked = false
  end

  def display_symbol
    @player.team.zero? ? ' ♔ WK '.blue : ' ♚ BK '.red
  end

  def move_option
    (-1..1).to_a.reduce([]) do |acc, val|
      new_arr = []
      (-1..1).each do |val2|
        new_arr.push([val, val2]) unless [val, val2] == [0, 0]
      end
      acc + new_arr
    end
  end

  def possible_moves(game_board)
    move_option.map { |option| [@location[0] + option[0], @location[1] + option[1]] }.filter do |loc|
      next if check_in_range(loc) == false

      chesspiece_node = game_board.get_node(loc).chess_piece
      chesspiece_node.nil? || chesspiece_node.player.team != @player.team
    end
  end

  def checked_at?(loc, chess_board)
    chess_pieces_list = %w[Bishop King Knight Pawn Queen Rook]
    chess_pieces_list.each do |name|
      class_name = Module.const_get name
      test_instance = class_name.new(@player, loc)
      possible_moves = test_instance.possible_moves(chess_board)
      possible_moves.each { |move| return true if chess_board.get_node(move).chess_piece.class.to_s == name }
    end
    false
  end

  def set_checked(chess_board)
    @checked =  checked_at?(@location, chess_board)
  end

  def mate?(chess_board)
    @checked == true && possible_moves(chess_board) != [] && possible_moves(chess_board).all? do |move|
      checked_at?(move, chess_board) == true
    end
  end

  def stalemate?(chess_board)
    @checked == false && possible_moves(chess_board) != [] && possible_moves(chess_board).all? do |move|
      checked_at?(move, chess_board) == true
    end
  end
end
