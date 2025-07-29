# frozen_string_literal: true

require_relative "game"
require_relative "logics/logic"
require_relative "logics/piece_analysis"
require_relative "logics/piece_lookup"
require_relative "logics/endgame_logic"
require_relative "logics/moves_simulation"
require_relative "board"
require_relative "pieces/chess_piece"
require_relative "pieces/king"
require_relative "pieces/queen"
require_relative "pieces/bishop"
require_relative "pieces/knight"
require_relative "pieces/rook"
require_relative "pieces/pawn"
require_relative "utilities/fen_import"
require_relative "utilities/fen_export"

module ConsoleGame
  module Chess
    # The Level class handles the core game loop of the game Chess
    # @author Ancient Nimbus
    class Level
      include Logic
      include FenImport

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
      # @param import_fen [String] expects a valid FEN string
      def initialize(input, sides, session, import_fen = nil)
        @controller = input
        @w_player, @b_player = sides.values
        @session = session
        @board = Board.new(self)
        controller.link_level(self)
        @fen_data = import_fen.nil? ? parse_fen(self) : parse_fen(self, import_fen)
      end

      # == Flow ==

      # Start level
      def open_level
        init_level
        play_chess until game_ended
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

      # Main Game Loop
      def play_chess
        # Pre turn
        save_turn
        set_current_player
        refresh
        return if game_ended

        player.play_turn
        # Post turn
        self.white_turn = !white_turn
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

      # Convert internal data to FEN friendly string
      # @return [String] fen string
      def to_fen = FenExport.to_fen(self)

      # Helper: Process move history and full move counter
      # @return [Integer]
      def format_full_move
        w_moves, b_moves = all_moves
        move_pair = w_moves.zip(b_moves).reject { |turn| turn.include?(nil) }.last
        curr_turn = session[:moves].size + 1
        session[:moves][curr_turn] = move_pair if white_turn && !move_pair.nil?
        @full_move = curr_turn
      end

      # Fetch moves history from both player
      # @return [Array<Array<String>>]
      def all_moves = [w_player, b_player].map(&:moves_history)

      # # Override: Process flow when there is an issue during FEN parsing
      # # @param level [Chess::Level] Chess level object
      # # @param fen_str [String] expects a string in FEN format
      # # @param err_msg [String] error message during FEN error
      # def fen_error(level, fen_str, err_msg: board.s("fen.err")) = super

      # == Endgame Logics ==

      # Check for end game condition
      # @return [Boolean]
      # @see EndgameLogic #game_end_check
      def game_end_check = @game_ended = EndgameLogic.new(self).game_end_check
    end
  end
end
