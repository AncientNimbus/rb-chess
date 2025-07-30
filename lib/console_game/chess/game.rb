# frozen_string_literal: true

require_relative "../base_game"
require_relative "player/chess_player"
require_relative "player/chess_computer"
require_relative "level"
require_relative "input/chess_input"
require_relative "logics/display"
require_relative "utilities/chess_utils"
require_relative "utilities/player_builder"
require_relative "utilities/session_builder"
require_relative "utilities/load_manager"

module ConsoleGame
  # The Chess module features all the working parts for the game Chess.
  # @author Ancient Nimbus
  # @version 0.8.0
  module Chess
    # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
    class Game < BaseGame
      include ChessUtils
      include Display

      attr_reader :mode, :p1, :p2, :sides, :sessions, :level

      # @param game_manager [GameManager]
      # @param title [String]
      def initialize(game_manager = nil, title = "Chess")
        super(game_manager, title, ChessInput.new(game_manager, self), ver: "0.8.0")
        user.profile[:appdata][:chess] ||= {}
        @sessions = user.profile[:appdata][:chess]
      end

      # Setup sequence
      # new game or load game
      def setup_game
        reset_state
        opt = game_selection
        id = opt == 1 ? new_game : load_game
        fen = sessions.dig(id, :fens, -1)
        @level = Level.new(controller, sides, sessions[id], fen).open_level
        end_game
      end

      private

      # == Flow ==

      # Game intro
      def boot
        tf_fetcher("", *%w[boot how_to help]).each do |msg|
          print_msg(msg.sub("0.0.0", ver))
          controller.ask(s("blanks.enter"), empty: true)
        end
      end

      # Prompt player for new game or load game
      def game_selection
        print_msg(s("load.f1"))
        controller.ask(s("load.f1a"), err_msg: s("load.f1a_err"), reg: [1, 2], input_type: :range).to_i
      end

      # Handle new game sequence
      # @param err [Boolean] is use when there is a load err
      def new_game(err: false)
        print_msg(s("new.err")) if err
        print_msg(s("new.f1"))
        @mode = controller.ask(s("new.f1a"), err_msg: s("new.f1a_err"), reg: [1, 2], input_type: :range).to_i
        @p1, @p2 = setup_players
        start_order
        create_session
      end

      # Handle load game sequence
      def load_game
        user_opt, session = select_session
        @mode = session[:mode]
        begin
          @p1, @p2 = build_players(session)
        rescue KeyError
          print_msg(s("load.err"))
          new_game(err: true)
        end
        assign_sides
        user_opt
      end

      # Endgame handling
      def end_game
        self.state = :ended
        opt = controller.ask(s("session.restart"), reg: COMMON_REG[:yesno], input_type: :custom)
        setup_game if opt.downcase.include?("y")
      end

      # == Utilities ==

      # Reset state
      def reset_state
        Player.player_count(0)
        @player_builder = nil
        @sides = {}
        setup_p1
        @p2 = nil
      end

      # Create new session data
      # @return [Integer] session id
      def create_session
        id, session_data = SessionBuilder.build_session(self)
        sessions[id] = p1.register_session(id, **session_data)
        id
      end

      # Select game session from list of sessions
      # @see LoadManager #select_session
      def select_session = LoadManager.select_session(self)

      # Setup players
      def setup_players = [p1, p2].map { |player| player_profile(player) }

      # Set up player profile
      # @param player [ConsoleGame::ChessPlayer, nil]
      # @return [ChessPlayer, ChessComputer]
      def player_profile(player)
        player ||= mode == 1 ? create_player("") : create_player("Computer", type: :ai)
        return player if player.is_a?(ChessComputer)

        # flow 2: name players
        f2 = s("new.f2", { count: [Player.total_player], name: [player.name] })
        player.edit_name(controller.ask(f2, reg: COMMON_REG[:filename], empty: true, input_type: :custom))
        print_msg(s("new.f2a", { name: player.name }))

        player
      end

      # Set start order
      def start_order
        f1, f1a, f1a_err = tf_fetcher("order", *%w[.f1 .f1a .f1a_err])
        print_msg(f1)
        opt = controller.ask(f1a, err_msg: f1a_err, reg: [1, 3], input_type: :range).to_i
        opt = rand(1..2) if opt == 3
        assign_sides(opt:)
      end

      # Assign players to a sides hash
      # @param opt [Integer] expects 1 or 2, where 1 will set p1 as white and p2 as black, and 2 in reverse
      # @return [Hash<ChessPlayer, ChessComputer>]
      def assign_sides(opt: 1)
        validated_opt = p1.side ? determine_opt : opt
        sides[w_sym], sides[b_sym] = validated_opt == 1 ? [p1, p2] : [p2, p1]
      end

      # Helper: determine side assignment option, usable only when p1.side is not nil
      # @return [Integer]
      def determine_opt = p1.side == w_sym ? 1 : 2

      # == Player object creation ==

      # Setup player 1
      def setup_p1 = @p1 = create_player(user.profile[:username])

      # Create new player builder service
      # @return [PlayerBuilder]
      def player_builder = @player_builder ||= PlayerBuilder.new(self)

      # Create players based on load mode
      # @see PlayerBuilder #build_player
      def build_players(...) = player_builder.build_players(...)

      # Create a player
      # @see PlayerBuilder #create_player
      def create_player(...) = player_builder.create_player(...)
    end
  end
end
