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

    # Expected file types
    SUPPORTED_FILETYPES = %i[yml json pgn].freeze
    # Expected user profile structure
    PROFILE = { uuid: "", username: "", saved_date: Time, appdata: {}, stats: {} }.freeze

    attr_reader :apps, :cli, :user
    attr_accessor :running, :active_game

    def initialize(lang: "en")
      F.set_locale(lang)
      @running = true
      @apps = { "chess" => method(:chess) }
      @cli = ConsoleMenu.new(self)
      @user = nil
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
      user&.save_profile
      exit
    end

    # Run game: Chess
    def chess
      self.active_game = Chess.new(self)
      active_game.start
      puts "Welcome back to the lobby! Hope you have fun playing chess."
    end

    # Save user profile
    def save_user_profile
      return "No user profile found, operation cancelled" if user.nil?

      user.save_profile
      print_msg(F.s("cli.save.msg", { dir: [user.filepath, :yellow] }))
    end

    # Load another profile when using is at the lobby
    def switch_user_profile
      return "No user profile found, operation cancelled" if user.nil?

      load_profile
    end

    private

    # Handle new user
    # @param username [String] username for UserProfile, skip prompt stage if it is provided.
    def new_profile(username = "")
      # Get username
      username = username.empty? ? grab_username : username
      # Create user profile
      @user = UserProfile.new(username)
      # Save to disk
      launch_counter
      save_user_profile
      # Welcome user
      print_msg(F.s("cli.new.msg4", { name: [user.username, :yellow] }))
    end

    # Handle returning user
    def load_profile(extname: ".json")
      filepath = select_profile(extname: extname)

      profile = F.load_file(filepath, extname: extname)

      begin
        @user = UserProfile.new(profile[:username], profile) if profile.keys == PROFILE.keys
        launch_counter
        print_msg(F.s("cli.load.msg3", { name: [user.username, :yellow] }))
      rescue NoMethodError
        puts "No profile found, creating a new profile with the name: #{username}"
        new_profile(username)
      end
    end

    # Handle profile selection
    def select_profile(extname: ".json")
      show("cli.load.msg")

      folder_path = F.filepath("", "user_data")
      profile_names = F.file_list(folder_path, extname: extname)
      # Print the list
      F.print_file_list(folder_path, profile_names)
      reg = regexp_formatter("[1-#{profile_names.size}]")
      num = handle_input(F.s("cli.new.msg2"), reg: reg).to_i - 1

      folder_path + profile_names[num]
    end

    # Get username from prompt
    # @return [String] username
    def grab_username
      reg = /\A[\sa-zA-Z0-9._-]+\z/
      handle_input(F.s("cli.new.msg3"), reg: reg, empty: true)
    end

    # Simple usage stats counting
    def launch_counter
      return "No user profile found, operation cancelled" if user.nil?

      user.profile[:stats][:launch_count] ||= 0
      user.profile[:stats][:launch_count] += 1
    end
  end
end
