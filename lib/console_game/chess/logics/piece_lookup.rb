# frozen_string_literal: true

require_relative "../utilities/chess_utils"

module ConsoleGame
  module Chess
    # The Piece lookup class handles various piece fetching tasks
    # @author Ancient Nimbus
    class PieceLookup
      include ChessUtils
      # @!attribute [r] level
      #   @return [Level] current level
      # @!attribute [r] turn_data
      #   @return [Array<ChessPiece, String>] complete state of the current turn
      # @!attribute [r] player
      #   @return [ChessPlayer, ChessComputer] player of the current turn
      # @!attribute [r] choices
      #   @return [Array<String>] usable pieces available to the current player
      attr_reader :level, :turn_data, :usable_pieces, :player, :choices

      # @param level [Level] expects a Chess::Level class object
      def initialize(level)
        @level = level
        @turn_data = level.turn_data
        @usable_pieces = level.usable_pieces
        @player = level.player
        @choices = usable_pieces[player.side]
      end

      # Fetch a single chess piece
      # @param query [String] algebraic notation `"e4"`
      # @param bypass [Boolean] for internal use only, use this to bypass user-end validation
      # @return [ChessPiece]
      def fetch_piece(query, bypass: true)
        return nil unless bypass || choices.include?(query)

        turn_data[to_1d_pos(query)]
      end

      # Fetch a group of pieces notation from turn_data based on algebraic notation
      # @param query [Array<String>]
      # @return [Array<Array<ChessPiece>, Array<String>>]
      def group_fetch(query)
        pieces = []
        notations = query.flatten.map do |alg_pos|
          pieces << (piece = fetch_piece(alg_pos))
          piece.notation
        end
        [pieces, notations]
      end

      # Grab all pieces, only whites or only blacks
      # @param side [Symbol] expects :all, :white or :black
      # @param type [ChessPiece, King, Queen, Rook, Bishop, Knight, Pawn] limit selection
      # @return [Array<ChessPiece>] a list of chess pieces
      def fetch_all(side = :all, type: ChessPiece)
        turn_data.select { |tile| tile.is_a?(type) && (SIDES_SYM.include?(side) ? tile.side == side : true) }
      end

      # Lookup a piece based on its possible move position
      # @param side [Symbol] :black or :white
      # @param type [Symbol] expects a notation
      # @param target [String] expects a algebraic notation
      # @param file_rank [String] expects a file rank data
      # @return [ChessPiece, nil]
      def reverse_lookup(side, type, target, file_rank = nil)
        type = Chess.const_get(ALG_REF.dig(type, :class))
        result = refined_lookup(fetch_all(side, type:), side, to_1d_pos(target), file_rank)
        result.size > 1 ? nil : result[0]
      end

      private

      # Helper: Filter pieces by checking whether it is usable at the current term with file info for extra measure
      # @param filtered_pieces [Array<ChessPiece>]
      # @param side [Symbol] :black or :white
      # @param new_pos [Integer] expects a positional value
      # @param file_rank [String] expects a file rank data
      # @return [Array<ChessPiece>]
      def refined_lookup(filtered_pieces, side, new_pos, file_rank)
        filtered_pieces.select do |piece|
          next unless usable_pieces[side].include?(piece.info)

          piece.possible_moves.include?(new_pos) && (file_rank.nil? || piece.info.include?(file_rank))
        end
      end
    end
  end
end
