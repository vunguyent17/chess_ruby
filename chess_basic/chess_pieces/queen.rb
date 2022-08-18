# frozen_string_literal: true

require_relative 'chess_piece'

# Queen class for Chess
class Queen < ChessPiece
  def display_symbol
    @player.team.zero? ? ' ♕ WQ '.blue : ' ♛ BQ '.red
  end

  def possible_moves(game_board)
    possible_moves_col(game_board) + possible_moves_row(game_board) + possible_moves_diag(game_board)
  end
end
