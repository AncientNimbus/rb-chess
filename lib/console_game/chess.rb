# frozen_string_literal: true

require_relative "base_game"
require_relative "chess_input"

module ConsoleGame
  # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
  class Chess < BaseGame
    def initialize(game_manager = nil, title = "Base Game")
      super(game_manager, title, ChessInput.new(game_manager))
    end

    private

    def boot
      super
      print_msg(*tf_fetcher("chess", *%w[boot intro help], root: "app"))
    end

    def setup_game
      handle_input("Type something ", cmds: input.commands)
    end
  end
end
