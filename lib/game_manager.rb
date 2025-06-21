# frozen_string_literal: true

require_relative "user_profile"
require_relative "console"
require_relative "player"
require_relative "base_game"
require_relative "chess"

# Alias for NimbusFileUtils
F = NimbusFileUtils

# Console Game System v2.0.0
module ConsoleGame
  # Game Manager for Console game
  class GameManager
    include Console
    attr_reader :apps, :menu, :user
    attr_accessor :running, :active_game

    def initialize(lang: "en")
      F.set_locale(lang)
      @running = true
      @apps = { "chess" => method(:chess) }
      @menu = ConsoleMenu.new(self)
      @user = UserProfile.new
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
      # %w[ver boot menu].map
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
