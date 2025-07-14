# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The Piece Analysis module handles the turn actions within a chess level
    # @author Ancient Nimbus
    module PieceAnalysis
      private

      # Analyse the board
      # usable_pieces: usable pieces of the given turn
      # threats_map: all blunder tile for each side
      # @param pieces_groups [Hash<ChessPiece>]
      # @return [Array<Hash<ChessPiece>>] usable_pieces and threats_map
      def board_analysis(pieces_groups)
        usable_pieces = { white: [], black: [] }
        threats_map = { white: [], black: [] }
        pieces_groups.each do |side, pieces|
          threats_map[side] = add_pos_to_blunder_tracker(pieces)
          usable_pieces[side] = pieces.map { |piece| piece.info unless piece.possible_moves.empty? }.compact
        end
        [threats_map, usable_pieces]
      end

      # Helper: add blunder tiles to session variable
      # @param pieces [ChessPiece]
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
