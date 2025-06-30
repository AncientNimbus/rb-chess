# frozen_string_literal: true

require "paint"

module ConsoleGame
  module Chess
    # Display module for the game Chess in Console Game
    module Display
      # Default design for the chessboard
      BOARD = {
        bg_theme: %w[#ada493 #847b6a],
        file: [*"a".."h"],
        std_tile: 3,
        xl_tile: 7,
        h: "═",
        decor1: "◆", decor2: "◇",
        head_l: "╔═══╦", head_r: "╦═══╗",
        sep_l: "╠═══╬", sep_r: "╬═══╣",
        tail_l: "╚═══╩", tail_r: "╩═══╝",
        side: ->(v) { "║ #{v} ║" }
      }.freeze

      # Build the chessboard
      # @param colors [Array<Symbol, String>] Expects contrasting background colour
      # @param size [Integer] padding size
      # @param show_r [Boolean] print ranks on the side?
      # @return [Array<String>] a complete board with head and tail
      def build_board(turn_data = Array.new(8) { [" "] }, colors: BOARD[:bg_theme], size: 1, show_r: true)
        tile_w = to_quadratic(size)
        board = []
        # top
        board << frame(:head, tile_w: tile_w, show_r: show_r, label: BOARD[:decor2])
        # main
        turn_data.each_with_index do |row, i|
          rank_num = i + 1
          rank_row = format_row(rank_num, row, colors: colors, tile_w: tile_w, show_r: show_r)
          buffer_row = [format_row(rank_num, [" "], colors: colors, tile_w: tile_w, show_r: false)] * (size - 1)
          board << buffer_row.concat(rank_row, buffer_row)
          # if size == 1
          #   board << rank_row
          # else
          #   buffer_row = [format_row(rank_num, [" "], colors: colors, tile_w: tile_w, show_r: false)] * (size - 1)
          #   board << buffer_row.concat(rank_row, buffer_row)
          # end
        end
        # bottom
        board << frame(:tail, tile_w: tile_w, show_r: show_r, label: BOARD[:decor1])
        board
      end

      private

      # Rank formatter
      # @param rank_num [Integer] rank number
      # @param row_data [Array<Hash>] expects a 1-element(reprinting) or 8-elements array(In order)
      # @option row_data [String] :asset element in the tile
      # @option row_data [Symbol] :color colour of the element
      # @param colors [Array<Symbol, String, nil>] Expects contrasting background colour
      # @param tile_w [Integer] width of each tile
      # @param show_r [Boolean] print ranks on the side?
      # @param label [String] override the print rank value with custom string
      # @return [Array<String>] a complete row of a specific rank within the board
      def format_row(rank_num, row_data, colors: BOARD[:bg_theme], tile_w: BOARD[:std_tile], show_r: false, label: "")
        arr = []
        # Light background colour, dark background colour
        bg1, bg2 = pattern_order(rank_num, colors: colors)
        # Build individual tile
        8.times { |i| arr << paint_tile(row_data[i % row_data.size], tile_w, i.even? ? bg1 : bg2) }
        # Build side borders
        label = rank_num if label.empty?
        side = [BOARD[:side].call(show_r ? label : " ")]
        [side.concat(arr, side).join("")]
      end

      # Helper: Build the head and tail section of the chessboard
      # @param section [Symbol] :head or :tail
      # @param tile_w [Integer] width of each tile
      # @param show_r [Boolean] print ranks on the side?
      # @param label [String] override the print rank value with custom string
      # @return [Array<String>] the top or bottom section of the board
      def frame(section = :head, tile_w: BOARD[:std_tile], show_r: true, label: "")
        arr = []
        row_values = show_r ? BOARD[:file] : [label]
        ends_l, ends_r = section == :head ? %i[head_l head_r] : %i[tail_l tail_r]

        arr << border(BOARD[ends_l], BOARD[ends_r], tile_w, BOARD[:h])
        arr << format_row(0, row_values, colors: [nil, nil], tile_w: tile_w, show_r: true, label: label)
        arr << border(BOARD[:sep_l], BOARD[:sep_r], tile_w, BOARD[:h])

        section == :head ? arr : arr.reverse
      end

      # Helper: Build horizontal border
      # @param left [String] left padding
      # @param right [String] right padding
      # @param length [Integer] times of repetition
      # @param value [String] value to be repeated
      def border(left, right, length, value)
        "#{left}#{value.center(length * 8, value)}#{right}"
      end

      # Helper: Determine the checker order of a specific rank
      # @param rank_num [Integer] rank number
      # @param colors [Array<Symbol, String>] Expects contrasting background colour
      # @return [Array<Symbol, String>] colour values
      def pattern_order(rank_num, colors: BOARD[:bg_theme])
        rank_num.even? ? colors : colors.reverse
      end

      # Helper: Paint tile
      # @param item [Hash] item hash
      # @option item [String] :asset element in the tile
      # @option item [Symbol] :color colour of the element
      # @param tile_w [Integer] width within each tile
      # @param bg_color [Symbol, String] expects a colour value
      # @return [String] coloured string
      def paint_tile(item, tile_w, bg_color)
        str, color, bg = if item.is_a?(Hash)
                           [item[:asset], item[:color], bg_color]
                         else
                           [item, :default, bg_color]
                         end
        Paint[str.center(tile_w), color, bg]
      end

      # Helper: Quadratic expression to maintain tile shape, based on n^2-n+1
      # @param size [Integer] padding size
      # @return [Integer] total width of each tile
      def to_quadratic(size)
        q = size + 1
        q**2 - q + 1
      end
    end
  end
end
