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

      private

      # == Smith notation ==

      # Input validation when input scheme is set to Smith notation
      # @param output [String] output value from prompt
      def validate_smith(output)
        case output.scan(input_parser)
        in [curr_pos] then { type: :preview_move, args: [curr_pos] }
        in [curr_pos, new_pos] then { type: :direct_move, args: [curr_pos, new_pos] }
        in [curr_pos, new_pos, notation] then { type: :direct_promote, args: [curr_pos, new_pos, notation] }
        end
      end

      # == Utilities ==

      # Algebraic Regexp pattern builder
      # @return [String]
      def regexp_smith
        "#{SMITH_PATTERN.values.join('')}?"
      end
    end
  end
end
