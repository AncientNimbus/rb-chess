# frozen_string_literal: true

require_relative "logics/display"

module ConsoleGame
  module Chess
    # The Board class handles the rendering of the chessboard
    # @author Ancient Nimbus
    class Board
      include Console
      include Display

      attr_accessor :board_size, :board_side, :board_padding, :flip_board, :highlight
      attr_reader :level

      # @param level [Level] chess Level object
      def initialize(level)
        @level = level
        display_configs
      end

      # Print before the chessboard
      # @param keypath [String] TF keypath
      # @param subs [Hash] `{ demo: ["some text", :red] }`
      # def print_before_cb(keypath, sub)
      #   board.print_msg(board.s(keypath, sub))
      # end

      # Print after the chessboard
      # @param keypath [String] TF keypath
      # @param subs [Hash] `{ demo: ["some text", :red] }`
      def print_after_cb(keypath, sub = {}) = print_msg(s(keypath, sub))

      # Print turn
      # @param event_msgs [Array<String>]
      def print_turn(event_msgs)
        system("clear")
        print_msg(*event_msgs, pre: "* ") unless event_msgs.empty?
        print_chessboard
        level.event_msgs.clear
      end

      # Print the chessboard
      def print_chessboard = print_msg(*build_chessboard, pre: "".ljust(board_padding), clear: false)

      # Enable & disable board flipping
      def flip_setting
        self.flip_board = !flip_board
        print_chessboard
        keypath = flip_board ? "cmd.board.flip_on" : "cmd.board.flip_off"
        print_msg(s(keypath), pre: D_MSG[:gear_icon])
      end

      # Make board bigger or smaller
      def adjust_board_size
        self.board_size, self.board_padding = board_size == 1 ? BOARD[:b_size_l] : BOARD[:b_size_s]
        print_chessboard
        keypath = board_size == 1 ? "cmd.board.size1" : "cmd.board.size2"
        print_msg(s(keypath), pre: D_MSG[:gear_icon])
      end

      private

      # Display configs
      def display_configs
        @board_size, @board_padding = BOARD[:b_size_s]
        @flip_board = true
        @board_side = :white
        @highlight = THEME[:classic].slice(:icon, :highlight)
      end

      # Pre-process turn data before sending it to display module
      # @return [Array] 2D array respect to bound limit
      def rendering_data
        display_data = highlight_moves(level.turn_data.dup, level.active_piece)
        to_matrix(display_data)
      end

      # Temporary display move indicator highlight on the board
      # @param display_data [Array<ChessPiece, String>] 1D copied of turn_data
      # @param active_piece [King, Queen, Bishop, Knight, Rook, Pawn] chess piece
      # @return [Array]
      def highlight_moves(display_data, active_piece)
        return display_data if active_piece.nil?

        active_piece.possible_moves.each { |move| display_data[move] = highlight if display_data[move].is_a?(String) }
        display_data
      end

      # Build the chessboard
      # @return [Array<String>]
      def build_chessboard
        board_direction = flip_board ? level.player.side : board_side
        build_board(rendering_data, side: board_direction, size: board_size)
      end
    end
  end
end
