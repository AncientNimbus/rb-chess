# frozen_string_literal: true

require "paint"

module ConsoleGame
  module Chess
    # Display module for the game Chess in Console Game
    module Display
      # Default design for the chessboard
      BOARD = {
        head: nil,
        side: ->(v) { "║ #{v} ║" },
        tail: nil,
        bg_theme: %w[#ada493 #847b6a]
      }.freeze

      # Print the chessboard
      def print_board
      end

      # Row formatter
      # @param row_num [Integer] row number
      # @param pieces [Array<Hash>] expects a 1-element(reprinting) or 8-elements array(In order)
      # @option pieces [String] :asset element in the cell
      # @option pieces [Symbol] :color colour of the element
      # @param colors [Array<Symbol, String>] Expects contrasting background colour
      # @param cell_w [Integer] width within each cell
      # @param show_r [Boolean] print ranks on the side?
      # @return [Array<String>] a complete row in a board
      def format_row(row_num, pieces, colors: BOARD[:bg_theme], cell_w: 3, show_r: false)
        arr = []
        # Light background colour, dark background colour
        bg1, bg2 = pattern_order(row_num, colors: colors)
        # Build individual cell
        8.times do |i|
          item = pieces[i % pieces.size]
          arr << Paint[item[:asset].center(cell_w), item[:color], i.even? ? bg1 : bg2]
        end
        # Build side borders
        side = [BOARD[:side].call(show_r ? row_num : " ")]
        [side.concat(arr, side).join("")]
      end

      private

      # Helper: Determine the checker order of a specific row
      # @param row_num [Integer] row number
      # @param colors [Array<Symbol, String>] Expects contrasting background colour
      # @return [Array<Symbol, String>] colour values
      def pattern_order(row_num, colors: BOARD[:bg_theme])
        row_num.even? ? colors : colors.reverse
      end
    end
  end
end
