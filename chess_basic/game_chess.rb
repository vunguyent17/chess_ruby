# frozen_string_literal: true

require_relative 'player'
require_relative './chess_board/chessboard'
require_relative '../util/basic_serialization'

# Chess class for a game of chess
class ChessGameControl
  include BasicSerializable
  attr_accessor :player_b, :player_w, :chess_board

  def initialize
    @player_b = Player.new('Black', 1)
    @player_w = Player.new('White', 0)
    @chess_board = ChessBoard.new(@player_b, @player_w)

    @winner = nil
    @next_turn = 0
  end

  # GAME TURN: which player turn -> player plays -> change next turn -> check winner
  # Use custom methods: choose_input, check_winner
  def game_turn
    puts "It's team #{@next_turn.zero? ? 'White (W)' : 'Black (B)'} turn"
    player = @next_turn.zero? ? @player_w : @player_b
    player.clear_two_steps_pawn
    choose_input(player)
    kings_set_checked
    @chess_board.display_board
    @next_turn = @next_turn.zero? ? 1 : 0
    check_winner
  end

  # Use custom methods: default_input, castling
  def choose_input(player)
    loop do
      print 'Type of input? Hit Enter - From/To, 1 - Castling: '
      case gets.chomp
      when ''
        default_input(player)
        break
      when '1'
        castling(player)
        break
      else
        puts 'Invalid input. Try again'
      end
    end
  end

  ### DEFAULT
  # Use custom methods: from_loc, to_loc, kings_set_checked
  def default_input(player)
    inputs = input_loc(player)
    chess_piece = @chess_board.get_node(inputs[0]).chess_piece
    return default_input(player) unless chess_piece.move(inputs[1], @chess_board)

    promote_to_queen(chess_piece) if check_pawn_promote?(chess_piece)
  end

  def kings_set_checked
    kings_set_checked_util(@player_b.chess_pieces['King0'])
    kings_set_checked_util(@player_w.chess_pieces['King0'])
  end

  def kings_set_checked_util(king)
    king.modify_checked(@chess_board)
    king.print_checked_info
  end

  ### CASTLING
  # Use custom methods: input_castling, castling_possible?, do_castling, choose_input
  def castling(player)
    rook = @chess_board.get_node(input_castling(player)).chess_piece
    king = player.chess_pieces['King0']
    if castling_possible?(king, rook)
      puts 'Initiate castling'
      do_castling(king, rook)
    else
      puts 'Castling not possible. Please choose again'
      choose_input(player)
    end
  end

  def castling_possible_util?(king, rook)
    check_same_row = rook.location[0] == king.location[0]
    check_empty_space = rook.loc_between_with_same_row(king.location).all? do |loc|
      @chess_board.get_node(loc).chess_piece.nil?
    end
    check_condition = [king.moved, rook.moved, king.checked, !check_same_row, !check_empty_space]
    puts "King moved / Rook moved / King checked / Not same row / No empty space  = #{
      check_condition.join(' / ')}"
    return false if check_condition.any?(true)

    true
  end

  # Use custom methods: castling_possible_util?
  def castling_possible?(king, rook)
    return false if castling_possible_util?(king, rook) == false

    king_direction = rook.location[1] < king.location[1] ? -1 : 1
    result = [1, 2].map { |num| [king.location[0], king.location[1] + num * king_direction] }.all? do |loc|
      !king.checked_at?(loc, @chess_board)
    end
    puts "Safe way for kings  = #{result}"
    result
  end

  def input_castling(player)
    print 'Type location of the rook you would like to initiate castling: '
    player.process_input(gets.chomp)
  end

  def do_castling(king, rook)
    king_direction = rook.location[1] < king.location[1] ? -1 : 1
    new_loc_king = [king.location[0], king.location[1] + 2 * king_direction]
    king.move(new_loc_king, @chess_board)
    new_loc_rook = [new_loc_king[0], new_loc_king[1] - king_direction]
    rook.move(new_loc_rook, @chess_board)
  end

  # check, mate, stalemate (black - 1, white - 0)
  def check_winner
    king_w = @player_w.chess_pieces['King0']
    king_b = @player_b.chess_pieces['King0']
    @winner = 0 if @player_w.mate?(@chess_board) || (@next_turn.zero? && king_b.checked)
    @winner = 1 if @player_b.mate?(@chess_board) || (@next_turn == 1 && king_w.checked)
    @winner = -1 if @player_b.stalemate?(@chess_board) || @player_w.stalemate?(@chess_board)
  end

  # INPUT
  # Use custom methods: valid_from_loc?
  def input_loc(player)
    loop do
      input_from = from_loc(player)
      @chess_board.display_board_possible_moves(input_from)
      input_to = to_loc(player, input_from)
      if input_to == 'reset'
        puts 'Resetting the input...'
        next
      end
      return [input_from, input_to]
    end
  end

  def from_loc(player)
    loop do
      input_loc = player.input_loc_from
      return input_loc if valid_from_loc?(input_loc, player)

      puts "Invalid input. Choose a location from a1 to h8 and you can't move opponent chess pieces. Try again"
    end
  end

  def valid_from_loc?(loc, player)
    target_piece = @chess_board.get_node(loc).chess_piece
    !target_piece.nil? && target_piece.player.team == player.team
  end

  # Use custom methods: valid_to_loc?
  def to_loc(player, from_loc)
    loop do
      input_loc = player.input_loc_to
      return input_loc if input_loc == 'reset' || valid_to_loc?(from_loc, input_loc)

      puts "Invalid move.
      The pieces #{@chess_board.get_node(from_loc).chess_piece.display_symbol} can't move to
      that location. Try again"
    end
  end

  def valid_to_loc?(from_loc, to_loc)
    @chess_board.get_node(from_loc).chess_piece.verify_next_move(to_loc, @chess_board)
  end

  def promote_to_queen(pawn)
    player = pawn.player
    new_queen = player.replace_pawn_with_queen(pawn)
    loc = new_queen.location
    @chess_board.chess_board[loc[0]][loc[1]].chess_piece = new_queen
  end

  def check_pawn_promote?(chess_piece)
    if chess_piece.name == 'Pawn'
      check_pawn_w = chess_piece.player.team.zero? && chess_piece.location[0].zero?
      check_pawn_b = chess_piece.player.team == 1 && chess_piece.location[0] == 7
      check_pawn_b || check_pawn_w
    else
      false
    end
  end
end
