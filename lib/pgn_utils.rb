# frozen_string_literal: true

# Helper module to perform PGN file related operations.
# .pgn is a file type that stores detailed chess session data.
# It is compatible with most online chess site, and extremely readable.
# @author Ancient Nimbus
# @version v1.0.0
module PgnUtils
  # Essential tags in PGN
  TAGS = { event: nil, site: nil, date: nil, round: nil, white: nil, black: nil, result: nil }.freeze
  # Optional tags in PGN
  OPT_TAGS = { annotator: nil, plyCount: nil, timeControl: nil, termination: nil, mode: nil, fen: nil }.freeze

  class << self
    # Convert pgn data file to usable hash
    # @param pgn_data [String]
    # @return [Hash] internal session data object
    def parse_pgn(pgn_data)
      metadata, others = pgn_data.lines.partition { |elem| elem.chomp!.start_with?("[") }
      session = { moves: nil }
      metadata.each do |elem|
        k, v = parse_pgn_metadata(elem)
        session[k] = v
      end
      session[:moves] = parse_pgn_moves(others)
      # p metadata
      p session
      # p session[:moves]
      # p others
    end

    # Expects a hash and returns a string object with PGN formatting.
    # @param session [Hash] expects a single chess session, invalid moves data will result operation being cancelled.
    # @return [String]
    def to_pgn(session)
      return nil unless session.key?(:moves)

      data = []
      moves = []
      result = session.fetch(:result)
      session.each do |k, v|
        data << format_metadata(k, v) if k != :moves
        moves = format_moves(v, result) if k == :moves
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

    # Helper to turn metadata string to key, value array pair
    # @param elem [String] expects a single metadata element
    # @return [Array] key, value pair
    def parse_pgn_metadata(elem)
      str_data = elem.delete('"[]').split
      key, value = str_data.partition { |part| str_data.index(part).zero? }
      key = key.join.downcase.to_sym
      value = if key == :date
                handle_date(value[0])
              else
                value.join(" ")
              end
      [key, value]
    end

    # Helper to try convert string value to a date, if it fails, returns a incomplete date as string
    # @param str_date [String]
    # @return [Time]
    def handle_date(str_date)
      y, m, d = str_date.tr(".", " ").split
      Time.new(y, m, d)
    rescue ArgumentError
      y, m, d = [y, m, d].map { |elem| elem.to_i.zero? ? 1 : elem }
      Time.new(y, m, d)
    end

    # Helper to format PGN moves
    # @param moves [Hash] expects moves in Algebraic notation format
    # @param result [String, nil] session result, if any.
    # @return [Array<String>]
    def format_moves(moves, result = nil)
      moves_arr = moves.map { |k, v| "#{k}. #{v}" }
      moves_arr << result unless result.nil?
      moves_arr
    end

    # Helper to turn pgn moves data to key, value array pair
    # @param moves_data [String]
    # @return [Array]
    def parse_pgn_moves(moves_data)
      moves_data.join(" ").split
    end
  end
end
