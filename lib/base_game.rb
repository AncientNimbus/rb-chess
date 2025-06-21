# frozen_string_literal: true

module ConsoleGame
  # Base Game class
  class BaseGame
    attr_reader :game_manager, :input, :title, :p1
    attr_accessor :state, :game_result

    # @param game_manager [ConsoleGame::GameManager]
    # @param input [ConsoleGame::ConsoleMenu]
    # @param title [String]
    def initialize(game_manager = nil, input = nil, title = "Base Game")
      @game_manager = game_manager
      @input = input
      @title = title
      @p1 = game_config[:players][0]
      Player.player_count(1)
      @state = :created
    end

    # Game config
    def game_config
      return nil if game_manager.nil?

      { players: [game_manager.p1] }
    end

    # State machine

    # Start the game
    def start
      self.state = :playing
      show_intro
      setup_game
    end

    # Change game state to paused
    def pause
      self.state = :paused
    end

    # Change game state to playing
    def resume
      self.state = :playing
    end

    # Change game state to ended
    def end_game(result)
      self.state = :ended
      @game_result = result
      show_end_screen
      restart
    end

    # Check if current game session is active
    def active?
      state == :playing
    end

    protected

    def setup_game; end

    def show_intro
      system("clear")
      input.print_msg(F.s("console.msg.run", { app: title }, :yellow))
    end

    def show_end_screen
      puts "Game Over! Result: #{@game_result}"
    end

    def restart; end
  end
end
