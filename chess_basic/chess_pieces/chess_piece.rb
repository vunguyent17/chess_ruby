# frozen_string_literal: true

require_relative '../../util/basic_serialization'
# ChessPiece class for Chess
class ChessPiece
  include BasicSerializable
  attr_accessor :piece_id, :name, :player, :moved, :location

  def initialize(piece_id, player)
    @piece_id = piece_id
    @name = self.class.to_s
    @player = player
    @moved = false
    @location = [0, 0]
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

  def unserialize(obj)
    super do |_obj, key|
      key == '@player'
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
    @player.chess_pieces['King0'].modify_checked(game_board)
  end

  def move_when_checked_possible?(new_loc, game_board)
    # save original state
    old_loc = @location
    old_move = @move
    old_king_checked = @player.chess_pieces['King0'].checked
    new_chess_piece = game_board.get_node(new_loc).chess_piece
    # test
    result = true
    initiate_move(new_loc, game_board)
    result = false if @player.chess_pieces['King0'].checked
    # load original state
    initiate_move(old_loc, game_board)
    game_board.set_chess_piece(new_loc, new_chess_piece)
    @move = old_move
    @player.chess_pieces['King0'].checked = old_king_checked
    result
  end

  def move_util(new_loc, game_board)
    return false if @player.chess_pieces['King0'].checked && !move_when_checked_possible?(new_loc, game_board)

    remove_opponent_piece(new_loc, game_board)
    initiate_move(new_loc, game_board)
    @moved = true
  end

  def move(new_loc, game_board)
    info = 'Move to new location not possible because the King would still be checked. Please choose another location'
    result = move_util(new_loc, game_board)
    puts info if result == false
    result
  end

  def remove_opponent_piece(new_loc, game_board)
    node_remove_piece = game_board.chess_board[new_loc[0]][new_loc[1]]
    opponent_piece = node_remove_piece.chess_piece
    return if opponent_piece.nil?

    opponent = opponent_piece.player
    opponent.chess_pieces.delete(opponent_piece.piece_id)
    node_remove_piece.chess_piece = nil
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
