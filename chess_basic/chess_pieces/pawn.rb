# frozen_string_literal: true

# Pawn class for Chess
class Pawn < ChessPiece
  attr_accessor :two_step_prev

  def initialize(player, location)
    super(player, location)
    @two_step_prev = false
  end

  def display_symbol
    @player.team.zero? ? ' ♙ WP '.blue : ' ♟ BP '.red
  end

  def adjust_loc
    @player.team.zero? ? 1 : -1
  end

  def filter_loc(loc, game_board); end

  def move(new_loc, game_board)
    @two_step_prev = (@location[0] - new_loc[0]).abs == 2
    if new_loc[1] != @location[1] && game_board.get_node(new_loc).chess_piece.nil?
      remove_pawn_enpassant_pass(game_board)
    end

    super(new_loc, game_board)
  end

  ### Possible moves
  # Use custom methods: possible_moves_normal, possible_moves_enpassant
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
    possible_moves_enpassant(possible_moves, game_board)

    possible_moves
  end

  # possible_moves_normal
  # Use custom methods: check_in_range (from chess_piece)
  def possible_moves_normal(game_board)
    move_option = [[-adjust_loc, 0]]
    move_option.push([-2 * adjust_loc, 0]) if !@moved && game_board.empty?([@location[0] - adjust_loc, @location[1]])
    move_option.map { |option| [@location[0] + option[0], @location[1] + option[1]] }.filter do |loc|
      next if check_in_range(loc) == false

      chesspiece_node = game_board.get_node(loc).chess_piece
      chesspiece_node.nil? || chesspiece_node.player.team != @player.team
    end
  end

  # En passant
  def possible_moves_enpassant(possible_moves, game_board)
    pawn_enpassant_pass = target_pawn_enpassant_pass(game_board)
    return if pawn_enpassant_pass.nil?

    target_pawn_loc = pawn_enpassant_pass.location
    possible_moves.push([target_pawn_loc[0] - adjust_loc, target_pawn_loc[1]])
  end

  def target_pawn_enpassant_pass(game_board)
    options = [1, -1]
    check_locs = options.map { |option| [@location[0], @location[1] + option] }
    check_locs.each do |loc|
      next unless (0..7).include?(loc[1])

      chesspiece = game_board.get_node(loc).chess_piece
      return chesspiece if !chesspiece.nil? && chesspiece.name == 'Pawn' && chesspiece.two_step_prev == true
    end
    nil
  end

  def remove_pawn_enpassant_pass(game_board)
    puts 'Note: Inititate en-passant move'
    target_pawn = target_pawn_enpassant_pass(game_board)
    return if target_pawn.nil?

    remove_opponent_piece(target_pawn.location, game_board)
  end
end
