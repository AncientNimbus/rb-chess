# frozen_string_literal: true

require_relative "chess_utils"

module ConsoleGame
  module Chess
    # The Session Builder class helps create new session data hash
    # @author Ancient Nimbus
    class SessionBuilder
      include ChessUtils

      # Create session data
      # @return [Array<Integer, Hash>] session data
      def self.build_session(...) = new(...).build_session

      attr_reader :sessions, :mode, :sides, :site_text

      # @param game [Game] expects chess game manager object
      def initialize(game)
        @sessions = game.sessions
        @mode = game.mode
        @sides = game.sides
        @site_text = game.s("misc.site")
      end

      # Build session data
      # @return [Array<Integer, Hash>] session data
      def build_session
        id = sessions.size + 1
        set_player_side
        wp_name, bp_name = sides.values_at(w_sym, b_sym).map(&:name)
        session = { mode: mode,
                    white: wp_name,
                    black: bp_name,
                    event: "#{wp_name} vs #{bp_name}",
                    site: site_text,
                    date: Time.new.ceil }
        [id, session]
      end

      private

      # Set internal side value for new player object
      def set_player_side = sides.map { |side, player| player.side = side }
    end
  end
end
