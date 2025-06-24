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

    # == Core methods ==

    # process user input
    # @param msg [String] first print
    # @param err_msg [String] second print
    # @param reg [Regexp] pattern to match
    # @param allow_empty [Boolean] allow empty input value, default to false
    def handle_input(msg = "", err_msg: F.s("cli.std_err"), reg: /.*/, allow_empty: false)
      input = prompt_user(msg, err_msg: err_msg, reg: reg, allow_empty: allow_empty)
      return input if input.empty?

      input_arr = input.split(" ")
      @input_is_cmd, is_valid, cmd = command?(input_arr[0], commands)

      if @input_is_cmd
        is_valid ? commands[cmd].call(input_arr[1..]) : print_msg(F.s("cli.cmd_err"))
      else
        input
      end
    end

    # Display the console menu
    # @param str [String] textfile key
    def show(str)
      print_msg(F.s(str))
    end

    # Display with added prefix
    # @param str [String] textfile key
    # @param pre [String] message prefix
    def std_show(str, pre: "* ")
      print_msg(F.s(str), pre: pre)
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
      puts "should print username"
    end
  end
end
