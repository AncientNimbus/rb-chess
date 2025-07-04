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

      attr_accessor :turn_data, :active_piece
      attr_reader :mode, :controller, :w_player, :b_player, :sessions

      def initialize(mode, input, side, sessions, turn_data = nil)
        @mode = mode
        @controller = input
        @w_player = side[:white]
        @b_player = side[:black]
        @session = sessions
        @turn_data = turn_data.nil? ? parse_fen : parse_fen(turn_data)
      end

      # Start level
      def open_level
        p "Setting up game level"
        init_level
      end

      # Initialise the chessboard
      def init_level
        print_chessboard
        piece_input = "d5"
        assign_piece(piece_input)
        move_input = "d3"
        # active_piece.move(self, move_input.to_sym)
        moves = active_piece.query_moves(self).map { |pos| alg_map.key(pos) }
        p moves
        p active_piece.targets
        print_chessboard
      end

      # Game loop
      def game_loop; end

      # Endgame handling

      # == Utilities ==

      # Handling piece assignment
      # @param alg_pos [Symbol] algebraic notation
      def assign_piece(alg_pos)
        # add player side validation
        piece = turn_data[alg_map[alg_pos.to_sym]]
        return puts "'#{alg_pos}' is empty, please enter a correct notation" if piece == ""

        p "active piece: #{piece.side} #{piece.name}"
        self.active_piece = piece
      end

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
