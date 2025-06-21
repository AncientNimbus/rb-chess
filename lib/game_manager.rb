# frozen_string_literal: true

require_relative "console"
require_relative "player"
require_relative "base_game"
require_relative "connect_four"

# Console Game System v2.0.0
module ConsoleGame
  # Game Manager for Console game
  class GameManager
    include Console
    attr_reader :apps, :menu, :p1
    attr_accessor :running, :active_game

    def initialize(lang: "en")
      FileUtils.set_locale(lang)
      String.prevent_colors = true
      @running = true
      @apps = { "connect4" => method(:connect_four) }
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
      menu.show("console.ver")
      menu.show("console.boot")
      menu.show("console.menu")
    end

    # Run game: Connect Four
    def connect_four
      self.active_game = ConnectFour.new(self, menu)
      active_game.start
    end
  end
end
