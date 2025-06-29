# frozen_string_literal: true

require "paint"

module ConsoleGame
  module Chess
    # Display module for the game Chess in Console Game
    module Display
      # Default design for the chessboard
      BOARD = {
        side: ->(num) { "║ #{num} ║" }
      }.freeze
      # Print the chessboard

      # Row formatter
      # @param row_num [Integer]
      # @param pieces [Array<String>]
      # @param color [Symbol, String]
      # @param bg_colors [Array<Symbol, String>]
      # @param cell_width [Integer] cell width
      # @param print_num [Boolean]
      # @return [Array<String>]
      def format_row(row_num, pieces, color = :black, bg_colors: %w[#ada493 #847b6a], cell_w: 3, print_num: false)
        arr = []
        bg1, bg2 = row_num.even? ? bg_colors : bg_colors.reverse
        side = BOARD[:side].call(print_num ? row_num : " ")
        8.times do |i|
          bg = i.even? ? bg1 : bg2
          arr << Paint[pieces[i % pieces.size].center(cell_w), color, bg]
        end
        row = arr.unshift(side).push(side).join("")
        [row]
      end
    end
  end
end
