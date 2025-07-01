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
      attr_reader :notation, :name, :icon, :pts

      # @param notation [Symbol] expects a chess notation of a specific piece, e.g., Knight = :n
      def initialize(notation = :q)
        @notation = s("#{notation}.notation")
        @name = s("#{notation}.name")
        @icon = s("#{notation}.style1")
        @pts = PTS_VALUES[notation]
        @start_pos = true
      end

      # Movements for the given pieces
      def movements
        # calculate possible movement
        p valid_moves(52, :max)
        # p valid_moves(52, 2)
        # p valid_moves(1, :max)
        # p 34
        # p to_coord(34)
        # p 8 - 4
        # p valid_moves(4, 1)
        # p valid_moves(0, 1)
      end

      # Recursively find the next value depending on direction
      # @param value [Integer] start value
      # @param path [Symbol] see DIRECTIONS for available options. E.g., :e for count from left to right
      # @param combination [Array<Integer>] default value is an empty array
      # @param length [Symbol, Integer] maximum range or custom length of the sequence
      # @param bound [Array<Integer>] grid size `[row, col]`
      # @return [Array<Integer>] array of numbers
      def direction(value = 0, path = :e, combination = nil, length: PRESET[:length], bound: PRESET[:bound])
        combination ||= [value]
        arr_size = combination.size
        return combination if arr_size == length

        next_value = DIRECTIONS.fetch(path) do |key|
          raise ArgumentError, "Invalid path: #{key}"
        end.call(value, arr_size, bound[0])

        combination << next_value

        if out_of_bound?(next_value, bound) || not_adjacent?(path, combination)
          return length == :max ? combination[0..-2] : []
        end

        direction(value, path, combination, length: length, bound: bound)
      end

      # == Utilities ==

      private

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
