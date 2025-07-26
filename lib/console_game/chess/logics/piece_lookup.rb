# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The Piece lookup module handles various piece fetching tasks
    # @author Ancient Nimbus
    module PieceLookup
      # Fetch a single chess piece
      # @param query [String] algebraic notation `"e4"`
      # @param choices [Array<String>] usable pieces available to the current player
      # @param turn_data [Array<ChessPiece, String>] expects level turn_data array
      # @param alg_dict [#call] expects a method to convert query to board position
      # @param warn_msg [#call] User warning during bad input
      # @param bypass [Boolean] for internal use only, use this to bypass user-end validation
      # @return [ChessPiece]
      def fetch_piece(query, choices:, turn_data:, alg_dict:, warn_msg:, bypass: false)
        return warn_msg.call("level.err.notation") unless choices.include?(query) || bypass

        turn_data[alg_dict.call(query)]
      end

      # Fetch a group of pieces notation from turn_data based on algebraic notation
      # @param query [Array<String>]
      # @param choices [Array<String>] usable pieces available to the current player
      # @param turn_data [Array<ChessPiece, String>] expects level turn_data array
      # @param pieces [Array<ChessPiece>]
      # @return [Array<Array<ChessPiece>, Array<String>>]
      def group_fetch(query, choices:, turn_data:, pieces: [])
        notations = query.flatten.map do |alg_pos|
          pieces << (piece = fetch_piece(alg_pos, choices:, turn_data:, bypass: true))
          piece.notation
        end
        [pieces, notations]
      end

      # Grab all pieces, only whites or only blacks
      # @param side [Symbol] expects :all, :white or :black
      # @param type [ChessPiece, King, Queen, Rook, Bishop, Knight, Pawn] limit selection
      # @param turn_data [Array<ChessPiece, String>] expects level turn_data array
      # @return [Array<ChessPiece>] a list of chess pieces
      def fetch_all(side = :all, type:, turn_data:)
        turn_data.select { |tile| tile.is_a?(type) && (%i[black white].include?(side) ? tile.side == side : true) }
      end

      # Lookup a piece based on its possible move position
      # @param side [Symbol] :black or :white
      # @param type [Symbol] expects a notation
      # @param target [String] expects a algebraic notation
      # @param file_rank [String] expects a file rank data
      # @param usable_pieces [Hash] expects a usable_pieces hash from chess level
      # @param piece_lib [Hash] expects a FEN reference hash
      # @param alg_dict [#call] expects a method to convert query to board position
      # @return [ChessPiece, nil]
      def reverse_lookup(side, type, target, file_rank = nil, usable_pieces:, piece_lib:, alg_dict:)
        type = Chess.const_get(piece_lib.dig(type, :class))
        result = refined_lookup(fetch_all(side, type:), side, alg_dict.call(target), file_rank, usable_pieces:)
        result.size > 1 ? nil : result[0]
      end

      private

      # Helper: Filter pieces by checking whether it is usable at the current term with file info for extra measure
      # @param filtered_pieces [Array<ChessPiece>]
      # @param side [Symbol] :black or :white
      # @param new_pos [Integer] expects a positional value
      # @param file_rank [String] expects a file rank data
      # @param usable_pieces [Hash] expects a usable_pieces hash from chess level
      # @return [Array<ChessPiece>]
      def refined_lookup(filtered_pieces, side, new_pos, file_rank, usable_pieces:)
        filtered_pieces.select do |piece|
          next unless usable_pieces[side].include?(piece.info)

          piece.possible_moves.include?(new_pos) && (file_rank.nil? || piece.info.include?(file_rank))
        end
      end
    end
  end
end
