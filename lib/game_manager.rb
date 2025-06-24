# frozen_string_literal: true

require_relative "console"
require_relative "console_menu"
require_relative "user_profile"
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
      show("cli.ver")
      show("cli.boot")
    end

    # Setup user profile
    def assign_user_profile
      pretty_show("cli.new.msg")

      reg = regexp_formatter("[1-2]")
      mode = handle_input(F.s("cli.new.msg2"), reg: reg).to_i

      mode == 1 ? new_profile : load_profile
    end

    # Arcade lobby
    def lobby
      show("cli.menu")
      handle_input(cmds: cli.commands, empty: true) while running
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

    private

    # Handle new user
    def new_profile
      # Get username
      username = handle_input(F.s("cli.new.msg3"), empty: true)
      # Create user profile
      @user = UserProfile.new(username)
      # Save to disk
      user.save_profile
      # p user
      print_msg(F.s("cli.save.msg", { dir: ["#{user.filepath}.json", :yellow] }))
      print_msg(F.s("cli.new.msg4", { name: [user.username, :yellow] }))
    end

    # Handle returning user
    def load_profile
    end
  end
end
