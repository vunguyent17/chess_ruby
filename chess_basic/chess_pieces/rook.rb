# frozen_string_literal: true

require_relative 'chess_piece'

# Rook class for Chess
class Rook < ChessPiece
  def display_symbol
    @player.team.zero? ? ' ♖ WR '.blue : ' ♜ BR '.red
  end

  def possible_moves(game_board)
    possible_moves_col(game_board) + possible_moves_row(game_board)
  end
end
