# frozen_string_literal: true

require_relative "player"

module ConsoleGame
  # Chess computer player class
  class ChessComputer < Player
    def initialize(game_manager = nil, name = "Computer")
      super(game_manager, name)
    end
  end
end
