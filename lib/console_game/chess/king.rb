# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # King is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class King < ChessPiece
      def initialize
        super(:k)
      end
    end
  end
end
