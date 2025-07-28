# frozen_string_literal: true

require "whirly"
require "paint"
require_relative "../nimbus_file_utils/nimbus_file_utils"
require_relative "../console/console"

module ConsoleGame
  # Input class is a base class for various control layouts for ConsoleGame
  class Input
    include Console
    include ::NimbusFileUtils

    attr_reader :game_manager, :commands, :cmd_pattern, :command_usage

    # @param game_manager [ConsoleGame::GameManager]
    def initialize(game_manager = nil)
      @game_manager = game_manager
      @commands = setup_commands
      @cmd_pattern = regexp_capturing_gp(commands.keys, pre: "--", suf: '(\s.*)?')
      @command_usage = Hash.new { |h, k| h[k] = 0 }
    end

    # == Core methods ==

    # Override: process user input
    # @param msg [String] first print
    # @param cmds [Hash] expects a list of commands hash
    # @param err_msg [String] second print
    # @param reg [Regexp, String, Array<String>] pattern to match, use an Array when input type is :range
    # @param empty [Boolean] allow empty input value, default to false
    # @param input_type [Symbol] expects the following option: :any, :range, :custom
    # @return [String]
    def ask(msg = "", cmds: commands, err_msg: s("cli.std_err"), reg: ".*", empty: false, input_type: :any)
      reg = case input_type
            when :range then regexp_range(cmd_pattern, min: reg[0], max: reg[1])
            when :custom then regexp_formatter(cmd_pattern, reg)
            else reg
            end
      # p "location: #{self.class}, reg: #{reg}"
      # p reg
      super(msg, cmds:, err_msg:, reg:, empty:)
    end

    # Process user input where bound checks are required
    # @param options [Array] a list of options
    # @param msg [String] first print
    # @param err_msg [String] second print
    # @return [Any] a valid element within the given array
    def pick_from(options, msg: "Pick from the following options: ", err_msg: "Not a valid option, try again.")
      until options.fetch(opt = ask(msg, reg: COMMON_REG[:digits], input_type: :custom, err_msg: err_msg).to_i - 1, nil)
        print_msg(err_msg, pre: Paint["! ", :red])
      end
      options[opt]
    end

    # == Console Commands ==

    # Exit sequences | command patterns: `exit`
    def quit(_args = []) = game_manager.nil? ? exit : game_manager.exit_arcade

    # Display help string | command pattern: `help`
    def help(_args = []) = print_msg(s("cli.std_help"))

    # Display system info | command pattern: `info`
    def info(_args = []) = print_msg(s("cli.ver", { ver: game_manager.ver }))

    private

    # == Unities ==

    # Setup input commands
    def setup_commands = { "exit" => method(:quit), "ttfn" => method(:quit), "help" => method(:help),
                           "info" => method(:info) }

    # Override: Handle command
    # @param cmd [String]
    # @param opt_arg [String]
    # @param cmds [Array]
    # @param is_valid [Boolean]
    # @param cmd_err [String] custom error message
    def handle_command(cmd, opt_arg, cmds, is_valid, cmd_err: s("cli.cmd_err"))
      command_usage[cmd.to_sym] += 1 if cmds.key?(cmd)
      super
    end
  end
end
