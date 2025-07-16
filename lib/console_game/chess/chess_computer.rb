# frozen_string_literal: true

require_relative "chess_player"

module ConsoleGame
  module Chess
    # Chess computer player class
    class ChessComputer < ChessPlayer
      def initialize(name = "Computer")
        super(name)
      end

      # Play a turn in chess as an AI player
      def play_turn
        p "Computer's move"
      end
    end
  end
end
