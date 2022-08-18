# frozen_string_literal: true

# Knight class for Chess
class Knight < ChessPiece
  def display_symbol
    @player.team.zero? ? ' ♘ WN '.blue : ' ♞ BN '.red
  end

  def move_option
    arr1 = [-2, 2]
    arr2 = [-1, 1]
    arr1.product(arr2) + arr2.product(arr1)
  end

  def possible_moves(game_board)
    move_option.map { |option| [@location[0] + option[0], @location[1] + option[1]] }.filter do |loc|
      next if check_in_range(loc) == false

      chesspiece_node = game_board.get_node(loc).chess_piece
      chesspiece_node.nil? || chesspiece_node.player.team != @player.team
    end
  end
end
