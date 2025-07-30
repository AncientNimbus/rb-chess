# frozen_string_literal: true

module ConsoleGame
  module Chess
    # SessionUtils handles various player session related tasks, such as profile loading and validation.
    # @author Ancient Nimbus
    module SessionUtils
      include ChessUtils

      private

      # Assign players to a sides hash
      # @param player1 [ChessPlayer] expects a ChessPlayer objects
      # @param player2 [ChessPlayer, ChessComputer] expects a ChessPlayer objects
      # @param opt [Integer] expects 1 or 2, where 1 will set p1 as white and p2 as black, and 2 in reverse
      # @return [Hash<ChessPlayer, ChessComputer>]
      def assign_sides(player1, player2, opt: 1, sides: {})
        p1_side = player1.side
        opt = p1_side == w_sym ? 1 : 2 unless p1_side.nil?
        sides[w_sym] = player1
        sides[b_sym] = player2
        sides[w_sym], sides[b_sym] = sides[b_sym], sides[w_sym] if opt == 2
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
    end
  end
end
