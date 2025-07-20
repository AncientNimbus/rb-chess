# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Bishop is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Bishop < ChessPiece
      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      # @param level [Level] Chess::Level object
      def initialize(alg_pos = :c1, side = :white, level: nil)
        super(alg_pos, side, :b, movements: %i[ne se sw nw], range: :max, level: level)
      end
    end
  end
end
