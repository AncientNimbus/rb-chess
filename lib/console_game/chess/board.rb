# frozen_string_literal: true

require_relative "logics/display"

module ConsoleGame
  module Chess
    # The Board class handles the rendering of the chessboard
    # @author Ancient Nimbus
    class Board
      include Console
      include Display

      attr_accessor :board_size, :board_side, :flip_board, :highlight
      attr_reader :level

      # @param level [Level] chess Level object
      def initialize(level)
        @level = level
        display_configs
      end

      # Print the chessboard
      def print_chessboard = print_msg(*build_chessboard, pre: "* ")

      # Enable & disable board flipping
      def flip_setting
        self.flip_board = !flip_board
        print_chessboard
        puts flip_board ? "Board flipping enabled." : "Board flipping disabled." # @todo: to TF
      end

      # Make board bigger or smaller
      def adjust_board_size
        self.board_size = board_size == 1 ? 2 : 1
        print_chessboard
        puts board_size == 1 ? "Board size is set to standard." : "Board size is set to large." # @todo: to TF
      end

      private

      # Display configs
      def display_configs
        @board_size = 1
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
