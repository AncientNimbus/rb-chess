# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # King is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class King < ChessPiece
      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :e1, side = :white, level: nil)
        super(alg_pos, side, :k, level: level)
      end
    end
  end
end
