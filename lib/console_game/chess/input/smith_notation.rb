# frozen_string_literal: true

module ConsoleGame
  module Chess
    # Module to parse Smith notation
    module SmithNotation
      # Smith Input Regexp pattern
      # The first capture group is used to support move preview mode
      # The second capture group is used to support direct move and place
      SMITH_PATTERN = {
        base: "(?:[a-h][1-8])|(?:[a-h][1-8]){2}", promotion: "(?:[qrbn])"
      }.freeze

      # Smith regexp pattern parser
      SMITH_PARSER = /[a-z]\d*/

      private

      # == Smith notation ==

      # Input validation when input scheme is set to Smith notation
      # @param input [String] input value from prompt
      # @return [Hash] a command pattern hash
      def validate_smith(input)
        case input.scan(SMITH_PARSER)
        in [curr_pos] then { type: :preview_move, args: [curr_pos] }
        in [curr_pos, new_pos] then { type: :direct_move, args: [curr_pos, new_pos] }
        in [curr_pos, new_pos, notation] then { type: :direct_promote, args: [curr_pos, new_pos, notation] }
        else { type: :invalid_input, args: [input] }
        end
      end

      # == Utilities ==

      # Smith Regexp pattern builder
      # @return [String]
      def regexp_smith
        "#{SMITH_PATTERN.values.join('')}?"
      end
    end
  end
end
