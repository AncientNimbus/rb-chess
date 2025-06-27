# frozen_string_literal: true

require_relative "../pgn_utils/pgn_utils"
require_relative "player"

module ConsoleGame
  # ChessPlayer is the Player object for the game Chess and it is a subclass of Player.
  class ChessPlayer < Player
    attr_accessor :side

    def initialize(game_manager = nil, name = "")
      super(game_manager, name)
      @side = nil
    end

    # Override: Initialise player save data
    def init_data
      @data = Hash.new do |hash, key|
        hash[key] = { event: nil, site: nil, date: nil, round: nil, white: nil, black: nil, result: nil, moves: {} }
      end
    end

    # Register session data
    # @param id [Integer] session id
    # @param p2_name [String] player 2's name
    # @param event [String] name of the event
    # @param site [String] name of the site
    # @param date [Time] time of the event
    def register_session(id, p2_name, event: "Ruby Arcade Chess Casual", site: "Ruby Arcade", date: Time.new.ceil)
      players = [name, p2_name].map { |name| Paint.unpaint(name) }
      white, black = side == :white ? players : players.reverse
      write_metadata(id, :white, white)
      write_metadata(id, :black, black)
      write_metadata(id, :event, event)
      write_metadata(id, :site, site)
      write_metadata(id, :date, date)
      data[id]
    end

    private

    # Access player session keys
    def write_metadata(id, key, value)
      data[id][key] = value
    end
  end
end
