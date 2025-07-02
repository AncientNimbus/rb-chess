# frozen_string_literal: true

require_relative "../base_game"
require_relative "logic"
require_relative "display"
require_relative "chess_input"
require_relative "chess_player"
require_relative "chess_computer"
require_relative "chess_piece"

module ConsoleGame
  # The Chess module features all the working parts for the game Chess.
  # @author Ancient Nimbus
  # @version 0.3.0
  module Chess
    # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
    class Game < BaseGame
      include Logic
      include Display

      attr_reader :mode, :p1, :p2, :side, :sessions

      def initialize(game_manager = nil, title = "Base Game")
        super(game_manager, title, ChessInput.new(game_manager))
        Player.player_count(0)
        @p1 = ChessPlayer.new(game_manager, user.profile[:username])
        @p2 = nil
        @side = { white: nil, black: nil }
        user.profile[:appdata][:chess] ||= {}
        @sessions = user.profile[:appdata][:chess]
      end

      private

      def boot
        super
        boot, intro, help = tf_fetcher("", *%w[boot intro help])
        print_msg(boot, intro, help)
      end

      # == Flow ==

      # Setup sequence
      def setup_game
        # new game or load game
        opt = game_selection
        opt == 1 ? new_game : load_game
        print_chessboard
      end

      # Prompt player for new game or load game
      def game_selection
        print_msg(s("load.f1"))
        controller.ask(s("load.f1a"), err_msg: s("load.f1a_err"), reg: [1, 2], input_type: :range).to_i
      end

      # Handle new game sequence
      def new_game
        print_msg(s("new.f1"))
        @mode = controller.ask(s("new.f1a"), err_msg: s("new.f1a_err"), reg: [1, 2], input_type: :range).to_i
        @p1, @p2 = setup_players
        start_order
        create_session(sessions.size + 1)
        # [p1, p2].each { |player| print_msg(s("order.f2", { player: [player.name], color: [player.side] }), pre: "* ") }
      end

      # Handle load game sequence
      def load_game
        p "load game from list"
      end

      # == Utilities ==

      # Print the chessboard
      def print_chessboard
        chessboard = build_board
        print_msg(*chessboard, pre: "* ")
      end

      # Setup players
      def setup_players
        [p1, p2].map { |player| player_profile(player) }
      end

      # Set up player profile
      # @param player [ConsoleGame::ChessPlayer, nil]
      # @return [ChessPlayer, ChessComputer]
      def player_profile(player)
        player ||= mode == 1 ? ChessPlayer.new(game_manager, "") : ChessComputer.new(game_manager)
        return player if player.is_a?(ChessComputer)

        # flow 2: name players
        f2 = s("new.f2", { count: [Player.total_player], name: [player.name] })
        player.edit_name(controller.ask(f2, reg: FILENAME_REG, empty: true, input_type: :custom))
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
      def create_session(id)
        sides = side.keys
        p1.side, p2.side = side[:white] == p1 ? sides : sides.reverse
        sessions[id] = p1.register_session(id, p2.name)
      end

      # Override: s
      # Retrieves a localized string and perform String interpolation and paint text if needed.
      # @param key_path [String] textfile keypath
      # @param subs [Hash] `{ demo: ["some text", :red] }`
      # @param paint_str [Array<Symbol, String, nil>]
      # @param extname [String]
      # @return [String] the translated and interpolated string
      def s(key_path, subs = {}, paint_str: [nil, nil], extname: ".yml")
        super("app.chess.#{key_path}", subs, paint_str: paint_str, extname: extname)
      end
    end
  end
end
