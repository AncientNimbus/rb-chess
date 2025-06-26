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
      %w[boot intro help].each { |key| show(T.call(key)) }
    end

    def setup_game
      handle_input("Type something")
    end
  end
end
