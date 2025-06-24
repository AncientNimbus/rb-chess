# frozen_string_literal: true

require_relative "file_utils"
require_relative "console"

module ConsoleGame
  # Game menu manager for console game
  class ConsoleMenu
    include Console

    attr_reader :commands, :cmd_pattern, :game_manager

    # @param game_manager [ConsoleGame::GameManager]
    def initialize(game_manager = nil)
      @game_manager = game_manager
      @commands = { "exit" => method(:quit), "ttfn" => method(:quit), "help" => method(:help), "info" => method(:info),
                    "save" => method(:save), "load" => method(:load), "play" => method(:play), "self" => method(:self) }
      @cmd_pattern = regexp_capturing_gp(commands.keys, pre: "--", suf: ".*?")
      @input_is_cmd = false
    end

    # == Console Commands ==

    # Exit sequences | command patterns: `exit`, `ttfn`
    def quit(_arg = [])
      print_msg(F.s("cli.lobby.exit"))
      game_manager.exit_arcade
    end

    # Display help string | command pattern: `help`
    def help(_arr = [])
      show("cli.help")
    end

    # Display system info | command pattern: `info`
    def info(_arr = [])
      show("cli.menu")
    end

    # Save user profile to disk | command pattern: `save`
    def save(_arr = [])
      puts "Saving user profile..."
      game_manager.user.profile[:saved_date] = Time.now.ceil
      game_manager.user.save_profile
    end

    # Load user profile from disk | command pattern: `load`
    def load(_arr = [])
      puts "Fetching user profile..."
    end

    # Launch a game | command pattern: `play <launch code>`
    # @param arr [Array<String>] optional arguments
    def play(arr = [])
      return print_msg(F.s("cli.play.gm_err")) unless game_manager

      app_name = arr[0]
      if game_manager.apps.key?(app_name)
        game_manager.apps[app_name].call
      else
        print_msg(F.s("cli.play.run_err"))
      end
    end

    # Display user info | command pattern: `self`
    def self(_arr = [])
      puts game_manager.user.profile
    end
  end
end
