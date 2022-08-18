# frozen_string_literal: true

require_relative '../../util/basic_serialization'
# ChessPiece class for Chess
class ChessPiece
  include BasicSerializable
  attr_accessor :name, :player, :moved, :location

  def initialize(player, location)
    @name = self.class.to_s
    @player = player
    @moved = false
    @location = location
  end

  def serialize_util
    super do |obj, var|
      if var == :@player
        obj[var] = @player.team
        true
      else
        false
      end
    end
  end

  def possible_moves(game_board); end

  def verify_next_move(new_loc, game_board)
    return false if check_new_loc(new_loc, game_board) == false

    possible_moves = possible_moves(game_board)
    possible_moves.include?(new_loc)
  end

  def initiate_move(new_loc, game_board)
    game_board.set_chess_piece(@location, nil)
    @location = new_loc
    game_board.set_chess_piece(@location, self)
  end

  def move_when_checked(new_loc, game_board)
    old_location = @location
    initiate_move(new_loc, game_board)
    if @player.king.checked
      initiate_move(old_location, game_board)
      return false
    end
    true
  end

  def move(new_loc, game_board)
    if @player.king.checked
      return false if move_when_checked(new_loc, game_board) == false
    else
      initiate_move(new_loc, game_board)
    end
    @moved = true
  end

  def display_location
    "#{H_AXIS[@location[1]]}#{V_AXIS[@location[0]]}"
  end

  def check_in_range(new_loc)
    (0..7).include?(new_loc[0]) && (0..7).include?(new_loc[1])
  end

  def check_new_loc(new_loc, game_board)
    target = game_board.get_node(new_loc).chess_piece
    return true if target.nil? || target.player.team != @player.team

    false
  end

  def possible_moves_row_util(game_board, mode)
    result = []
    row = @location[0]
    col = @location[1]
    loop do
      col += mode
      break unless (0..7).include?(col)

      chesspiece_node = game_board.get_node([row, col]).chess_piece
      result.push([row, col]) if chesspiece_node.nil? || chesspiece_node.player.team != @player.team
      break unless chesspiece_node.nil?
    end
    result
  end

  def possible_moves_row(game_board)
    possible_moves_row_util(game_board, 1) + possible_moves_row_util(game_board, -1)
  end

  def possible_moves_col_util(game_board, mode)
    result = []
    row = @location[0]
    col = @location[1]
    loop do
      row += mode
      break unless (0..7).include?(row)

      chesspiece_node = game_board.get_node([row, col]).chess_piece
      result.push([row, col]) if chesspiece_node.nil? || chesspiece_node.player.team != @player.team
      break unless chesspiece_node.nil?
    end
    result
  end

  def possible_moves_col(game_board)
    possible_moves_col_util(game_board, 1) + possible_moves_col_util(game_board, -1)
  end

  def possible_moves_diag_util(game_board, adjust)
    result = []
    row = @location[0]
    col = @location[1]
    loop do
      row += adjust[0]
      col += adjust[1]
      break if check_in_range([row, col]) == false

      chesspiece_node = game_board.get_node([row, col]).chess_piece
      result.push([row, col]) if chesspiece_node.nil? || chesspiece_node.player.team != @player.team
      break unless chesspiece_node.nil?
    end
    result
  end

  def possible_moves_diag(game_board)
    adjusts = [1, -1].product([1, -1])
    adjusts.reduce([]) { |acc, adjust| acc + possible_moves_diag_util(game_board, adjust) }
  end

  def loc_between_with_same_row(loc_two)
    result = []
    return result if @location[0] != loc_two[0]

    range_col = @location[1] < loc_two[1] ? (@location[1] + 1..loc_two[1] - 1) : (loc_two[1] + 1..@location[1] - 1)
    range_col.to_a.map { |col| [loc_two[0], col] }
  end
end
