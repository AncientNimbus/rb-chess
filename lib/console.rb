# frozen_string_literal: true

require_relative "file_utils"

module ConsoleGame
  # Game display & input manager for console game
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

    # prompt user to collect input
    # @param msg [String] first print
    # @param err_msg [String] second print
    # @param reg [Regexp] pattern to match
    # @param allow_empty [Boolean] allow empty input value, default to false
    # @return [String] user input
    def prompt_user(msg = "", err_msg: F.s("cli.std_err"), reg: /.*/, allow_empty: false)
      input = ""
      loop do
        print_msg("#{msg}#{F.s('cli.prompt_prefix')}", mode: :print)
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
    def command?(input, commands = %w[exit debug], flags: %w[-- -])
      case
      when input[0..1] == flags[0]
        input.delete_prefix!(flags[0])
      when input[0] == flags[1]
        input.delete_prefix!(flags[1])
      else
        return false
      end
      [true, commands.include?(input), input]
    end

    # Helper method to create regexp pattern
    # @param reg [String] pattern to match
    # @param cmd_pattern [String] command patterns
    # @param pre [String] pattern prefix
    # @param suf [String] pattern suffix
    # @param flag [String, Regexp] regexp flag
    # @return [Regexp]
    def regexp_formatter(reg = "reg", cmd_pattern = "--(exit|help|debug).*?", pre: '\A', suf: '\z', flag: "")
      Regexp.new("#{pre}(#{reg}|#{cmd_pattern})#{suf}", flag)
    end

    # Helper method to build regexp capturing group
    # @param reg [Array] elements
    # @param pre [String] pattern prefix
    # @param suf [String] pattern suffix
    # @return [String]
    def regexp_capturing_gp(reg = %w[reg abc], pre: "", suf: "")
      "#{pre}(#{reg.join('|')})#{suf}"
    end
  end
end
