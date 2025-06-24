# frozen_string_literal: true

require_relative "file_utils"
require_relative "console"

module ConsoleGame
  # Game menu manager for console game
  class ConsoleMenu
    include Console

    attr_reader :commands, :game_manager

    def initialize(game_manager = nil)
      @game_manager = game_manager
      @commands = { "exit" => method(:quit), "ttfn" => method(:quit),
                    "help" => method(:help), "play" => method(:play) }
      @input_is_cmd = false
    end

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

    # Display help string
    def help(_arr = [])
      show("cli.help")
    end

    # Launch a game
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

    # Exit sequences
    def quit(_arg = [])
      game_manager.running = false
      print_msg(F.s("cli.lobby.exit"))
      exit
    end
  end
end
