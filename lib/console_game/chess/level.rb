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
      attr_reader :mode, :controller, :w_player, :b_player, :sessions, :default_board

      def initialize(mode, input, side, sessions, import_fen = nil)
        @mode = mode
        @controller = input
        @w_player = side[:white]
        @b_player = side[:black]
        @session = sessions
        @default_board = parse_fen(self)
        @turn_data = import_fen.nil? ? default_board : parse_fen(self, import_fen)
      end

      # Start level
      def open_level
        p "Setting up game level"
        init_level
      end

      # Initialise the chessboard
      def init_level
        print_chessboard
        # pieces = turn_data.reject { |elem| elem.is_a?(String) }

        # p pieces.size
        piece_input = "b2"
        assign_piece(piece_input)
        p active_piece.movements
        p active_piece.at_start
        p active_piece.query_moves
        move_input = "b4"
        active_piece.move(move_input.to_sym)
        print_chessboard
        p active_piece.query_moves
        move_input = "b5"
        active_piece.move(move_input.to_sym)
        print_chessboard
        p active_piece.query_moves
        move_input = "b6"
        active_piece.move(move_input.to_sym)
        print_chessboard
        p active_piece.query_moves
        # move_input = "c7"
        # active_piece.move(move_input.to_sym)
        # print_chessboard

        # p active_piece.possible_moves
        p active_piece.targets
        p active_piece.at_start # @todo fix this
        # print_chessboard
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
