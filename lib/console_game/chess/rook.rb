# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Rook is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Rook < ChessPiece
      def initialize
        super(:r, movements: %i[n e s w], range: :max)
      end
    end
  end
end
