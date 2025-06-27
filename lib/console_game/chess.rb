# frozen_string_literal: true

require_relative "base_game"
require_relative "chess_input"
require_relative "chess_player"
require_relative "chess_computer"

module ConsoleGame
  # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
  class Chess < BaseGame
    # Textfile head
    TF = "app.chess"

    attr_reader :mode, :p1, :p2

    def initialize(game_manager = nil, title = "Base Game")
      super(game_manager, title, ChessInput.new(game_manager))
      Player.player_count(0)
      @p1 = ChessPlayer.new(game_manager, user.profile[:username])
      @p2 = nil
    end

    private

    def boot
      super
      print_msg(*tf_fetcher("", *%w[boot intro help]))
    end

    # == Flow ==

    # Setup sequence
    def setup_game
      game_selection

      # a. new game

      # b. load game
    end

    # Prompt player for new game or load game
    def game_selection
      opt = controller.ask(s("load.f1"), err_msg: s("load.f1_err"), reg: [1, 2], input_type: :range).to_i
      opt == 1 ? new_game : load_game
    end

    # Handle new game sequence
    def new_game
      @mode = controller.ask(s("new.f1"), err_msg: s("new.f1_err"), reg: [1, 2], input_type: :range).to_i
      # mode == 1 ? pvp : pve
      setup_players
    end

    # Setup players
    def setup_players
      [p1, p2].map! { |player| player_profile(player) }
    end

    # Setup PvP mode
    def pvp
      p "PvP selected"

      # name player 1

      # Set player 2 as player
      # name player 2
    end

    # Setup PvE mode
    def pve
      p "PvE selected"

      # name player 1

      # Set player 2 as computer
    end

    # Handle load game sequence
    def load_game
      p "load game from list"
    end

    # == Utilities ==

    # Set up player profile
    # @param player [ConsoleGame::ChessPlayer, nil]
    def player_profile(player)
      p player.object_id
      player ||= mode == 1 ? ChessPlayer.new(game_manager, "") : ChessComputer.new(game_manager)
      p player.object_id
      return player if player.is_a?(Computer)

      f2 = s("new.f2", { count: [Player.total_player], name: [player.name] })
      player.edit_name(controller.ask(f2, reg: FILENAME_REG, empty: true, input_type: :custom))

      puts "Player is renamed to: #{player.name}"
      player
    end

    # Override: s
    # Retrieves a localized string and perform String interpolation and paint text if needed.
    # @param key_path [String] textfile keypath
    # @param subs [Hash] `{ demo: ["some text", :red] }`
    # @param paint_str [Array<Symbol, String, nil>]
    # @param extname [String]
    # @return [String] the translated and interpolated string
    def s(key_path, subs = {}, paint_str: [nil, nil], extname: ".yml")
      super("#{TF}.#{key_path}", subs, paint_str: paint_str, extname: extname)
    end

    # Override: Textfile strings fetcher
    # @param sub [String] sub-head
    # @param keys [Array<String>] key
    # @return [Array<String>] array of textfile strings
    def tf_fetcher(sub, *keys, root: TF)
      super(sub, keys, root: root)
    end
  end
end
