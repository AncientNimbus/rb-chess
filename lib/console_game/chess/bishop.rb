# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Bishop is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Bishop < ChessPiece
      def initialize
        super(:b)
      end
    end
  end
end
