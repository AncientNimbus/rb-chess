# frozen_string_literal: true

require_relative "chess_utils"

module ConsoleGame
  module Chess
    # FenExport is a class that performs FEN data export operations.
    # It is compatible with most online chess site, and machine readable.
    # @author Ancient Nimbus
    # @version v1.1.0
    class FenExport
      include ChessUtils
      # Simulates the next possible moves for a given chess position.
      # @return [Array<Integer>] good moves
      def self.to_fen(...) = new(...).to_fen

      # @!attribute [r] turn_data
      #   @return [Array<ChessPiece, String>] complete state of the current turn
      # @!attribute [r] white_turn
      #   @return [Boolean]
      # @!attribute [r] castling_states
      #   @return [Hash]
      # @!attribute [r] en_passant
      #   @return [Hash]
      # @!attribute [r] half_move
      #   @return [Integer]
      # @!attribute [r] full_move
      #   @return [Integer]
      attr_reader :turn_data, :white_turn, :castling_states, :en_passant, :half_move, :full_move

      # @param level [Level] expects a Chess::Level class object
      def initialize(level)
        @level = level
        @turn_data = level.turn_data
        @white_turn = level.white_turn
        @castling_states = level.castling_states
        @en_passant = level.en_passant
        @half_move = level.half_move
        @full_move = level.full_move
      end

      # == FEN Export ==

      # FEN core export method
      # Transform internal turn data to FEN string
      # @return [String]
      def to_fen
        [to_turn_data, to_active_color, to_castling_states, to_en_passant, half_move.to_s, full_move.to_s].join(" ")
      end

      private

      # Convert internal turn data to string
      # @return [String] FEN position placements as string
      def to_turn_data
        str_arr = []
        turn_data.each_slice(8) do |row|
          compressed_row = compress_row_str(row_data_to_str(row))
          str_arr << compressed_row.join("")
        end
        str_arr.join("/").reverse
      end

      # Helper: Convert row data to string
      # @param row [Array<ChessPiece>]
      # @return [Array<String>]
      def row_data_to_str(row)
        row.map do |tile|
          if tile.is_a?(ChessPiece)
            notation = tile.notation
            tile.side == :white ? notation : notation.downcase
          else
            "0"
          end
        end
      end

      # Helper: Compress empty tile
      # @param row_str_arr [Array<String>]
      # @param [Array<String>]
      def compress_row_str(row_str_arr, count: 0, compressed_row: [])
        row_str_arr.reverse_each do |elem|
          if elem == "0"
            count += 1
          else
            compressed_row.push(count.to_s) if count.positive?
            compressed_row.push(elem)
            count = 0
          end
        end
        compressed_row.tap { |arr| arr.push(count.to_s) if count.positive? }
      end

      # Convert internal white_turn to FEN active colour field
      # @return [String]
      def to_active_color = white_turn ? "w" : "b"

      # Convert castling states to FEN castling status field
      # @return [String]
      def to_castling_states
        str = castling_states.reject { |_, v| v == false }.keys.map(&:to_s).join("")
        str.empty? ? "-" : str
      end

      # Convert en passant states to FEN en passant field
      # @return [String]
      def to_en_passant
        value = en_passant.nil? ? "-" : en_passant.fetch(-1)
        value = to_alg_pos(value) if value.is_a?(Integer)
        value
      end
    end
  end
end
