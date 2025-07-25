# frozen_string_literal: true

require_relative "game"

module ConsoleGame
  module Chess
    # A wrapper to launch the game Chess
    # @author Ancient Nimbus
    module Launcher
      # Load chess to app list
      # @return [Hash]
      def load_chess = { "chess" => method(:chess) }

      # Run game: Chess
      # @param game_manager [GameManager] expects ConsoleGame::GameManager object
      # @return [Game]
      def chess(game_manager) = Chess::Game.new(game_manager)
    end
  end
end
