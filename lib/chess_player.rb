# frozen_string_literal: true

require_relative "pgn_utils"

module ConsoleGame
  # ChessPlayer is the Player object for the game Chess and it is a subclass of Player.
  class ChessPlayer < Player
    # Initialise player save data
    def init_data
      @data = { chess: {
        1 => { event: nil, site: nil, date: nil, round: nil, white: nil, black:, result: nil, moves: {} }
      } }
    end

    # Export session record in PGN format
    # @param session_id [Integer] session to access within the player save file
    # def to_pgn(session_id)
    #   return "Session not found, operation cancelled." unless data.key?(session_id)

    #   session = data.fetch(session_id)
    #   pgn_data = <<~PGN
    #     [Event]
    #     [Site]
    #     [Date]
    #     [Round]
    #     [White]
    #     [Black]
    #     [Result]

    #   PGN
    # end
  end
end
