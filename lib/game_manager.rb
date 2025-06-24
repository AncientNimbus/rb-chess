# frozen_string_literal: true

require_relative "user_profile"
require_relative "console"
require_relative "console_menu"
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

    SUPPORTED_FILETYPE = %i[yml json pgn].freeze

    attr_reader :apps, :cli, :user
    attr_accessor :running, :active_game

    def initialize(lang: "en")
      F.set_locale(lang)
      @running = true
      @apps = { "chess" => method(:chess) }
      @cli = ConsoleMenu.new(self)
      @user = UserProfile.new
      @active_game = nil
    end

    # run the console game manager
    def run
      greet
      # Create or load user
      assign_user_profile
      # Enter lobby
      lobby
    end

    # Greet user
    def greet
      # %w[ver boot menu].map
      cli.show("cli.ver")
      cli.show("cli.boot")
      # cli.show("cli.menu")
    end

    # Setup user profile
    def assign_user_profile
      puts "Setting up user"
    end

    # Arcade lobby
    def lobby
      cli.handle_input(allow_empty: true) while running
    end

    # Exit Arcade
    def exit_arcade
      self.running = false
      exit
    end

    # Run game: Chess
    def chess
      puts "Should start chess"
      # self.active_game = Chess.new(self, cli)
      # active_game.start
    end
  end
end
