# frozen_string_literal: true

require_relative "game"
require_relative "logic"
require_relative "display"

module ConsoleGame
  module Chess
    # The Level class handles the core game loop of the game Chess
    # @author Ancient Nimbus
    class Level
      include Console
      include Logic
      include Display

      attr_accessor :turn_data
      attr_reader :mode, :controller, :w_player, :b_player, :sessions

      def initialize(mode, input, side, sessions, turn_data = nil)
        @mode = mode
        @controller = input
        @w_player = side[:white]
        @b_player = side[:black]
        @session = sessions
        @turn_data = turn_data.nil? ? parse_fen : turn_data
      end

      # Start level
      def open_level
        p "Setting up game level"
        init_level
      end

      # Initialise the chessboard
      def init_level
        print_chessboard
        piece_input = "d2"
        piece = turn_data[alg_map[piece_input.to_sym]]
        move_input = "d3"
        piece.move(self, move_input.to_sym)
        print_chessboard
      end

      # Game loop
      def game_loop; end

      # Endgame handling

      # == Utilities ==

      # Print the chessboard
      def print_chessboard
        chessboard = build_board(to_matrix(turn_data))
        print_msg(*chessboard, pre: "* ")
      end

      # Update turn data
      # Update chessboard display

      # User data handling
    end
  end
end
