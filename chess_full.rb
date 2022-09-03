# frozen_string_literal: true

require_relative './chess_basic/chess_file_control'

# Main Chess class
class Chess < ChessFileControl
  def play
    puts 'WELCOME TO CHESS GAME'
    loop do
      start_new_game
      play_one_game
      print 'Do you want to exit? (y/n): '
      break if gets.chomp == 'y'
    end
    puts 'Thank you for playing. See you next time'
  end

  def start_new_game
    print 'Options: 2 - Load, Empty - Start new game: '
    if gets.chomp.to_i == 2
      load_gameplay
    else
      initialize
    end
  end

  def play_one_game
    @chess_board.display_board
    while @winner.nil?
      game_turn
      print_winner unless @winner.nil?
      return true unless @winner.nil? # game completed
      return false if choose_game_option == false # game not complete
    end
  end

  def print_winner
    text_print = 'Chess match is over. '
    text_print += if @winner == -1
                    "It's a draw"
                  else
                    "The winner is Player #{@winner.zero? ? 'White' : 'Black'}"
                  end
    puts text_print
  end

  def choose_game_option
    print 'Options: 1 - Save, 2 - Load, 3 - Close this game, Empty - Continue: '
    user_input = gets.chomp.to_i
    case user_input
    when 1
      save_gameplay
    when 2
      load_gameplay
    when 3
      return false
    end
    true
  end
end
