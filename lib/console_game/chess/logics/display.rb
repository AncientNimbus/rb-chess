# frozen_string_literal: true

require "paint"
require_relative "../../../nimbus_file_utils/nimbus_file_utils"

module ConsoleGame
  module Chess
    # Display module for the game Chess in Console Game
    module Display
      include ::NimbusFileUtils
      # Default design for the chessboard
      # Board padding is added as an UX enhancement, with 80 character width as design blueprint.
      # Standard board padding is set to 23, while large board is set to 7.
      BOARD = { size: 8, turn_data: Array.new(8) { [" "] }, file: [*"a".."h"], std_tile: 3, h: "═", decors: %w[◆ ◇],
                head_l: "╔═══╦", head_r: "╦═══╗", sep_l: "╠═══╬", sep_r: "╬═══╣", tail_l: "╚═══╩", tail_r: "╩═══╝",
                side: ->(v) { "║ #{v} ║" }, b_size_s: [1, 23], b_size_l: [2, 7] }.freeze

      # Default design for chess pieces
      PIECES = { k: { name: "King", notation: "K", style1: "♚", style2: "♔" },
                 q: { name: "Queen", notation: "Q", style1: "♛", style2: "♕" },
                 r: { name: "Rook", notation: "R", style1: "♜", style2: "♖" },
                 b: { name: "Bishop", notation: "B", style1: "♝", style2: "♗" },
                 n: { name: "Knight", notation: "N", style1: "♞", style2: "♘" },
                 p: { name: "Pawn", notation: "P", style1: "♟", style2: "♙" } }.freeze

      # Default theme
      # Note on other good options: bg: %w[#ada493 #847b6a], black: "#A52A2A", white: "#F0FFFF"
      THEME = {
        classic: { bg: %w[#cdaa7d #8b5742], black: "#000000", white: "#f0ffff", icon: "◇", highlight: "#00ff7f" },
        navy: { bg: %w[#cdaa7d #8b5742], black: "#191970", white: "#f0ffff", icon: "◇", highlight: "#00ff7f" }
      }.freeze

      # Message Syntax highlight
      MSG_HIGHLIGHT = {
        std: { type: "cyan", alg_pos: "gold" }
      }.freeze

      # Override: s
      # Retrieves a localized string and perform String interpolation and paint text if needed.
      # @param key_path [String] textfile keypath
      # @param subs [Hash] `{ demo: ["some text", :red] }`
      # @param paint_str [Array<Symbol, String, nil>]
      # @param extname [String]
      # @return [String] the translated and interpolated string
      def s(key_path, subs = {}, paint_str: %i[default default], extname: ".yml")
        super("app.chess.#{key_path}", subs, paint_str:, extname:)
      end

      private

      # Build the chessboard
      # @param turn_data [Array<Array<ChessPiece, String>>] expects an 8 by 8 array, each represents a whole rank
      # @param side [Symbol] :white or :black, this will flip the board
      # @param colors [Array<Symbol, String>] Expects contrasting background colour
      # @param size [Integer] padding size
      # @param show_r [Boolean] print ranks on the side?
      # @return [Array<String>] a complete board with head and tail
      def build_board(turn_data = BOARD[:turn_data], side: :white, colors: THEME[:classic][:bg], size: 1, show_r: true)
        tile_w = to_quadratic(size)
        # main
        board = build_main(turn_data, side: side, colors: colors, tile_w: tile_w, size: size, show_r: show_r)
        # Set board decorator
        board_decors = BOARD[:decors]
        head_side, tail_side = side == :black ? board_decors : board_decors.reverse
        # Insert head
        board.unshift(frame(:head, side: side, tile_w: tile_w, show_r: show_r, label: head_side))
        # Push tail
        board.push(frame(:tail, side: side, tile_w: tile_w, show_r: show_r, label: tail_side))
        # Return flatten
        board.flatten
      end

      # Rank formatter
      # @param rank_num [Integer] rank number
      # @param row_data [Array<ChessPiece, String>] expects a 1-element(reprinting) or n-elements array(In order)
      # @param colors [Array<Symbol, String, nil>] Expects contrasting background colour
      # @param tile_w [Integer] width of each tile
      # @param show_r [Boolean] print ranks on the side?
      # @param label [String] override the print rank value with custom string
      # @return [Array<String>] a complete row of a specific rank within the board
      def format_row(rank_num, row_data, colors: THEME[:classic][:bg], tile_w: BOARD[:std_tile], show_r: false,
                     label: "", flipped: false)
        arr = []
        # Light background colour, dark background colour
        bg1, bg2 = pattern_order(rank_num, colors: colors)
        # Build individual tile
        BOARD[:size].times { |i| arr << paint_tile(row_data[i % row_data.size], tile_w, i.even? ? bg1 : bg2) }
        # Build side borders
        label = rank_num if label.empty?
        border = [BOARD[:side].call(show_r ? label : " ")]
        add_borders(arr, border, flipped: flipped)
      end

      # Return a formatted row with borders
      def add_borders(arr_data, border, flipped: false)
        formatted_row = border.concat(arr_data, border)
        formatted_row.reverse! if flipped
        [formatted_row.join("")]
      end

      # Build the main section of the chessboard
      # @param turn_data [Array<Array>] expects an array with n elements, each represents a single row
      # @param side [Symbol] :white or :black, this will flip the board
      # @param colors [Array<Symbol, String>] Expects contrasting background colour
      # @param tile_w [Integer] width of each tile
      # @param size [Integer] padding size
      # @param show_r [Boolean] print ranks on the side?
      def build_main(turn_data, side: :white, colors: THEME[:classic][:bg], tile_w: BOARD[:std_tile], size: 1,
                     show_r: true)
        board = []
        flip = true if side == :black
        turn_data.each_with_index do |row, i|
          rank_num = i + 1
          rank_row = format_row(rank_num, row, colors: colors, tile_w: tile_w, show_r: show_r, flipped: flip)
          buffer_row = [format_row(rank_num, [" "], colors: colors, tile_w: tile_w, flipped: flip)] * (size - 1)
          board << buffer_row.concat(rank_row, buffer_row)
        end
        flip ? board : board.reverse
      end

      # Helper: Build the head and tail section of the chessboard
      # @param section [Symbol] :head or :tail
      # @param tile_w [Integer] width of each tile
      # @param show_r [Boolean] print ranks on the side?
      # @param label [String] override the print rank value with custom string
      # @return [Array<String>] the top or bottom section of the board
      def frame(section = :head, side: :white, tile_w: BOARD[:std_tile], show_r: true, label: "")
        row_values = show_r ? BOARD[:file] : [label]
        flip = true if side == :black
        ends_l, ends_r = section == :head ? %i[head_l head_r] : %i[tail_l tail_r]

        arr = [border(BOARD[ends_l], BOARD[ends_r], tile_w, BOARD[:h])]
        arr << format_row(0, row_values, colors: [nil, nil], tile_w: tile_w, show_r: true, label: label, flipped: flip)
        arr << border(BOARD[:sep_l], BOARD[:sep_r], tile_w, BOARD[:h])

        section == :head ? arr : arr.reverse
      end

      # Helper: Build horizontal border
      # @param left [String] left padding
      # @param right [String] right padding
      # @param length [Integer] times of repetition
      # @param value [String] value to be repeated
      def border(left, right, length, value) = "#{left}#{value.center(length * BOARD[:size], value)}#{right}"

      # Helper: Determine the checker order of a specific rank
      # @param rank_num [Integer] rank number
      # @param colors [Array<Symbol, String>] Expects contrasting background colour
      # @return [Array<Symbol, String>] colour values
      def pattern_order(rank_num, colors: THEME[:classic][:bg]) = rank_num.even? ? colors : colors.reverse

      # Helper: Paint tile
      # @param item [ChessPiece, Hash, String] item
      # @param tile_w [Integer] width within each tile
      # @param bg_color [Symbol, String] expects a colour value
      # @return [String] coloured string
      def paint_tile(item, tile_w, bg_color)
        str, color, bg = case item
                         when ChessPiece then [item.icon, item.color, bg_color]
                         when Hash then [item[:icon], item[:highlight], bg_color]
                         when String then [item, :default, bg_color]
                         end
        Paint[str.center(tile_w), color, bg]
      end

      # Helper: Quadratic expression to maintain tile shape, based on n^2-n+1
      # @param size [Integer] padding size
      # @return [Integer] total width of each tile
      def to_quadratic(size) = (size + 1)**2 - (size + 1) + 1

      # Convert a 1D array to 2D array based on bound's row value
      # @param flat_arr [Array]
      # @param bound [Array<Integer>] `[row, col]`
      # @return [Array] nested array
      def to_matrix(flat_arr, bound: [BOARD[:size], BOARD[:size]])
        nested_arr = []
        flat_arr.each_slice(bound[0]) { |row| nested_arr.push(row) }
        nested_arr
      end
    end
  end
end
