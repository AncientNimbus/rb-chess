# frozen_string_literal: true

require_relative "chess_utils"
require_relative "../player/chess_player"
require_relative "../player/chess_computer"

module ConsoleGame
  module Chess
    # The Player Builder class helps create new chess players for each session
    # @author Ancient Nimbus
    class PlayerBuilder
      include ChessUtils

      attr_reader :game, :session, :controller, :human_class, :ai_class

      # @param game [Game] expects chess game manager object
      def initialize(game)
        @game = game
        @controller = game.controller
        @human_class = ChessPlayer
        @ai_class = ChessComputer
      end

      # Create players based on load mode
      # @param session [Hash] game session to load
      # @return [Array<ChessPlayer, ChessComputer>]
      def build_players(session)
        @session = session
        case session[:mode]
        when 1 then pvp_mode
        when 2 then pve_mode
        else raise KeyError
        end
      end

      # Create a player
      # @param name [String] expects a name
      # @param side [Symbol, nil] expects :black or :white
      # @param type [Symbol] expects :human or :ai
      # @param m_history [Array<String>]
      # @return [ChessPlayer, ChessComputer]
      def create_player(name = "", side = nil, type: :human, m_history: [])
        new_player = type == :human ? human_class : ai_class
        new_player.new(name, controller, side, m_history:)
      end

      private

      # When it is player vs player
      # @return [Array<ChessPlayer>]
      def pvp_mode
        SIDES_SYM.map { |side| create_player(session[side], side, m_history: m_history_data(side)) }
      end

      # When it is player vs computer
      # @return [Array<ChessPlayer, ChessComputer>]
      def pve_mode
        computer_side = session.key("Computer")
        raise KeyError if computer_side.nil?

        player_side = opposite_of(computer_side)
        [create_player(session[player_side], player_side, m_history: m_history_data(player_side)),
         create_player(session[computer_side], computer_side, type: :ai, m_history: m_history_data(computer_side))]
      end

      # Helper to return moves history depending on side
      # @return [Array<String>]
      def m_history_data(side)
        data = session["#{side}_moves".to_sym]
        data.nil? ? [] : data
      end
    end
  end
end
