# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Rook is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Rook < ChessPiece
      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :a1, side = :white)
        super(alg_pos, side, :r, movements: %i[n e s w], range: :max)
      end
    end
  end
end
