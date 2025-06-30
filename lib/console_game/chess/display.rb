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
        head_l: "╔═══╦", head_r: "╦═══╗",
        sep_l: "╠═══╬", sep_r: "╬═══╣",
        tail_l: "╚═══╩", tail_r: "╩═══╝",
        side: ->(v) { "║ #{v} ║" },
        ends: ->(left, right, length, v) { "#{left}#{v.center(length * 8, v)}#{right}" }
      }.freeze

      # Build the chessboard
      # @param colors [Array<Symbol, String>] Expects contrasting background colour
      # @param padding [Integer] padding size
      # @param show_r [Boolean] print ranks on the side?
      # @return [Array<String>] a complete board with head and tail
      def build_board(turn_data = nil, colors: BOARD[:bg_theme], padding: 1, show_r: true)
        turn_data = Array.new(8) { [" "] } if turn_data.nil?
        tile_w = 2 * padding + 1
        board = []
        # top
        board << frame(:head, tile_w: tile_w, label: "◇")
        # main
        turn_data.each_with_index do |row, i|
          board << format_row(i + 1, row, colors: colors, tile_w: tile_w, show_r: show_r)
        end
        # bottom
        board << frame(:tail, tile_w: tile_w, label: "◆")
        board
      end

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

      private

      # Helper: Build the head and tail section of the chessboard
      # @param section [Symbol] :head or :tail
      # @param tile_w [Integer] width of each tile
      # @param show_r [Boolean] print ranks on the side?
      # @param label [String] override the print rank value with custom string
      # @return [Array<String>] the top or bottom section of the board
      def frame(section = :head, tile_w: BOARD[:std_tile], show_r: true, label: "")
        arr = []
        ends_l, ends_r = section == :head ? %i[head_l head_r] : %i[tail_l tail_r]
        arr << BOARD[:ends].call(BOARD[ends_l], BOARD[ends_r], tile_w, BOARD[:h])
        arr << format_row(0, BOARD[:file], colors: [nil, nil], tile_w: tile_w, show_r: show_r, label: label)
        arr << BOARD[:ends].call(BOARD[:sep_l], BOARD[:sep_r], tile_w, BOARD[:h])
        section == :head ? arr : arr.reverse
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
    end
  end
end
