# frozen_string_literal: true

require "readline"

# Game display & input capturing for console game
# @author Ancient Nimbus
# @version v2.1.0
module Console
  # Default message strings
  D_MSG = { msg: "Using message printer", err_msg: "Invalid input, please try again: ",
            prompt_prefix: ">>> ", query_prefix: "? ", warn_prefix: "! ", gear_icon: "⛭ ",
            cmd_err: "Invalid command, type --help to view all available commands.",
            cmd_pattern: "--(exit).*?", v_sep: "| " }.freeze

  # prompt message helper
  # @param msgs [Array<String>] message to print
  # @param pre [String] message prefix
  # @param suf [String] message suffix
  # @param mode [Symbol] expecting the following symbols: `puts`, `print`, `p`
  # @param delay [Integer] add delay between message print
  # @param clear [Boolean] clear screen before print?
  # @return [nil]
  def print_msg(*msgs, pre: "", suf: "", mode: :puts, delay: 0, clear: false)
    return ArgumentError("Invalid mode used for this method") unless %i[puts print p].include?(mode)

    system("clear") if clear
    msgs.each do |msg|
      formatted_msg = "#{pre}#{msg}#{suf}"
      method(mode).call(formatted_msg)
      sleep(delay) if delay.positive?
    end
    nil
  end

  # process user input
  # @param msg [String] first print
  # @param cmds [Hash] expects a list of commands hash
  # @param err_msg [String] second print
  # @param reg [Regexp, String] pattern to match
  # @param empty [Boolean] allow empty input value, default to false
  # @return [String]
  def ask(msg = "", cmds: { "exit" => method(:exit) }, err_msg: D_MSG[:err_msg], reg: /.*/, empty: false)
    input = prompt_user(msg, err_msg: err_msg, reg: reg, empty: empty)
    return input if input.empty?

    input_arr = input.split(" ")
    @input_is_cmd, is_valid, cmd = command?(input_arr[0], cmds)

    return input unless @input_is_cmd

    handle_command(cmd, input_arr[1..], cmds, is_valid)
    ask(msg, cmds:, err_msg:, reg:, empty:)
  end

  # Build table
  # @param data [Hash<String>] data
  # @param head [String] the title of the table
  def build_table(data: {}, head: "Console Table")
    data_values = data.values.map(&:values)
    return "Non-string elements found, ops cancelled." unless data_values.all? { |_, v| v.is_a?(String) }

    prefix_size, max_length = table_formatter(data_values)
    build_header(data, head, prefix_size, max_length) + build_rows(data_values, max_length - prefix_size)
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
  def regexp_capturing_gp(reg = %w[reg abc], pre: "", suf: "") = "#{pre}(#{reg.join('|')})#{suf}"

  private

  # prompt user to collect input
  # @param msg [String] first print
  # @param err_msg [String] second print
  # @param reg [Regexp] pattern to match
  # @param empty [Boolean] allow empty input value, default to false
  # @return [String] user input
  def prompt_user(msg = "", err_msg: D_MSG[:err_msg], reg: /.*/, empty: false)
    input = ""
    query_symbol = Paint[D_MSG[:query_prefix], :green]
    loop do
      prompt_msg = "#{query_symbol}#{msg}#{D_MSG[:prompt_prefix]}"
      input = Readline.readline(prompt_msg, true)
      break if met_requirement?(input, reg, empty)

      query_symbol = Paint[D_MSG[:warn_prefix], :red]
      msg = err_msg
    end
    input.rstrip
  end

  # Handle prompt exit condition in a more precises manner
  # @param input [String] user input to verify
  # @param reg [Regexp] pattern to match
  # @param empty [Boolean] allow empty input value, default to false
  # @return [Boolean] true when requirement is met
  def met_requirement?(input, reg, empty) = input.match?(reg) || (input.empty? if empty)

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
  # @param cmd_err [String] custom error message
  def handle_command(cmd, opt_arg, cmds, is_valid, cmd_err: D_MSG[:cmd_err])
    return print_msg(cmd_err, pre: Paint[D_MSG[:warn_prefix], :red]) unless is_valid

    begin
      cmds.fetch(cmd).call(opt_arg)
    rescue TypeError
      cmd == "exit" ? cmds.fetch(cmd).call : raise(TypeError, "#{cmd} is missing optional argument: #{opt_arg}")
    end
  end

  # == Build table helper ==

  # Helper: Table formatter
  # @param data_arr [Array<String>]
  # @return [Array]
  def table_formatter(data_arr)
    row_counts = data_arr.size
    prefix_size = ol_prefix(row_counts).size
    auto_pad = row_counts * 2 + D_MSG[:v_sep].size
    max_length = data_arr.map { |arr| arr.max_by(&:size) }.sum(&:size) + auto_pad + prefix_size
    max_length = 80 if max_length > 80
    [prefix_size, max_length]
  end

  # Helper: Build Header row
  # @return [Array<String>]
  def build_header(data, head, prefix_size, row_length)
    tb_col_heads = data.values[0].keys.map { |title| title.to_s.capitalize }
    col_heads = tb_col_heads.join(D_MSG[:v_sep].rjust(row_length - prefix_size * 3))
    separator = horizontal_line(row_length)
    [head, separator, col_heads, separator]
  end

  # Helper: Build table row
  # @param data_arr [Array<String>]
  # @param tb_rows [Array<String>]
  # @return [Array<String>]
  def build_rows(data_arr, row_length, tb_rows = [])
    data_arr.each_with_index do |entry, i|
      last_col = entry[-1]
      cols = entry[0].ljust(row_length - last_col.size)
      tb_rows << "#{ol_prefix(i)}#{cols}#{last_col}"
    end
    tb_rows
  end

  # Helper: Ordered list prefix builder
  # @param idx [Integer]
  # @return [String]
  def ol_prefix(idx) = "* [#{idx + 1}] - "

  # Helper: Build horizontal line
  # @param length [Integer]
  # @return [String]
  def horizontal_line(length) = "-" * length
end
