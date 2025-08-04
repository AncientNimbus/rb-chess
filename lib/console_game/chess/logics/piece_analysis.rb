# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The Piece Analysis class calculates the overall state of the chessboard
    # @author Ancient Nimbus
    class PieceAnalysis
      class << self
        # Analyse the board
        # @return [Hash] Board analysis data
        #   @option return [Hash<Symbol, Set<Integer>>] :threats_map Threatened squares by side
        #   @option return [Hash<Symbol, Array<String>>] :usable_pieces Movable piece positions by side
        def board_analysis(...) = new(...).board_analysis

        # Returns a hash with :white and :black keys to nil.
        # @return [Hash<nil>]
        def bw_nil_hash = { white: nil, black: nil }

        # Returns a Hash with default values as empty arrays, and initial keys :white and :black set to empty arrays.
        # @return [Hash<Array>]
        def bw_arr_hash = Hash.new { |h, k| h[k] = [] }.merge({ white: [], black: [] })
      end

      # @!attribute [r] all_pieces
      #   @return [Array<ChessPiece>] All the ChessPiece that's currently on the board
      attr_reader :all_pieces

      # @param all_pieces [Array<ChessPiece>]
      def initialize(all_pieces)
        @all_pieces = all_pieces
      end

      # Analyse the board
      # usable_pieces: usable pieces of the given turn
      # threats_map: all blunder tile for each side
      # @return [Hash] Board analysis data
      def board_analysis
        threats_map, usable_pieces = Array.new(2) { PieceAnalysis.bw_arr_hash }
        pieces_group.each do |side, pieces|
          threats_map[side] = add_pos_to_blunder_tracker(pieces)
          usable_pieces[side] = pieces.map { |piece| piece.info unless piece.possible_moves.empty? }.compact
        end
        { threats_map:, usable_pieces: }
      end

      private

      # Split chess pieces into two group
      # @return [Hash]
      def pieces_group
        grouped_pieces = PieceAnalysis.bw_nil_hash
        grouped_pieces[:white], grouped_pieces[:black] = all_pieces.partition { |piece| piece.side == :white }
        grouped_pieces
      end

      # Helper: add blunder tiles to session variable
      # @param pieces [ChessPiece]
      # @return [Set<Integer>]
      def add_pos_to_blunder_tracker(pieces)
        pawns, back_row = pieces.partition { |piece| piece.is_a?(Pawn) }
        bad_moves = pawns_threat(pawns) + back_rows_threat(back_row)
        bad_moves.flatten.sort.to_set
      end

      # Helper: Add pawn pieces's threat to map
      # @param pawns [Pawn]
      # @return [Array<Integer>]
      def pawns_threat(pawns) = pawns.map { |unit| unit.sights + unit.targets.values.compact }

      # Helper: Add back row pieces's threat to map
      # @param back_row [King, Queen, Bishop, Knight, Rook]
      # @return [Array<Integer>]
      def back_rows_threat(back_row) = back_row.map { |unit| unit.sights + unit.possible_moves.compact }
    end
  end
end
