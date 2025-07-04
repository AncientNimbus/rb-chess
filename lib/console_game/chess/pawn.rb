# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Pawn is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Pawn < ChessPiece
      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :a2, side = :white, level: nil)
        super(alg_pos, side, :p, movements: %i[n ne nw], range: 1, level: level)
      end

      private

      # Override detect_occupied_tiles
      # Detect blocked tile based on the given positions
      # @param path [Symbol]
      # @param turn_data [Array] board data array
      # @param positions [Array] rank array
      # @return [Array]
      def detect_occupied_tiles(path, turn_data, positions)
        new_positions = super(path, turn_data, positions)
        tile_data = new_positions.empty? ? nil : turn_data[new_positions.first]
        if path == :n
          new_positions = [] if tile_data.is_a?(ChessPiece)
          targets[path] = nil
        elsif tile_data.is_a?(String)
          new_positions = []
        end
        new_positions
      end

      # Override path
      # Path via Pathfinder
      # @param pos [Integer] board positional value
      # @param path [Symbol] compass direction
      # @param range [Symbol, Integer] movement range of the given piece or :max for furthest possible range
      # @return [Array<Integer>]
      def path(pos = 0, path = :e, range: 1)
        range = 2 if at_start && path == :n
        super(pos, path, range: range)
      end
    end
  end
end
