# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Knight is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Knight < ChessPiece
      def initialize
        super(:n)
      end

      # Knight Movement via pathfinder
      # @param pos [Integer] board positional value
      # @param path [Symbol] compass direction
      # @return [Array<Integer>]
      def explore_path(pos = 0, path = :e)
        dirs_keys = DIRECTIONS.keys
        offset_dirs = dirs_keys.rotate(1)
        length = 2
        offset_pos = pathfinder(pos, offset_dirs[dirs_keys.index(path)], length: length).last
        return [] if offset_pos.nil?

        next_pos = pathfinder(offset_pos, path, length: length).last
        return [] if next_pos.nil?

        [pos, next_pos]
      end

      # Valid movement for Knight
      # @param pos1 [Integer] original board positional value
      # @param pos2 [Integer] new board positional value
      # @return [Boolean]
      def valid_moves?(pos1, pos2)
        r1, c1 = to_coord(pos1)
        r2, c2 = to_coord(pos2)

        ((r1 - r2).abs == 2 && (c1 - c2).abs == 1) || ((r1 - r2).abs == 1 && (c1 - c2).abs == 2)
      end
    end
  end
end
