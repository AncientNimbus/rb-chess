# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Knight is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Knight < ChessPiece
      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :b1, side = :white)
        super(alg_pos, side, :n)
      end

      # Knight Movement via pathfinder
      # @param pos [Integer] board positional value
      # @param path [Symbol] compass direction
      # @param range [Symbol, Integer] movement range of the given piece
      # @return [Array<Integer>]
      def path(pos = 0, path = :e, range: 1)
        dirs_keys = DIRECTIONS.keys
        offset_dirs = dirs_keys.rotate(1)
        offset_pos = super(pos, offset_dirs[dirs_keys.index(path)], range: range).last
        return [] if offset_pos.nil?

        next_pos = super(offset_pos, path, range: range).last
        return [] if next_pos.nil?

        valid_moves?(pos, next_pos) ? [pos, next_pos] : []
      end

      # Valid movement for Knight
      # @param pos1 [Integer] original board positional value
      # @param pos2 [Integer] new board positional value
      # @return [Boolean]
      def valid_moves?(pos1, pos2)
        r1, c1, r2, c2 = [pos1, pos2].map { |pos| to_coord(pos) }.flatten

        ((r1 - r2).abs == 2 && (c1 - c2).abs == 1) || ((r1 - r2).abs == 1 && (c1 - c2).abs == 2)
      end
    end
  end
end
