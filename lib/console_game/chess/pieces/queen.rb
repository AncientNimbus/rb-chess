# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Queen is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Queen < ChessPiece
      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      # @param level [Level] Chess::Level object
      def initialize(alg_pos = :d1, side = :white, level: nil) = super(alg_pos, side, :q, range: :max, level:)
    end
  end
end
