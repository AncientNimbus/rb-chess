# frozen_string_literal: true

module ConsoleGame
  # Game display & input capturing for console game
  module Console
    # Default message strings
    D_MSG = {
      msg: "Using message printer",
      err_msg: "Invalid input, please try again: ",
      prompt_prefix: ">>> ",
      query_prefix: "? ",
      warn_prefix: "! ",
      cmd_err: "Invalid commands, type --help to view all available commands.",
      cmd_pattern: "--(exit).*?"
    }.freeze

    # prompt message helper
    # @param msg [String] message to print
    # @param pre [String] message prefix
    # @param suf [String] message suffix
    # @param mode [Symbol] expecting the following symbols: `puts`, `print`, `p`
    def print_msg(msg = D_MSG[:msg], pre: "", suf: "", mode: :puts, delay: 0)
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
    def handle_input(msg = "", cmds: { "exit" => method(:exit) }, err_msg: D_MSG[:err_msg], reg: /.*/, empty: false)
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
    def regexp_formatter(cmd_pattern = D_MSG[:cmd_pattern], reg = "reg", pre: '\A', suf: '\z', flag: "")
      Regexp.new("#{pre}(#{reg}|#{cmd_pattern})#{suf}", flag)
    end

    # Shorthand method: handle range selections prompt, current number limit is up to 99.
    # @param cmd_pattern [String] command patterns
    # @param min [String, Integer] min range
    # @param max [String, Integer] max range (inclusive)
    # @param flag [String, Regexp] regexp flag
    # @return [Regexp]
    def regexp_range(cmd_pattern = D_MSG[:cmd_pattern], min: 1, max: 3, flag: "")
      block = "[#{min}-#{max}]"
      block = "[#{min}-9][0-#{max % 10}]?" if max.is_a?(Integer) && (max >= 10)

      regexp_formatter(cmd_pattern, block, flag: flag)
    end

    # Helper method to build regexp capturing group
    # @param reg [Array] elements
    # @param pre [String] pattern prefix
    # @param suf [String] pattern suffix
    # @return [String]
    def regexp_capturing_gp(reg = %w[reg abc], pre: "", suf: "")
      "#{pre}(#{reg.join('|')})#{suf}"
    end

    private

    # prompt user to collect input
    # @param msg [String] first print
    # @param err_msg [String] second print
    # @param reg [Regexp] pattern to match
    # @param allow_empty [Boolean] allow empty input value, default to false
    # @return [String] user input
    def prompt_user(msg = "", err_msg: D_MSG[:err_msg], reg: /.*/, allow_empty: false)
      input = ""
      loop do
        print_msg("#{Paint[D_MSG[:query_prefix], :green]} #{msg}#{D_MSG[:prompt_prefix]}", mode: :print)
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
      return print_msg(D_MSG[:cmd_err], pre: D_MSG[:warn_prefix]) unless is_valid

      begin
        cmds.fetch(cmd).call(opt_arg)
      rescue TypeError
        cmd == "exit" ? cmds.fetch(cmd).call : raise(TypeError, "#{cmd} is missing optional argument: #{opt_arg}")
      end
    end
  end
end
