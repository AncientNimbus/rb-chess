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
        super(alg_pos, side, :p, movements: %i[n], range: 2, level: level)
      end
    end
  end
end
