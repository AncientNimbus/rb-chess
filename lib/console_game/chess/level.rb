# frozen_string_literal: true

require_relative "game"
require_relative "logic"
require_relative "display"

module ConsoleGame
  module Chess
    # The Level class handles the core game loop of the game Chess
    # @author Ancient Nimbus
    class Level
      include Logic
      include Display

      attr_accessor
      attr_reader :mode, :controller, :w_player, :b_player, :sessions, :turn_data

      def initialize(mode, input, side, sessions, turn_data = nil)
        @mode = mode
        @controller = input
        @w_player = side[:white]
        @b_player = side[:black]
        @session = sessions
        @turn_data = turn_data
      end

      # Start level
      def open_level
        p "Setting up game level"
      end

      # Initialise the chessboard
      def init_level; end

      # Game loop
      def game_loop; end

      # Endgame handling

      # == Utilities ==

      # Update turn data
      # Update chessboard display

      # User data handling
    end
  end
end
