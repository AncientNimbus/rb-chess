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
        p pathfinder
        # p valid_moves(52, 2)
        # p valid_moves(1, :max)
        # p 34
        # p to_coord(34)
        # p 8 - 4
        # p valid_moves(4, 1)
        # p valid_moves(0, 1)
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
