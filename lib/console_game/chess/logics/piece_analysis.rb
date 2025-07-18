# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The Piece Analysis module handles the overall stats of the chessboard
    # @author Ancient Nimbus
    module PieceAnalysis
      # Default hash pattern
      BW_HASH = {
        new_nil: -> { Hash.new { |h, k| h[k] = nil }.merge({ white: nil, black: nil }) },
        new_arr: -> { Hash.new { |h, k| h[k] = [] }.merge({ white: [], black: [] }) }
      }.freeze

      # Analyse the board
      # usable_pieces: usable pieces of the given turn
      # threats_map: all blunder tile for each side
      # @param all_pieces [Array<ChessPiece>]
      # @return [Array<Hash<ChessPiece>>] usable_pieces and threats_map
      def board_analysis(all_pieces)
        threats_map, usable_pieces = Array.new(2) { BW_HASH[:new_arr].call }
        pieces_group(all_pieces).each do |side, pieces|
          threats_map[side] = add_pos_to_blunder_tracker(pieces)
          usable_pieces[side] = pieces.map { |piece| piece.info unless piece.possible_moves.empty? }.compact
        end
        [threats_map, usable_pieces]
      end

      # Refresh possible move and split chess pieces into two group
      # @param all_piece [Array<ChessPiece>]
      # @return [Hash]
      def pieces_group(all_pieces)
        grouped_pieces = BW_HASH[:new_nil].call
        grouped_pieces[:white], grouped_pieces[:black] = all_pieces.partition { |piece| piece.side == :white }
        grouped_pieces
      end

      # Helper: add blunder tiles to session variable
      # @param pieces [ChessPiece]
      # @return [Set<Integer>]
      def add_pos_to_blunder_tracker(pieces)
        bad_moves = []
        pawns, back_row = pieces.partition { |piece| piece.is_a?(Pawn) }
        pawns.each { |piece| bad_moves << piece.sights }
        back_row.each do |piece|
          bad_moves << piece.sights
          bad_moves << piece.possible_moves.compact
        end
        bad_moves.flatten.sort.to_set
      end
    end
  end
end
