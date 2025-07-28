# frozen_string_literal: true

require_relative "../console/console"
require_relative "../nimbus_file_utils/nimbus_file_utils"

module ConsoleGame
  # Base Game class
  class BaseGame
    include Console
    include ::NimbusFileUtils

    attr_reader :game_manager, :controller, :title, :user, :ver
    attr_accessor :state, :game_result

    # @param game_manager [GameManager]
    # @param title [String]
    # @param input [Input]
    # @param ver [String] game version
    def initialize(game_manager = nil, title = "Base Game", input = nil, ver:)
      @ver = ver
      @game_manager = game_manager
      @controller = input
      @title = title
      @user = game_config[:users][0]
      @state = :created
    end

    # Game config
    def game_config
      return nil if game_manager.nil?

      { users: [game_manager.user] }
    end

    # State machine

    # Start the game
    def start
      self.state = :playing
      boot
      setup_game
    end

    # Change game state to paused
    def pause = self.state = :paused

    # Change game state to playing
    def resume = self.state = :playing

    # Change game state to ended
    def end_game(result)
      self.state = :ended
      @game_result = result
      show_end_screen
      restart
    end

    # Check if current game session is active
    def active? = state == :playing

    private

    # Print the boot screen
    def boot; end

    def setup_game; end

    def show_end_screen
      puts "Game Over! Result: #{@game_result}"
    end

    def restart; end
  end
end
