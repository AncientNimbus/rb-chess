# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Pawn is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Pawn < ChessPiece
      def initialize
        super(:p, movements: %i[n], range: 1)
      end
    end
  end
end
