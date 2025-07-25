# frozen_string_literal: true

require_relative "game"

module ConsoleGame
  module Chess
    # A wrapper to launch the game Chess
    # @author Ancient Nimbus
    module ChessLauncher
      # Load chess to app list
      # @return [Hash]
      def load_chess = { "chess" => method(:chess) }

      # Run game: Chess
      # @return [Game]
      def chess = Chess::Game.new(self)

      # End game message
      # @return [String] textfile key
      def shut_down_msg = "app.chess.end.home"
    end
  end
end
