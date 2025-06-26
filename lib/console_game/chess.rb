# frozen_string_literal: true

require_relative "base_game"
require_relative "chess_input"

module ConsoleGame
  # Textfile head
  TF = "app.chess"
  # Main game flow for the game Chess, a subclass of ConsoleGame::BaseGame
  class Chess < BaseGame
    def initialize(game_manager = nil, title = "Base Game")
      super(game_manager, title, ChessInput.new(game_manager))
    end

    private

    def boot
      super
      print_msg(*tf_fetcher("chess", *%w[boot intro help], root: "app"))
    end

    # == Flow ==

    # Setup sequence
    def setup_game
      game_selection

      # a. new game

      # b. load game
    end

    # Flow 1
    def game_selection
      opt = controller.handle_input(s("load.msg1"), err_msg: s("load.msg1_err"), reg: [1, 2], input_type: :range).to_i
      opt == 1 ? new_game : load_game
    end

    # Flow 2a
    def new_game
      p "create new game"
      opt = controller.handle_input(s("new.msg1"), err_msg: s("new.msg1_err"), reg: [1, 2], input_type: :range).to_i
      opt == 1 ? pvp : pve
    end

    # Flow 2.1a
    def pvp
      p "PvP selected"

      # name player 1

      # Set player 2 as player
      # name player 2
    end

    # Flow 2.1b
    def pve
      p "PvE selected"

      # name player 1

      # Set player 2 as computer
    end

    # Flow 2b
    def load_game
      p "load game from list"
    end

    # == Utilities ==

    # Set up player profile
    def player_profile
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
