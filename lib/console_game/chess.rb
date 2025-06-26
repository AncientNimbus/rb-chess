# frozen_string_literal: true

require_relative "base_game"

module ConsoleGame
  # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
  class Chess < BaseGame
    # Shorthand to build textfile string
    T = ->(*str) { "app.chess.#{str.join('.')}" }

    private

    def boot
      super
      print_msg(*tf_fetcher("chess", *%w[boot intro help], root: "app"))
    end

    def setup_game
      handle_input("Type something ")
    end
  end
end
