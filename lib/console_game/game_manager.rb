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
      print_msg(*tf_fetcher("", *%w[.ver .boot], root: "cli"))
    end

    # Setup user profile
    def assign_user_profile
      print_msg(s("cli.new.msg"), pre: "* ")

      mode = base_input.ask(s("cli.new.msg2"), reg: [1, 2], input_type: :range).to_i
      @user = mode == 1 ? new_profile : load_profile
      # Create stats data
      launch_counter
      # Save to disk
      save_user_profile
    end

    # Arcade lobby
    def lobby
      print_msg(s("cli.menu"))
      cli.ask(empty: true) while running
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
      return puts "No user profile found, operation cancelled" if user.nil?

      user.save_profile
      print_msg(s("cli.save.msg", { dir: [user.filepath, :yellow] }))
    end

    # Load another profile when using is at the lobby
    def switch_user_profile
      return puts "No user profile found, operation cancelled" if user.nil?

      @user = load_profile
      launch_counter
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
      profile = UserProfile.new(username)

      # Welcome user
      print_msg(s("cli.new.msg4", { name: [profile.username, :yellow] }))
      profile
    end

    # Handle returning user
    def load_profile(extname: ".json")
      f_path = select_profile(extname: extname)
      # Load ops
      profile = f_path.nil? ? load_err(:no_profile) : UserProfile.load_profile(F.load_file(f_path, extname: extname))
      profile = profile.nil? ? load_err(:bad_profile) : UserProfile.new(profile[:username], profile)
      # Post-load ops
      print_msg(s("cli.load.msg3", { name: [profile.username, :yellow] }))
      profile
    end

    # Handle profile selection
    def select_profile(extname: ".json")
      print_msg(s("cli.load.msg"))

      folder_path = F.filepath("", "user_data")
      profiles = F.file_list(folder_path, extname: extname)
      return nil if profiles.empty?

      # Print the list
      print_file_list(folder_path, profiles)
      # Handle selection
      profile = base_input.pick_from(profiles, msg: s("cli.load.msg2"), err_msg: s("cli.load.input_err"))
      # Returns a valid filename
      folder_path + profile
    end

    # Edge cases handling when there are issue loading a profile
    # @param err_label [Symbol] control which error message to print
    def load_err(err_label = :no_profile)
      case err_label
      when :no_profile
        print_msg(s("cli.load.no_profile_err"), pre: "! ")
      when :bad_profile
        print_msg(s("cli.load.bad_file_err"), pre: "! ")
      else
        print_msg("Unknown err, creating a new profile now...", pre: "! ")
      end
      new_profile
    end

    # Get username from prompt
    # @return [String] username
    def grab_username
      base_input.ask(s("cli.new.msg3"), reg: F::FILENAME_REG, input_type: :custom, empty: true)
    end

    # Simple usage stats counting
    def launch_counter
      return puts "No user profile found, operation cancelled" if user.nil?

      user.profile[:stats][:launch_count] ||= 0
      user.profile[:stats][:launch_count] += 1
    end
  end
end
