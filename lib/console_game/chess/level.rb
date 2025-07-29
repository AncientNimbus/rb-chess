# frozen_string_literal: true

require_relative "game"
require_relative "board"
require_relative "logics/piece_analysis"
require_relative "logics/piece_lookup"
require_relative "logics/endgame_logic"
require_relative "logics/moves_simulation"
require_relative "pieces/king"
require_relative "pieces/queen"
require_relative "pieces/bishop"
require_relative "pieces/knight"
require_relative "pieces/rook"
require_relative "pieces/pawn"
require_relative "utilities/fen_import"
require_relative "utilities/fen_export"
require_relative "utilities/chess_utils"

module ConsoleGame
  module Chess
    # The Level class handles the core game loop of the game Chess
    # @author Ancient Nimbus
    class Level
      include ChessUtils

      # @!attribute [w] player
      #   @return [ChessPlayer, ChessComputer]
      attr_accessor :fen_data, :white_turn, :turn_data, :active_piece, :en_passant, :player, :half_move, :full_move,
                    :game_ended, :event_msgs
      attr_reader :controller, :w_player, :b_player, :session, :board, :kings, :castling_states, :threats_map,
                  :usable_pieces

      # @param input [ChessInput]
      # @param sides [hash]
      #   @option sides [ChessPlayer, ChessComputer] :white Player who plays as White
      #   @option sides [ChessPlayer, ChessComputer] :black Player who plays as Black
      # @param session [hash] current session
      # @param fen_import [String] expects a valid FEN string
      def initialize(input, sides, session, fen_import = nil)
        @controller = input
        @w_player, @b_player = sides.values
        @session = session
        @board = Board.new(self)
        controller.link_level(self)
        @fen_data = fen_import.nil? ? parse_fen : parse_fen(fen_import)
      end

      # == Flow ==

      # Start level
      def open_level
        init_level
        play_chess until game_ended
      end

      # == Board Logic ==

      # Actions to perform when player input is valid
      # @param print_turn [Boolean] print board if is it set to true
      # @return [Boolean] true if the operation is a success
      def refresh(print_turn: true)
        @piece_lookup = nil
        update_board_state
        game_end_check
        board.print_turn(event_msgs) if print_turn
      end

      # Board state refresher
      # Generate all possible move and send it to board analysis
      # @see PieceAnalysis #board_analysis
      def update_board_state
        @threats_map, @usable_pieces = PieceAnalysis.board_analysis(fetch_all.each(&:query_moves))
      end

      # Simulate next move - Find good moves
      # @param piece [ChessPiece] expects a ChessPiece object
      # @return [Array<Integer>] good moves
      # @see MovesSimulation #simulate_next_moves
      def simulate_next_moves(piece) = MovesSimulation.simulate_next_moves(self, piece)

      # == Game Logic ==

      # Pawn specific: Present a list of option when player can promote a pawn
      def promote_opts = player.indirect_promote

      # Reset En Passant status when it is not used at the following turn
      def reset_en_passant
        return if en_passant.nil? || active_piece == en_passant[0]

        self.en_passant = nil if active_piece.curr_pos != en_passant[1]
      end

      # == Utilities ==

      # Create new piece lookup service
      # @return [PieceLookup]
      def piece_lookup = @piece_lookup ||= PieceLookup.new(self)

      # Fetch a single chess piece
      # @see PieceLookup #fetch_piece
      def fetch_piece(...) = piece_lookup.fetch_piece(...)

      # Fetch a group of pieces notation from turn_data based on algebraic notation
      # @see PieceLookup #group_fetch
      def group_fetch(...) = piece_lookup.group_fetch(...)

      # Grab all pieces, only whites or only blacks
      # @see PieceLookup #fetch_all
      def fetch_all(...) = piece_lookup.fetch_all(...)

      # Lookup a piece based on its possible move position
      # @see PieceLookup #reverse_lookup
      def reverse_lookup(...) = piece_lookup.reverse_lookup(...)

      private

      # Initialise the chessboard
      def init_level
        @kings = PieceAnalysis.bw_nil_hash
        @turn_data, @white_turn, @castling_states, @en_passant, @half_move, @full_move = fen_data.values_at(
          :turn_data, :white_turn, :castling_states, :en_passant, :half, :full
        )
        @threats_map, @usable_pieces = Array.new(2) { PieceAnalysis.bw_arr_hash }
        @event_msgs = []
        set_current_player
        load_en_passant_state
        refresh(print_turn: false)
      end

      # Pre-turn flow
      def pre_turn
        save_turn
        set_current_player
        player.link_level(self)
        refresh
      end

      # Main Game Loop
      def play_chess
        pre_turn
        return if game_ended

        player_action

        # Post turn
        self.white_turn = !white_turn
      end

      # Player action flow
      def player_action
        board.print_msg(board.s("level.turn", { player: player.name }), pre: "* ")
        player.is_a?(ChessComputer) ? player.play_turn : controller.turn_action(player)
      end

      # Set player side
      # @return [ChessPlayer, ChessComputer]
      def set_current_player = @player = white_turn ? w_player : b_player

      # Restore En passant status based on FEN data
      def load_en_passant_state
        return if en_passant.nil?

        en_passant[0] = fetch_piece(en_passant[0], bypass: true)
        en_passant[1] = alg_map[en_passant[1].to_sym]
      end

      # == Data Handling ==

      # Save turn handling
      def save_turn
        format_full_move
        fen_str = to_fen
        session[:fens].push(fen_str) if session.fetch(:fens)[-1] != fen_str
        controller.save(mute: true)
      end

      # Parse FEN string data and convert this to usable internal data hash
      # @param fen_import [String, nil] expects a complete FEN string
      # @return [Hash<Hash>] FEN data hash for internal use
      # @see FenImport #parse_fen
      def parse_fen(fen_import = nil) = FenImport.parse_fen(self, fen_import)

      # Convert internal data to FEN friendly string
      # @return [String] fen string
      # @see FenExport #to_fen
      def to_fen = FenExport.to_fen(self)

      # Process move history and full move counter
      def format_full_move
        w_moves, b_moves = all_moves
        move_pair = w_moves.zip(b_moves).reject { |turn| turn.include?(nil) }.last
        @full_move = calculate_full_move
        session[:moves][full_move] = move_pair if white_turn && !move_pair.nil?
      end

      # Fetch moves history from both player
      # @return [Array<Array<String>>]
      def all_moves = [w_player, b_player].map(&:moves_history)

      # Calculate the full move
      # @return [Integer]
      def calculate_full_move = session[:moves].size + 1

      # == Endgame Logics ==

      # Check for end game condition
      # @return [Boolean]
      # @see EndgameLogic #game_end_check
      def game_end_check = @game_ended = EndgameLogic.game_end_check(self)
    end
  end
end
