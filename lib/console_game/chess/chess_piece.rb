# frozen_string_literal: true

require_relative "../../nimbus_file_utils/nimbus_file_utils"
require_relative "logic"

module ConsoleGame
  module Chess
    # Chess Piece is a parent class for the game Chess in Console Game
    # @author Ancient Nimbus
    class ChessPiece
      include NimbusFileUtils
      include Logic

      # Points system for chess pieces
      PTS_VALUES = { k: 100, q: 9, r: 5, b: 5, n: 3, p: 1 }.freeze

      attr_accessor :start_pos
      attr_reader :notation, :name, :icon, :pts, :movements

      # @param notation [Symbol] expects a chess notation of a specific piece, e.g., Knight = :n
      def initialize(notation = :k, movements: %i[n ne e se s sw w nw], range: 1)
        @notation = s("#{notation}.notation")
        @name = s("#{notation}.name")
        @icon = s("#{notation}.style1")
        @pts = PTS_VALUES[notation]
        @start_pos = true
        @movements = possible_movements(movements, range: range)
      end

      # Calculate valid sequence based on positional value
      # @param pos [Integer] positional value within a matrix
      # @return [Hash<Array<Integer>>] an array of valid directional path within given bound
      def all_paths(pos = 0)
        paths = Hash.new { |h, k| h[k] = nil }
        movements.each do |path, range|
          next if range.nil?

          sequence = path(pos, path, range: range)
          paths[path] = sequence unless sequence.empty?
        end
        paths
      end

      # Path via Pathfinder
      # @param pos [Integer] board positional value
      # @param path [Symbol] compass direction
      # @param range [Symbol, Integer] movement range of the given piece or :max for furthest possible range
      # @return [Array<Integer>]
      def path(pos = 0, path = :e, range: 1)
        seq_length = range.is_a?(Integer) ? range + 1 : range
        path = pathfinder(pos, path, length: seq_length)
        path.size > 1 ? path : []
      end

      # Valid movement
      # @param pos1 [Integer] original board positional value
      # @param pos2 [Integer] new board positional value
      # @return [Boolean]
      def valid_moves?(pos1, pos2); end

      # == Utilities ==

      private

      # Possible movement direction for the given piece
      # @param directions [Array<Symbol>] possible paths
      # @param range [Symbol, Integer] movement range of the given piece or :max for furthest possible range
      def possible_movements(directions = [], range: 1)
        movements = Hash.new { |h, k| h[k] = nil }
        DIRECTIONS.each_key { |k| movements[k] }
        directions.each { |dir| movements[dir] = range }
        movements
      end

      # Override: s
      # Retrieves a localized string and perform String interpolation and paint text if needed.
      # @param key_path [String] textfile keypath
      # @param subs [Hash] `{ demo: ["some text", :red] }`
      # @param paint_str [Array<Symbol, String, nil>]
      # @param extname [String]
      # @return [String] the translated and interpolated string
      def s(key_path, subs = {}, paint_str: [nil, nil], extname: ".yml")
        super("app.chess.pieces.#{key_path}", subs, paint_str: paint_str, extname: extname)
      end
    end
  end
end
