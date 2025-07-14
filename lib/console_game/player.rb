# frozen_string_literal: true

require "colorize"
require "paint"

module ConsoleGame
  # Player class
  class Player
    @number_of_player = 0
    # @colors = String.colors[8..15]
    class << self
      # attr_reader :colors

      # Add Player count
      def add_player
        @number_of_player += 1
      end

      # Set global player count
      def player_count(value)
        @number_of_player = value
      end

      # Return number of active players
      def total_player
        @number_of_player
      end

      # Setup color array and remove unwanted color options
      # def setup_color
      #   %i[default gray].each { |elem| remove_color(elem) }
      # end

      # Remove color option to avoid two players share the same color tag
      # @param color [Symbol]
      # def remove_color(color)
      #   @colors.delete(color)
      # end
    end

    attr_reader :data, :name, :player_color, :controller

    # @param game_manager [GameManager]
    # @param name [String]
    # @param controller [Input]
    def initialize(game_manager = nil, name = "", controller = nil)
      @game_manager = game_manager
      @name = name
      @controller = controller
      # Player.setup_color
      Player.add_player
      @player_color = Paint.random
      edit_name(name)
      init_data
    end

    # Initialise player save data
    def init_data
      @data = { name: name }
    end

    # Edit player name
    # @param new_name [String]
    def edit_name(new_name = "")
      if new_name.empty?
        new_name = name.empty? ? "Player #{Player.total_player}" : name
      end
      @name = Paint[new_name, player_color]
    end

    # Store player's move
    # @param value [Integer] Positional value of the grid
    # def store_move(value)
    #   return nil if value.nil?

    #   data.fetch(:moves) << value
    # end

    # Update player turn count
    # def update_turn_count
    #   data[:turn] = data.fetch(:moves).size
    # end

    # == Utilities ==
  end

  # Computer player class
  # class Computer < Player
  #   def initialize(game_manager = nil, name = "Computer")
  #     super(game_manager, name)
  #   end

  #   # Returns a random integer between 1 to 7
  #   # @param empty_slots [Array<Integer>]
  #   # @param bound [Array<Integer>]
  #   def random_move(empty_slots, bound)
  #     row, = bound
  #     value = (empty_slots.sample % row) + 1
  #     print "#{value}\n"
  #     value
  #   end
  # end
end
