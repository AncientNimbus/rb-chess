# frozen_string_literal: true

module ConsoleGame
  module Chess
    # FenExport is a helper module to perform FEN data export operations.
    # It is compatible with most online chess site, and machine readable.
    # @author Ancient Nimbus
    # @version v1.0.0
    module FenExport
      private

      # == FEN Export ==

      # FEN core export method
      # @return [String]
      def fen_export(**session_data) = to_fen(session_data)

      # Transform internal turn data to FEN string
      # @param turn_data [Array<ChessPiece, String>]
      # @param session_data [Hash]
      # @return [String]
      def to_fen(session_data)
        turn_data, white_turn, castling_states, en_passant, half_move, full_move =
          session_data.values_at(:turn_data, :white_turn, :castling_states, :en_passant, :half, :full)

        [to_turn_data(turn_data), to_active_color(white_turn), to_castling_states(castling_states),
         to_en_passant(en_passant), half_move.to_s, full_move.to_s].join(" ")
      end

      # Convert internal turn data to string
      # @param turn_data [Array<ChessPiece, String>]
      # @return [String] FEN position placements as string
      def to_turn_data(turn_data)
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
      # @param white_turn [Boolean]
      # @return [String]
      def to_active_color(white_turn) = white_turn ? "w" : "b"

      # Convert castling states to FEN castling status field
      # @param castling_states [Hash]
      # @return [String]
      def to_castling_states(castling_states)
        str = castling_states.reject { |_, v| v == false }.keys.map(&:to_s).join("")
        str.empty? ? "-" : str
      end

      # Convert en passant states to FEN en passant field
      # @param [Hash]
      # @return [String]
      def to_en_passant(en_passant) = en_passant.nil? ? "-" : en_passant.fetch(-1)
    end
  end
end
