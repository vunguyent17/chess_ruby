# frozen_string_literal: true

# Pawn class for Chess
class Pawn < ChessPiece
  attr_accessor :two_step

  def initialize(player, location)
    super(player, location)
    @two_step = false
  end

  def display_symbol
    @player.team.zero? ? ' ♙ WP '.blue : ' ♟ BP '.red
  end

  def adjust_loc
    @player.team.zero? ? 1 : -1
  end

  def filter_loc(loc, game_board); end

  def possible_moves_normal(game_board)
    move_option = [[-adjust_loc, 0]]
    move_option.push([-2 * adjust_loc, 0]) if !moved && game_board.empty?([@location[0] - adjust_loc, @location[1]])
    move_option.map { |option| [@location[0] + option[0], @location[1] + option[1]] }.filter do |loc|
      next if check_in_range(loc) == false

      chesspiece_node = game_board.get_node(loc).chess_piece
      chesspiece_node.nil? || chesspiece_node.player.team != @player.team
    end
  end

  def possible_moves(game_board)
    possible_moves = possible_moves_normal(game_board)
    opponent_loc = [[-adjust_loc, adjust_loc], [-adjust_loc, -adjust_loc]].map do |option|
      [@location[0] + option[0], @location[1] + option[1]]
    end
    check_opponent = opponent_loc.filter { |loc| check_in_range(loc) }
    check_opponent.each do |loc|
      chess_piece = game_board.get_node(loc).chess_piece
      possible_moves.push(loc) if !chess_piece.nil? && chess_piece.player.team != @player.team
    end
    possible_moves
  end

  def move(new_loc, game_board)
    @two_step = (@location[0] - new_loc[0]).abs == 2
    game_board.set_chess_piece(@location, nil)
    @location = new_loc
    game_board.set_chess_piece(@location, self)
  end
end
