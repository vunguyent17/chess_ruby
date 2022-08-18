# frozen_string_literal: true

require_relative 'chess_piece'

# Bishop class for Chess
class Bishop < ChessPiece
  def display_symbol
    @player.team.zero? ? ' ♗ WB '.blue : ' ♝ BB '.red
  end

  def possible_moves(game_board)
    possible_moves_diag(game_board)
  end
end
