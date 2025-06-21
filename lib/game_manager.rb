# frozen_string_literal: true

require_relative "console"
require_relative "player"
require_relative "base_game"
require_relative "chess"

# Console Game System v2.0.0
module ConsoleGame
  # Game Manager for Console game
  class GameManager
    include Console
    attr_reader :apps, :menu, :p1
    attr_accessor :running, :active_game

    def initialize(lang: "en")
      FileUtils.set_locale(lang)
      @running = true
      @apps = { "chess" => method(:chess) }
      @menu = ConsoleMenu.new(self)
      @p1 = Player.new(self)
      @active_game = nil
    end

    # run the console game manager
    def run
      greet
      # lobby
      menu.handle_input(allow_empty: true) while @running
    end

    # Greet user
    def greet
      menu.show("cli.ver")
      menu.show("cli.boot")
      menu.show("cli.menu")
    end

    # Run game: Chess
    def chess
      puts "Should start chess"
      # self.active_game = Chess.new(self, menu)
      # active_game.start
    end
  end
end
