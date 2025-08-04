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

      attr_reader :sessions, :mode, :sides, :site_txt, :ongoing_txt

      # @param game [Game] expects chess game manager object
      def initialize(game)
        @sessions = game.sessions
        @mode = game.mode
        @sides = game.sides
        @site_txt = game.s("misc.site")
        @ongoing_txt = game.s("status.ongoing")
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
                    event: "#{wp_name} vs #{bp_name} Status #{ongoing_txt}",
                    site: site_txt,
                    date: Time.new.ceil.strftime(STR_TIME) }
        [id, session]
      end

      private

      # Set internal side value for new player object
      def set_player_side = sides.map { |side, player| player.side = side }
    end
  end
end
