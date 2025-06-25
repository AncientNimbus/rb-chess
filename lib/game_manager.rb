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

    # Save user profile
    def save_user_profile
      return "No user profile found, operation cancelled" if user.nil?

      user.save_profile
      print_msg(F.s("cli.save.msg", { dir: [user.filepath, :yellow] }))
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
      save_user_profile
      # Welcome user
      print_msg(F.s("cli.new.msg4", { name: [user.username, :yellow] }))
    end

    # # Handle returning user
    # def load_profile
    #   username = grab_username
    #   filename ||= F.formatted_filename(username)
    #   filepath ||= F.filepath(filename, "user_data")

    #   profile = F.load_file(filepath, format: :json)

    #   begin
    #     @user = UserProfile.new(username, profile) if profile.keys == PROFILE.keys
    #   rescue NoMethodError
    #     puts "No profile found, creating a new profile with the name: #{username}"
    #     new_profile(username)
    #   end
    # end
    # Handle returning user
    def load_profile(extname: ".json")
      show("cli.load.msg")

      filepath = F.filepath("", "user_data")
      profile_names = []
      count = 0
      dir = Dir.new(filepath).each_child do |f_name|
        next unless f_name.include?(extname)

        profile_names << f_name
        count += 1
        filename = File.basename(f_name, extname).ljust(20)
        mod_time = File.new(filepath + f_name).mtime.strftime("%m/%d/%Y %I:%M %p")
        puts "* [#{count}] - #{filename} | #{mod_time}"
      end

      reg = regexp_formatter("[1-#{profile_names.size}]")
      num = handle_input(F.s("cli.new.msg2"), reg: reg).to_i - 1

      profile = F.load_file(filepath + profile_names[num], extname: extname)

      begin
        @user = UserProfile.new(profile[:username], profile) if profile.keys == PROFILE.keys
      rescue NoMethodError
        puts "No profile found, creating a new profile with the name: #{username}"
        new_profile(username)
      end
    end

    # Get username from prompt
    # @return [String] username
    def grab_username
      reg = /\A[\sa-zA-Z0-9._-]+\z/
      handle_input(F.s("cli.new.msg3"), reg: reg, empty: true)
    end
  end
end
