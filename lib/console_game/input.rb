# frozen_string_literal: true

require_relative "../nimbus_file_utils/nimbus_file_utils"
require_relative "../console/console"

module ConsoleGame
  # Input class is a base class for various control layouts for ConsoleGame
  class Input
    include Console
    include ::NimbusFileUtils

    attr_reader :game_manager, :commands, :cmd_pattern

    # @param game_manager [ConsoleGame::GameManager]
    def initialize(game_manager = nil)
      @game_manager = game_manager
      @commands = setup_commands
      @cmd_pattern = regexp_capturing_gp(commands.keys, pre: "--", suf: '(\s.*)?')
      @input_is_cmd = false
    end

    # == Core methods ==

    # Override: process user input
    # @param msg [String] first print
    # @param cmds [Hash] expects a list of commands hash
    # @param err_msg [String] second print
    # @param reg [Regexp, String, Array<String>] pattern to match, use an Array when input type is :range
    # @param empty [Boolean] allow empty input value, default to false
    # @param input_type [Symbol] expects the following option: :any, :range, :custom
    def ask(msg = "", cmds: commands, err_msg: s("cli.std_err"), reg: ".*", empty: false, input_type: :any)
      reg = case input_type
            when :range
              regexp_range(cmd_pattern, min: reg[0], max: reg[1])
            when :custom
              regexp_formatter(cmd_pattern, reg)
            else
              reg
            end
      # p "location: #{self.class}, reg: #{reg}"
      # p reg
      super(msg, cmds: cmds, err_msg: err_msg, reg: reg, empty: empty)
    end

    # Process user input where bound checks are required
    # @param options [Array] a list of options
    # @param msg [String] first print
    # @param err_msg [String] second print
    # @param min [Index] minimum bound
    # @return [Any] a valid element within the given array
    def pick_from(options, msg: "Pick from the following options: ", err_msg: "Not a valid option, try again.", min: 1)
      max = options.size
      until options.fetch(opt = ask(msg, reg: [min, max], input_type: :range, err_msg: err_msg).to_i - 1, nil)
        print_msg(err_msg, pre: Paint["! ", :red])
      end
      options[opt]
    end

    private

    # == Console Commands ==

    # Exit sequences | command patterns: `exit`
    def quit(_arg = [])
      print_msg(s("cli.lobby.exit"))
      exit
    end

    # Display help string | command pattern: `help`
    def help(_arr = [])
      print_msg("Type --exit to exit the program")
    end

    # Display system info | command pattern: `info`
    def info(_arr = [])
      print_msg(s("cli.ver"))
    end

    # == Unities ==

    # Setup input commands
    def setup_commands
      { "exit" => method(:quit), "help" => method(:help), "info" => method(:info) }
    end
  end
end
