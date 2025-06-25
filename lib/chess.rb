# frozen_string_literal: true

require_relative "base_game"

module ConsoleGame
  # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
  class Chess < BaseGame
    private

    def boot
      super
      show("app.chess.boot")
    end

    def setup_game
      handle_input("Type something")
    end
  end
end
