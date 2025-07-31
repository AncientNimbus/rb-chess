# frozen_string_literal: true

require_relative "chess_utils"

module ConsoleGame
  module Chess
    # Move Formatter is a class that convert legal chess move to PGN standard
    # It is compatible with most online chess site, and machine readable.
    # @author Ancient Nimbus
    class MoveFormatter
      include ChessUtils

      # @return [String]
      def self.to_pgn_move(...) = new(...).to_pgn_move

      # @!attribute [r] player
      #   @return [ChessPlayer, ChessComputer]
      # @!attribute [r] piece
      #   @return [ChessPiece]
      # @!attribute [r] last_move
      #   @return [String]
      attr_reader :player, :piece, :last_move

      # @param player [ChessPlayer, ChessComputer]
      # @param active_piece [ChessPiece]
      def initialize(player, active_piece)
        @player = player
        @piece = active_piece
        @last_move = active_piece.last_move
      end

      # Convert player move into pgn move
      # @return [String]
      def to_pgn_move
        last_move
      end

      private

      # # Convert internal turn data to string
      # # @return [String] FEN position placements as string
      # def to_turn_data
      #   str_arr = []
      #   turn_data.each_slice(8) do |row|
      #     compressed_row = compress_row_str(row_data_to_str(row))
      #     str_arr << compressed_row.join("")
      #   end
      #   str_arr.join("/").reverse
      # end
    end
  end
end
