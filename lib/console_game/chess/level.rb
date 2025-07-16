# frozen_string_literal: true

require_relative "game"
require_relative "logic"
require_relative "board"
require_relative "piece_analysis"
require_relative "utilities/fen_import"
require_relative "utilities/fen_export"

module ConsoleGame
  module Chess
    # The Level class handles the core game loop of the game Chess
    # @author Ancient Nimbus
    class Level
      include Console
      include Logic
      include PieceAnalysis
      include FenImport
      include FenExport

      # @!attribute [w] player
      #   @return [ChessPlayer, ChessComputer]
      attr_accessor :white_turn, :turn_data, :active_piece, :previous_piece, :en_passant, :player, :half_move,
                    :full_move
      attr_reader :mode, :controller, :w_player, :b_player, :fen_data, :sessions, :board, :kings, :castling_states,
                  :threats_map, :usable_pieces

      # @param mode [Integer]
      # @param input [ChessInput]
      # @param sides [hash]
      #   @option sides [ChessPlayer, ChessComputer] :white Player who plays as White
      #   @option sides [ChessPlayer, ChessComputer] :black Player who plays as Black
      # @param sessions [hash]
      # @param import_fen [String] expects a valid FEN string
      def initialize(mode, input, sides, sessions, import_fen = nil)
        @mode = mode
        @controller = input
        @w_player, @b_player = sides.values
        @session = sessions
        @fen_data = import_fen.nil? ? parse_fen(self) : parse_fen(self, import_fen)
        @board = Board.new(self)
      end

      # == Flow ==

      # Start level
      def open_level
        init_level
        play_chess until any_checkmate?
        end_game
      end

      # == Game Logic ==

      # Pawn specific: Present a list of option when player can promote a pawn
      def promote_opts
        refresh
        player.indirect_promote
      end

      # Reset En Passant status when it is not used at the following turn
      def reset_en_passant
        return if en_passant.nil? || active_piece == en_passant[0]

        self.en_passant = nil if active_piece.curr_pos != en_passant[1]
      end

      # == Utilities ==

      # Fetch a single chess piece
      # @param query [String] algebraic notation `"e4"`
      # @param side [Symbol] expects :all, :white or :black
      # @param usable_pieces [Hash<Array<String>>] algebraic notations in string
      # @return [ChessPiece]
      def fetch_piece(query)
        return puts "'#{query}' is not a valid notation." unless usable_pieces[player.side].include?(query)

        turn_data[alg_map[query.to_sym]]
      end

      # Grab all pieces, only whites or only blacks
      # @param side [Symbol] expects :all, :white or :black
      # @param type [ChessPiece, King, Queen, Rook, Bishop, Knight, Pawn] limit selection
      # @return [Array<ChessPiece>] a list of chess pieces
      def fetch_all(side = :all, type: ChessPiece)
        turn_data.select { |tile| tile.is_a?(type) && (%i[black white].include?(side) ? tile.side == side : true) }
      end

      # Lookup a piece based on its possible move position
      # @param side [Symbol]
      # @param type [Symbol]
      # @param target [String]
      # @param file_rank [String]
      def reverse_lookup(side, type, target, file_rank = nil)
        type = Chess.const_get(FEN.dig(type, :class))
        filtered_pieces = fetch_all(side, type: type)
        new_alg_pos = alg_map[target.to_sym]
        result = filtered_pieces.select do |piece|
          next unless usable_pieces[side].include?(piece.info)

          piece.possible_moves.include?(new_alg_pos) && (file_rank.nil? || piece.info.include?(file_rank))
        end
        return nil if result.size > 1

        result[0]
      end

      # == Board Logic ==

      # Actions to perform when player input is valid
      # @return [Boolean] true if the operation is a success
      def refresh
        update_board_state
        board.print_chessboard
        true
      end

      private

      # Initialise the chessboard
      def init_level
        @turn_data, @white_turn, @castling_states, @en_passant, @half_move, @full_move =
          fen_data.values_at(:turn_data, :white_turn, :castling_states, :en_passant, :half, :full)
        controller.link_level(self)
        @kings = { white: nil, black: nil }
        @threats_map = { white: [], black: [] }
        @usable_pieces = { white: [], black: [] }
        @player = w_player
        kings_table
        load_en_passant_state
        update_board_state
      end

      # Main Game Loop
      def play_chess
        self.player = white_turn ? w_player : b_player
        # Pre turn
        refresh
        # Play turn
        player.play_turn
        # Post turn
        save_turn
        self.white_turn = !white_turn
      end

      # Save turn handling
      def save_turn
        session_data =
          { turn_data: turn_data, white_turn: white_turn, castling_states: castling_states, en_passant: en_passant,
            half: half_move, full: full_move }
        p to_fen(session_data)
      end

      # Endgame handling
      def end_game
        p "Game session complete, \nShould return to game.rb"
      end

      # Get and store both Kings
      def kings_table
        fetch_all(type: King).each { |king| kings[king.side] = king }
      end

      # Restore En passant status based on FEN data
      def load_en_passant_state
        return if en_passant.nil?

        pawn_query, ghost_pos = en_passant
        en_passant[0] = turn_data[alg_map[pawn_query.to_sym]]
        en_passant[1] = alg_map[ghost_pos.to_sym]
      end

      # Generate possible moves & targets for all pieces, all whites or all blacks
      # @param side [Symbol] expects :all, :white or :black
      def generate_moves(side = :all)
        side = :all unless %i[black white].include?(side)
        fetch_all(side).each(&:query_moves)
      end

      # Board state refresher
      def update_board_state
        @threats_map, @usable_pieces = board_analysis(generate_moves)
        any_checkmate?
        # puts usable_pieces
        # puts threats_map
      end

      # End game if either side achieved a checkmate
      def any_checkmate?
        kings.values.any?(&:checkmate?)
      end

      # User data handling
    end
  end
end
