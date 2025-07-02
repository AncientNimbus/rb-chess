# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Bishop is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Bishop < ChessPiece
      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :c1, side = :white)
        super(alg_pos, side, :b, movements: %i[ne se sw nw], range: :max)
      end
    end
  end
end
