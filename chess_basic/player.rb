# frozen_string_literal: true

require_relative '../util/basic_serialization'
# Player class to create player Black and White
class Player
  include BasicSerializable
  attr_accessor :team, :name, :king, :chess_pieces

  def initialize(*args)
    if args.size == 2
      @name = args[0]
      @team = args[1]
      @chess_pieces = initialize_pieces
    else
      data = args[0]
      @name = data['@name']
      @team = data['@team']
      @chess_pieces = convert_pieces(data['@chess_pieces'])
    end
  end

  def list_possible_moves(chess_board)
    result = {}
    @chess_pieces.each do |key, value|
      result[key] = value.possible_moves(chess_board)
    end
    result
  end

  def convert_pieces(data_arr)
    result = {}
    data_arr.each do |piece|
      piece_id = piece['@piece_id']
      piece_class = Object.const_get(piece['@name'])
      new_piece = piece_class.new(piece_id, self)
      new_piece.unserialize(piece)
      result[piece_id] = new_piece
    end
    result
  end

  def clear_two_steps_pawn
    @chess_pieces.each do |_key, piece|
      piece.two_step_prev = false if piece.name == 'Pawn'
    end
  end

  def serialize_util
    super do |obj, var|
      if var == :@chess_pieces
        obj[var] = @chess_pieces.map do |_key, piece|
          piece.serialize_util
        end
        true
      else
        false
      end
    end
  end

  def input_loc_from
    print 'Type from-location(i.e. a1): '
    process_input(gets.chomp)
  end

  def input_loc_to
    print 'Type to-location (i.e. a3) OR type "reset" to reset location input: '
    user_input = gets.chomp
    return 'reset' if user_input == 'reset'

    process_input(user_input)
  end

  # H_AXIS = 'abcdefgh'
  # V_AXIS = [8, 7, 6, 5, 4, 3, 2, 1].freeze
  def process_input(input)
    arr = input.split('')
    row = V_AXIS.find_index(arr[1].to_i)
    col = H_AXIS.index(arr[0])
    [row, col]
  end

  def win
    puts "Player #{@name} wins"
  end

  def initialize_pieces
    result = {}
    0.upto(7) do |y|
      piece_id = "Pawn#{y}"
      result[piece_id] = Pawn.new(piece_id, self)
    end
    %w[King Queen Rook Knight Bishop].each do |piece|
      0.upto(1) do |y|
        break if y.positive? && %w[King Queen].include?(piece)

        piece_id = piece + y.to_s
        piece_class = Object.const_get(piece)
        result[piece_id] = piece_class.new(piece_id, self)
      end
    end
    result
  end

  def possible_moves_without_checked(chess_board)
    result = {}
    @chess_pieces.each do |key, value|
      possible_new_loc = value.possible_moves(chess_board)
      result[key] = possible_new_loc != [] && possible_new_loc.any? do |new_loc|
        value.move_when_checked_possible?(new_loc, chess_board)
      end
    end
    result
  end

  def mate?(chess_board)
    king = @chess_pieces['King0']
    return false if king.checked == false

    list_possible_move = possible_moves_without_checked(chess_board)
    result = list_possible_move.none? { |_key, value| value }
    puts "#{@name} is mated" if result == true

    result
  end

  def stalemate?(chess_board)
    king = @chess_pieces['King0']
    return false if king.checked == true

    list_possible_move = possible_moves_without_checked(chess_board)
    result = list_possible_move.none? { |_key, value| value }
    puts "#{@name} is stalemated" if result == true

    result
  end

  def replace_pawn_with_queen(chess_piece)
    piece_id_num = @chess_pieces.values.count { |piece| piece.name = 'Queen' }
    new_queen = Queen.new("Queen#{piece_id_num}", self)
    new_queen.moved = true
    new_queen.location = chess_piece.location
    @chess_pieces.delete(chess_piece.piece_id)
    @chess_pieces[new_queen.piece_id] = new_queen
    new_queen
  end
end
