# frozen_string_literal: true

# Helper module to perform PGN file related operations.
# .pgn is a file type that stores detailed chess session data.
# It is compatible with most online chess site, and extremely readable.
# @author Ancient Nimbus
# @version v1.0.0
module PgnUtils
  class << self
    # Expects a hash and returns a string object with PGN formatting.
    # @param session [Hash] expects a single chess session, invalid moves data will result operation being cancelled.
    # @return [String]
    def to_pgn(session)
      return nil unless session.key?(:moves) || session.key?("moves")

      data = []
      moves = []
      session.each do |k, v|
        k = k.to_s.to_sym unless k.is_a?(Symbol)
        data << format_metadata(k, v) if k != :moves
        moves = format_moves(v) if k == :moves
      end

      <<~PGN
        #{data.join("\n")}

        #{moves.join(' ')}
      PGN
    end

    private

    # Helper to format PGN metadata
    # @param key [Symbol, String]
    # @param value [Object]
    # @return [String]
    def format_metadata(key, value)
      key = key.is_a?(Symbol) ? key.capitalize : key
      case value
      in String | Integer | Float
        "[#{key} \"#{value}\"]"
      in Time
        "[#{key} \"#{value.year}.#{value.mon}.#{value.day}\"]"
      else
        "[#{key} \"#{value}\"]"
      end
    end

    # Helper to format PGN moves
    # @param moves [Hash] expects moves in Algebraic notation format
    # @return [Array<String>]
    def format_moves(moves)
      moves.map { |k, v| "#{k}. #{v}" }
    end
  end
end
