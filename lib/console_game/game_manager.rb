# frozen_string_literal: true

require_relative "../nimbus_file_utils/nimbus_file_utils"
require_relative "console/console"
require_relative "input"
require_relative "console_menu"
require_relative "user_profile"
require_relative "player"
require_relative "base_game"
require_relative "chess"

# Alias for NimbusFileUtils
F = NimbusFileUtils

# Console Game System v2.0.0
# @author Ancient Nimbus
# @version 2.0.0
module ConsoleGame
  # Game Manager for Console game
  class GameManager
    include Console
    include NimbusFileUtils

    # Expected file types
    SUPPORTED_FILETYPES = %i[yml json pgn].freeze
    # Expected user profile structure
    PROFILE = { uuid: "", username: "", saved_date: Time, appdata: {}, stats: {} }.freeze

    attr_reader :base_input, :cli, :apps, :user
    attr_accessor :running, :active_game

    def initialize(lang: "en")
      F.set_locale(lang)
      @running = true
      @base_input = Input.new(self)
      @cli = ConsoleMenu.new(self)
      @apps = load_app_list
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
      print_msg(s("cli.ver"))
      print_msg(s("cli.boot"))
    end

    # Setup user profile
    def assign_user_profile
      print_msg(s("cli.new.msg"), pre: "* ")

      reg = regexp_range(base_input.cmd_pattern, max: 2)
      mode = handle_input(s("cli.new.msg2"), cmds: base_input.commands, reg: reg).to_i

      mode == 1 ? new_profile : load_profile
    end

    # Arcade lobby
    def lobby
      print_msg(s("cli.menu"))
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
      self.active_game = nil
    end

    # Save user profile
    def save_user_profile
      return "No user profile found, operation cancelled" if user.nil?

      user.save_profile
      print_msg(s("cli.save.msg", { dir: [user.filepath, :yellow] }))
    end

    # Load another profile when using is at the lobby
    def switch_user_profile
      return "No user profile found, operation cancelled" if user.nil?

      load_profile
    end

    private

    # Define the app list
    def load_app_list
      { "chess" => method(:chess) }
    end

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
      print_msg(s("cli.new.msg4", { name: [user.username, :yellow] }))
    end

    # Handle returning user
    def load_profile(extname: ".json")
      filepath = select_profile(extname: extname)

      profile = F.load_file(filepath, extname: extname)

      begin
        @user = UserProfile.new(profile[:username], profile) if profile.keys == PROFILE.keys
        launch_counter
        print_msg(s("cli.load.msg3", { name: [user.username, :yellow] }))
      rescue NoMethodError
        puts "No profile found, creating a new profile with the name: #{username}"
        new_profile(username)
      end
    end

    # Handle profile selection
    def select_profile(extname: ".json")
      print_msg(s("cli.load.msg"))

      folder_path = F.filepath("", "user_data")
      profile_names = F.file_list(folder_path, extname: extname)
      # Print the list
      F.print_file_list(folder_path, profile_names)
      reg = regexp_range(base_input.cmd_pattern, max: profile_names.size)
      num = handle_input(s("cli.new.msg2"), cmds: base_input.commands, reg: reg).to_i - 1

      folder_path + profile_names[num]
    end

    # Get username from prompt
    # @return [String] username
    def grab_username
      reg = regexp_formatter(base_input.cmd_pattern, F::FILENAME_REG)
      handle_input(s("cli.new.msg3"), cmds: base_input.commands, reg: reg, empty: true)
    end

    # Simple usage stats counting
    def launch_counter
      return "No user profile found, operation cancelled" if user.nil?

      user.profile[:stats][:launch_count] ||= 0
      user.profile[:stats][:launch_count] += 1
    end
  end
end
