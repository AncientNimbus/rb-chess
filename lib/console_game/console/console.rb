# frozen_string_literal: true

require_relative "../../nimbus_file_utils/nimbus_file_utils"

module ConsoleGame
  # Game display & input capturing for console game
  module Console
    # prompt message helper
    # @param msg [String] message to print
    # @param pre [String] message prefix
    # @param suf [String] message suffix
    # @param mode [Symbol] expecting the following symbols: `puts`, `print`, `p`
    def print_msg(msg = "Using message printer", pre: "", suf: "", mode: :puts, delay: 0)
      return ArgumentError("Invalid mode used for this method") unless %i[puts print p].include?(mode)

      sleep(delay) if delay.positive?
      formatted_msg = "#{pre}#{msg}#{suf}"
      method(mode).call(formatted_msg)
    end

    # process user input
    # @param msg [String] first print
    # @param cmds [Hash] expects a list of commands hash
    # @param err_msg [String] second print
    # @param reg [Regexp, String] pattern to match
    # @param empty [Boolean] allow empty input value, default to false
    def handle_input(msg = "", cmds: { "exit" => method(:exit) }, err_msg: F.s("cli.std_err"), reg: /.*/, empty: false)
      input = prompt_user(msg, err_msg: err_msg, reg: reg, allow_empty: empty)
      return input if input.empty?

      input_arr = input.split(" ")
      @input_is_cmd, is_valid, cmd = command?(input_arr[0], cmds)

      return input unless @input_is_cmd

      handle_command(cmd, input_arr[1..], cmds, is_valid)
      handle_input(msg, cmds: cmds, err_msg: err_msg, reg: reg, empty: empty)
    end

    # Helper method to create regexp pattern
    # @param cmd_pattern [String] command patterns
    # @param reg [String] pattern to match
    # @param pre [String] pattern prefix
    # @param suf [String] pattern suffix
    # @param flag [String, Regexp] regexp flag
    # @return [Regexp]
    def regexp_formatter(cmd_pattern = "--(exit).*?", reg = "reg", pre: '\A', suf: '\z', flag: "")
      Regexp.new("#{pre}(#{reg}|#{cmd_pattern})#{suf}", flag)
    end

    # Shorthand method: handle range selections prompt
    # @param cmd_pattern [String] command patterns
    # @param min [String, Integer] min range
    # @param max [String, Integer] max range (inclusive)
    # @param flag [String, Regexp] regexp flag
    # @return [Regexp]
    def regexp_range(cmd_pattern = "--(exit).*?", min: 1, max: 3, flag: "")
      regexp_formatter("[#{min}-#{max}]", cmd_pattern, flag: flag)
    end

    # Helper method to build regexp capturing group
    # @param reg [Array] elements
    # @param pre [String] pattern prefix
    # @param suf [String] pattern suffix
    # @return [String]
    def regexp_capturing_gp(reg = %w[reg abc], pre: "", suf: "")
      "#{pre}(#{reg.join('|')})#{suf}"
    end

    # Shorthand method: simple display
    # @param str [String] textfile key
    def show(str)
      print_msg(F.s(str))
    end

    # Shorthand method: Display with added prefix
    # @param str [String] textfile key
    # @param pre [String] message prefix
    def pretty_show(str, pre: "* ")
      print_msg(F.s(str), pre: pre)
    end

    private

    # prompt user to collect input
    # @param msg [String] first print
    # @param err_msg [String] second print
    # @param reg [Regexp] pattern to match
    # @param allow_empty [Boolean] allow empty input value, default to false
    # @return [String] user input
    def prompt_user(msg = "", err_msg: F.s("cli.std_err"), reg: /.*/, allow_empty: false)
      input = ""
      loop do
        print_msg("#{Paint['?', :green]} #{msg}#{F.s('cli.prompt_prefix')}", mode: :print)
        input = gets.chomp
        break if input.match?(reg) && (!input.empty? || allow_empty)

        msg = err_msg
      end
      input
    end

    # returns true if user input matches available commands
    # @param input [String] user input
    # @param commands [Array<String>] command string keys
    # @param flags [Array<String>] command pattern prefixes
    # @return [Boolean, Array<Boolean, String>] whether it is a command or not
    def command?(input, commands = %w[exit debug], flags: %w[--])
      clean_input = nil
      flags.each do |flag|
        clean_input = input.delete_prefix(flag) if input[0...flag.size] == flag
        break unless clean_input.nil?
      end
      return false if clean_input.nil?

      [true, commands.include?(clean_input), clean_input]
    end

    # Handle command
    # @param cmd [String]
    # @param opt_arg [String]
    # @param cmds [Array]
    # @param is_valid [Boolean]
    def handle_command(cmd, opt_arg, cmds, is_valid)
      return pretty_show("cli.cmd_err", pre: "! ") unless is_valid

      begin
        cmds.fetch(cmd).call(opt_arg)
      rescue TypeError
        cmd == "exit" ? cmds.fetch(cmd).call : raise(TypeError, "#{cmd} is missing optional argument: #{opt_arg}")
      end
    end
  end
end
