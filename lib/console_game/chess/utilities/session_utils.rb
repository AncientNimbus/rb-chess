# frozen_string_literal: true

module ConsoleGame
  module Chess
    # SessionUtils handles various player session related tasks, such as profile loading, validation, and more.
    # @author Ancient Nimbus
    module SessionUtils
      # Default symbol for white and black
      SIDES_SYM = %i[white black].freeze

      # Returns white as symbol
      def white_sym = SIDES_SYM[0]

      # Returns black as symbol
      def black_sym = SIDES_SYM[1]

      private

      # Assign players to a sides hash
      # @param player1 [ChessPlayer] expects a ChessPlayer objects
      # @param player2 [ChessPlayer, ChessComputer] expects a ChessPlayer objects
      # @param opt [Integer] expects 1 or 2, where 1 will set p1 as white and p2 as black, and 2 in reverse
      # @return [Hash<ChessPlayer, ChessComputer>]
      def assign_sides(player1, player2, opt: 1, sides: {})
        p1_side = player1.side
        opt = p1_side == white_sym ? 1 : 2 unless p1_side.nil?
        sides[white_sym] = player1
        sides[black_sym] = player2
        sides[white_sym], sides[black_sym] = sides[black_sym], sides[white_sym] if opt == 2
        sides
      end

      # Build list of sessions to load
      # This method select the event and date field within sessions, format the Date field and returns a list.
      # @param sessions [Hash] expects user sessions hash
      # @return [Hash] list of sessions
      def sessions_list(sessions = { event: "", date: Time.new(2025, 7, 1) })
        list = sessions.transform_values { |session| session.select { |k, _| %i[event date].include?(k) } }
        list.transform_values do |session|
          date_field = session[:date].is_a?(Time) ? session[:date] : Time.new(session[:date])
          session.merge(date: date_field.strftime("%m/%d/%Y %I:%M %p"))
        end
      end

      # Create players based on load mode
      # @param session [Hash] game session to load
      # @param controller [ChessInput] expects a ChessInput class object
      # @param player [ChessPlayer] expects ChessPlayer class object
      # @param ai_player [ChessComputer] expects ChessComputer class object
      # @return [Array<ChessPlayer, ChessComputer>]
      def build_players(session, controller:, player:, ai_player:)
        case session[:mode]
        when 1
          SIDES_SYM.map { |side| create_player(session[side], side, controller:, player:, ai_player:, type: :human) }
        when 2
          computer_side = session.key("Computer")
          raise KeyError if computer_side.nil?

          player_side = computer_side == white_sym ? black_sym : white_sym
          [create_player(session[player_side], player_side, controller:, player:, ai_player:, type: :human),
           create_player(session[computer_side], computer_side, controller:, player:, ai_player:, type: :ai)]
        else raise KeyError
        end
      end

      # Create a player
      # @param name [String] expects a name
      # @param side [Symbol, nil] expects :black or :white
      # @param controller [ChessInput] expects a ChessInput class object
      # @param player [ChessPlayer] expects ChessPlayer class object
      # @param ai_player [ChessComputer] expects ChessComputer class object
      # @param type [Symbol] expects :human or :ai
      # @return [ChessPlayer, ChessComputer]
      def create_player(name = "", side = nil, controller:, player:, ai_player:, type: :human)
        new_player = type == :human ? player : ai_player
        new_player.new(name, controller, side)
      end
    end
  end
end
