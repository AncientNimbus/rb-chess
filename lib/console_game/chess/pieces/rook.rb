# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Rook is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Rook < ChessPiece
      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :a1, side = :white, level: nil)
        super(alg_pos, side, :r, movements: %i[n e s w], range: :max, level: level)
      end

      # Move the chess piece to a new valid location
      # @param new_alg_pos [Symbol, Integer] expects board position in Algebraic notation, e.g., :e3
      def move(new_alg_pos)
        disable_castling
        super
      end

      private

      # disable castling
      def disable_castling
        return unless at_start

        kingside = file == "h"
        query = kingside ? :k : :q
        query = query.upcase if side == :white
        level.castling_states[query] = false
      end
    end
  end
end
