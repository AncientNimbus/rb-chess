# frozen_string_literal: true

require_relative "../nimbus_file_utils/nimbus_file_utils"
require_relative "console/console"

module ConsoleGame
  # Input class is a base class for various control layouts for ConsoleGame
  class Input
    include Console

    attr_reader :game_manager, :commands, :cmd_pattern

    # @param game_manager [ConsoleGame::GameManager]
    def initialize(game_manager = nil)
      @game_manager = game_manager
      @commands = setup_commands
      @cmd_pattern = regexp_capturing_gp(commands.keys, pre: "--", suf: ".*?")
      @input_is_cmd = false
    end

    # == Console Commands ==

    # Exit sequences | command patterns: `exit`
    def quit(_arg = [])
      pretty_show("cli.lobby.exit")
      exit
    end

    # Display help string | command pattern: `help`
    def help(_arr = [])
      print_msg("Type --exit to exit the program")
    end

    # Display system info | command pattern: `info`
    def info(_arr = [])
      pretty_show("cli.ver")
    end

    private

    # == Unities ==

    # Setup input commands
    def setup_commands
      { "exit" => method(:quit), "help" => method(:help), "info" => method(:info) }
    end
  end
end
