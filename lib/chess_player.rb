# frozen_string_literal: true

require_relative "pgn_utils"

module ConsoleGame
  # ChessPlayer is the Player object for the game Chess and it is a subclass of Player.
  class ChessPlayer < Player
    attr_reader :data

    # Initialise player save data
    def init_data
      @data = { chess: {
        1 => { event: nil, site: nil, date: nil, round: nil, white: nil, black: nil, result: nil, moves: {} }
      } }
    end
  end
end
