# frozen_string_literal: true

require_relative "../base_game"
require_relative "chess_player"
require_relative "chess_computer"
require_relative "level"
require_relative "input/chess_input"
require_relative "logics/logic"
require_relative "logics/display"
require_relative "utilities/session_utils"

module ConsoleGame
  # The Chess module features all the working parts for the game Chess.
  # @author Ancient Nimbus
  # @version 0.8.0
  module Chess
    # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
    class Game < BaseGame
      include SessionUtils
      include Logic
      include Display

      attr_reader :mode, :p1, :p2, :sides, :sessions, :level

      # @param game_manager [GameManager]
      # @param title [String]
      def initialize(game_manager = nil, title = "Chess")
        super(game_manager, title, ChessInput.new(game_manager, self), ver: "0.8.0")
        setup_p1
        @sides = {}
        user.profile[:appdata][:chess] ||= {}
        @sessions = user.profile[:appdata][:chess]
      end

      # Setup sequence
      # new game or load game
      def setup_game
        Player.player_count(1)
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
          print_msg(msg)
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
        @p2 = nil
        print_msg(s("new.err")) if err
        print_msg(s("new.f1"))
        @mode = controller.ask(s("new.f1a"), err_msg: s("new.f1a_err"), reg: [1, 2], input_type: :range).to_i
        @p1, @p2 = setup_players
        start_order
        create_session(sessions.size + 1)
      end

      # Handle load game sequence
      def load_game
        user_opt, session = select_session
        @p1, @p2 = build_players(session)
        @sides = assign_sides(p1, p2)
        user_opt
      end

      # Helper to get session selection from user
      def select_session
        new_game(err: true) if sessions.empty?
        print_sessions_to_load(sessions)
        user_opt = controller.pick_from(sessions.keys)
        session = sessions[user_opt]
        @mode = session[:mode]
        [user_opt, session]
      end

      # Helper to print list of sessions to load
      # @param sessions [Hash] expects user sessions hash
      def print_sessions_to_load(sessions) = print_msg(*build_table(data: sessions_list(sessions), head: s("load.f2a")))

      # Endgame handling
      def end_game
        opt = controller.ask(s("session.restart"), reg: COMMON_REG[:yesno], input_type: :custom)
        setup_game if opt.downcase.include?("y")
      end

      # == Utilities ==

      # Setup players
      def setup_players = [p1, p2].map { |player| player_profile(player) }

      # Setup player 1
      def setup_p1 = @p1 = create_player(user.profile[:username])

      # Set up player profile
      # @param player [ConsoleGame::ChessPlayer, nil]
      # @return [ChessPlayer, ChessComputer]
      def player_profile(player)
        player ||= mode == 1 ? create_player("") : create_player("Computer", type: :ai)
        return player if player.is_a?(ChessComputer)

        # flow 2: name players
        f2 = s("new.f2", { count: [Player.total_player], name: [player.name] })
        player.edit_name(controller.ask(f2, reg: COMMON_REG[:filename], empty: true, input_type: :custom))
        puts "Player is renamed to: #{player.name}"

        player
      end

      # Set start order
      def start_order
        f1, f1a, f1a_err = tf_fetcher("order", *%w[.f1 .f1a .f1a_err])
        print_msg(f1)
        opt = controller.ask(f1a, err_msg: f1a_err, reg: [1, 3], input_type: :range).to_i
        opt = rand(1..2) if opt == 3
        players = [p1, p2]
        sides[:white], sides[:black] = opt == 1 ? players : players.reverse
      end

      # Create session data
      # @param id [Integer] session id
      # @param mode [Integer] game mode
      # @return [Integer] current session id
      def create_session(id, game_mode = mode)
        sides_keys = sides.keys
        p1.side, p2.side = sides[:white] == p1 ? sides_keys : sides_keys.reverse
        sessions[id] = p1.register_session(id, p2.name, game_mode)
        id
      end

      # Override: Create a player
      # @param name [String] expects a name
      # @param side [Symbol, nil] expects :black or :white
      # @param controller [ChessInput] expects a ChessInput class object
      # @param player [ChessPlayer] expects ChessPlayer class object
      # @param ai_player [ChessComputer] expects ChessComputer class object
      # @param type [Symbol] expects :human or :ai
      # @return [ChessPlayer, ChessComputer]
      def create_player(name = "", side = nil, controller: self.controller, player: ChessPlayer,
                        ai_player: ChessComputer, type: :human) = super
    end
  end
end
