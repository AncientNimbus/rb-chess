# frozen_string_literal: true

require_relative "../nimbus_file_utils/nimbus_file_utils"
require_relative "../console/console"
require_relative "input"
require_relative "console_menu"
require_relative "user_profile"
require_relative "player"
require_relative "base_game"
require_relative "chess/game"

# Console Game System v2.0.0
# @author Ancient Nimbus
# @version 2.0.0
module ConsoleGame
  # Game Manager for Console game
  class GameManager
    include Console
    include ::NimbusFileUtils

    # Alias for NimbusFileUtils
    F = NimbusFileUtils

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
      assign_user_profile
      lobby
    end

    # Exit Arcade
    def exit_arcade
      self.running = false
      user&.save_profile
      exit
    end

    # Save user profile
    # @param mute [Boolean] bypass printing when use at the background
    def save_user_profile(mute: false)
      return load_err(:no_profile2) if user.nil?

      user.save_profile
      print_msg(s("cli.save.msg", { dir: [user.filepath, :yellow] })) unless mute
    end

    # Load another profile when using is at the lobby
    def switch_user_profile
      return load_err(:no_profile2) if user.nil?

      @user = load_profile
      launch_counter
    end

    private

    # Greet user
    def greet
      tf_fetcher("", *%w[.guideline .boot], root: "cli").each do |msg|
        print_msg(msg)
        base_input.ask(s("cli.std_blank"), empty: true)
      end
    end

    # Arcade lobby
    def lobby
      print_msg(s("cli.menu"))
      cli.ask(empty: true) while running
    end

    # Define the app list
    def load_app_list = { "chess" => method(:chess) }

    # Run game: Chess
    def chess
      self.active_game = Chess::Game.new(self)
      active_game.start
      print_msg(s("app.chess.end.home"))
      self.active_game = nil
    end

    # Setup user profile
    def assign_user_profile
      print_msg(s("cli.new.msg"))
      mode = base_input.ask(s("cli.new.msg2"), reg: [1, 2], input_type: :range).to_i
      @user = mode == 1 ? new_profile : load_profile
      # Create stats data
      launch_counter
      # Save to disk
      save_user_profile
    end

    # Handle new user
    # @param username [String] username for UserProfile, skip prompt stage if it is provided
    # @return [UserProfile] user profile
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
    # @param extname [String] extension name
    # @return [UserProfile] user profile
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
    # @param extname [String] extension name
    # @return [String] filepath
    def select_profile(extname: ".json")
      print_msg(s("cli.load.msg"))

      folder_path = F.filepath("", "user_data")
      profiles = F.file_list(folder_path, extname: extname)
      return nil if profiles.empty?

      # Print the list
      print_msg(*build_file_list(folder_path, profiles, col1: s("cli.load.li_col1"), col2: s("cli.load.li_col2")))
      # Handle selection
      profile = base_input.pick_from(profiles, msg: s("cli.load.msg2"), err_msg: s("cli.load.input_err"))
      # Returns a valid filename
      folder_path + profile
    end

    # Edge cases handling when there are issue loading a profile
    # @param err_label [Symbol] control which error message to print
    # @return [UserProfile]
    def load_err(err_label = :no_profile)
      err_msgs ||= { no_profile: "cli.load.no_profile_err", no_profile2: "cli.load.no_profile_err2",
                     bad_profile: "cli.load.bad_file_err" }
      keypath = err_msgs.fetch(err_label, "cli.load.unknown_err")
      print_msg(s(keypath), pre: "! ")
      new_profile
    end

    # Get username from prompt
    # @return [String] username
    def grab_username = base_input.ask(s("cli.new.msg3"), reg: F::FILENAME_REG, input_type: :custom, empty: true)

    # Simple usage stats counting
    def launch_counter
      return load_err(:no_profile2) if user.nil?

      user.profile[:stats][:launch_count] ||= 0
      user.profile[:stats][:launch_count] += 1
    end
  end
end
