# frozen_string_literal: true

require_relative "chess_utils"

module ConsoleGame
  module Chess
    # The Load Manager class handles the session loading process of chess
    # @author Ancient Nimbus
    class LoadManager
      include ChessUtils

      # Select game session from list of sessions
      # @return [Array]
      def self.select_session(...) = new(...).select_session

      attr_reader :game, :sessions, :controller

      # @param game [Game] expects chess game manager object
      def initialize(game)
        @game = game
        @sessions = game.sessions
        @controller = game.controller
      end

      # Select game session from list of sessions
      # @return [Array]
      def select_session
        user_opt = sessions.empty? ? game.new_game(err: true) : load_from_list
        session = sessions[user_opt]
        [user_opt, session]
      end

      private

      # Load from list
      # @return [Symbol, Integer]
      def load_from_list
        print_sessions_to_load
        controller.pick_from(sessions.keys)
      end

      # Helper to print list of sessions to load
      def print_sessions_to_load = game.print_msg(*game.build_table(data: sessions_list, head: game.s("load.f2a")))

      # Build list of sessions to load
      # This method select the event and date field within sessions, format the Date field and returns a list.
      # @return [Hash] list of sessions
      def sessions_list = sessions.transform_values { |session| session.select { |k, _| %i[event date].include?(k) } }
    end
  end
end
