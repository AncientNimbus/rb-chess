# frozen_string_literal: true

require_relative "../base_game"
require_relative "chess_player"
require_relative "chess_computer"
require_relative "level"
require_relative "input/chess_input"
require_relative "logics/logic"
require_relative "logics/display"

module ConsoleGame
  # The Chess module features all the working parts for the game Chess.
  # @author Ancient Nimbus
  # @version 0.7.0
  module Chess
    # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
    class Game < BaseGame
      include Logic
      include Display

      attr_reader :ver, :mode, :p1, :p2, :side, :sessions

      def initialize(game_manager = nil, title = "Chess")
        super(game_manager, title, ChessInput.new(game_manager, self))
        @ver = "0.7.0"
        @p1 = ChessPlayer.new(user.profile[:username], controller)
        @p2 = nil
        @side = PRESET[:nil_hash].call
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
        @level = Level.new(controller, side, sessions[id], fen).open_level
        end_game
      end

      private

      def boot
        tf_fetcher("", *%w[boot how_to help]).each do |msg|
          print_msg(msg)
          controller.ask(s("blanks.enter"), empty: true)
        end
      end

      # == Flow ==

      # Endgame handling
      def end_game
        opt = controller.ask(s("session.restart"), reg: COMMON_REG[:yesno], input_type: :custom)
        setup_game if opt.downcase.include?("y")
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
        create_session(sessions.size + 1)
      end

      # Handle load game sequence
      def load_game
        user_opt, session = select_session
        @p1, @p2 = build_players(session)
        assign_sides(p1, p2)
        user_opt
      end

      # Helper to get session selection from user
      def select_session
        new_game(err: true) if sessions.empty?
        print_sessions_to_load
        user_opt = controller.pick_from(sessions.keys)
        session = sessions[user_opt]
        @mode = session[:mode]
        [user_opt, session]
      end

      # Create player classes based on load mode
      # @param session [Hash] game session to load
      # @return [Array<ChessPlayer, ChessComputer>]
      def build_players(session)
        if mode == 1
          %i[white black].map { |side| ChessPlayer.new(session[side], controller, side) }
        else
          computer_side = session.key("Computer")
          player_side = opposite_of(computer_side)
          [
            ChessPlayer.new(session[player_side], controller, player_side),
            ChessComputer.new(session[computer_side], controller, computer_side)
          ]
        end
      end

      # Assign players
      # @param players [ChessPlayer, ChessComputer] expects two ChessPlayer objects
      def assign_sides(*players)
        side[:white], side[:black] = players
        side[:white], side[:black] = side[:black], side[:white] if p1.side == :black
      end

      # Helper to print list of sessions to load
      def print_sessions_to_load
        sessions_list = sessions.transform_values { |session| session.select { |k, _| %i[event date].include?(k) } }
        filter = sessions_list.transform_values do |session|
          session.merge(date: Time.new(session[:date]).strftime("%m/%d/%Y %I:%M %p"))
        end
        print_msg(*build_table(data: filter, head: s("load.f2a")))
      end

      # == Utilities ==

      # Setup players
      def setup_players = [p1, p2].map { |player| player_profile(player) }

      # Set up player profile
      # @param player [ConsoleGame::ChessPlayer, nil]
      # @return [ChessPlayer, ChessComputer]
      def player_profile(player)
        player ||= mode == 1 ? ChessPlayer.new("", controller) : ChessComputer.new("Computer", controller)
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
        side[:white], side[:black] = opt == 1 ? players : players.reverse
      end

      # Create session data
      # @param id [Integer] session id
      # @param mode [Integer] game mode
      # @return [Integer] current session id
      def create_session(id, game_mode = mode)
        sides = side.keys
        p1.side, p2.side = side[:white] == p1 ? sides : sides.reverse
        sessions[id] = p1.register_session(id, p2.name, game_mode)
        id
      end
    end
  end
end
