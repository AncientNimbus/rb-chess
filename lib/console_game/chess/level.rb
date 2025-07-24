# frozen_string_literal: true

require_relative "game"
require_relative "logics/logic"
require_relative "logics/piece_analysis"
require_relative "logics/piece_lookup"
require_relative "logics/endgame_logic"
require_relative "board"
require_relative "utilities/fen_import"
require_relative "utilities/fen_export"

module ConsoleGame
  module Chess
    # The Level class handles the core game loop of the game Chess
    # @author Ancient Nimbus
    class Level
      include Logic
      include EndgameLogic
      include PieceAnalysis
      include PieceLookup
      include FenImport
      include FenExport

      # @!attribute [w] player
      #   @return [ChessPlayer, ChessComputer]
      attr_accessor :fen_data, :white_turn, :turn_data, :active_piece, :en_passant, :player, :half_move, :full_move,
                    :game_ended, :event_msgs
      attr_reader :controller, :w_player, :b_player, :session, :board, :kings, :castling_states,
                  :threats_map, :usable_pieces

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

      # Override: Fetch a single chess piece
      # @param query [String] algebraic notation `"e4"`
      # @param choices [Array<String>] usable pieces available to the current player
      # @param t_data [Array<ChessPiece, String>] expects level turn_data array
      # @param alg_dict [#call] expects a method to convert query to board position
      # @param bypass [Boolean] for internal use only, use this to bypass user-end validation
      # @param warn_msg [String] User warning during bad input
      # @return [ChessPiece]
      def fetch_piece(query, choices: usable_pieces[player.side], t_data: turn_data, alg_dict: method(:to_1d_pos),
                      bypass: false, warn_msg: board.s("level.err.notation")) = super

      # Override: Fetch a group of pieces notation from turn_data based on algebraic notation
      # @param query [Array<String>]
      # @param pieces [Array<ChessPiece>]
      # @param choices [Array<String>] usable pieces available to the current player
      # @param t_data [Array<ChessPiece, String>] expects level turn_data array
      # @return [Array<Array<ChessPiece>, Array<String>>]
      def group_fetch(query, pieces: [], choices: usable_pieces[player.side], t_data: turn_data) = super

      # Override: Grab all pieces, only whites or only blacks
      # @param side [Symbol] expects :all, :white or :black
      # @param type [ChessPiece, King, Queen, Rook, Bishop, Knight, Pawn] limit selection
      # @param t_data [Array<ChessPiece, String>] expects level turn_data array
      # @return [Array<ChessPiece>] a list of chess pieces
      def fetch_all(side = :all, type: ChessPiece, t_data: turn_data) = super

      # Override: Lookup a piece based on its possible move position
      # @param side [Symbol] :black or :white
      # @param type [Symbol] expects a notation
      # @param target [String] expects a algebraic notation
      # @param file_rank [String] expects a file rank data
      # @param available_pieces [Hash] expects a usable_pieces hash from chess level
      # @param piece_lib [Hash] expects a FEN reference hash
      # @param alg_dict [#call] expects a method to convert query to board position
      # @return [ChessPiece, nil]
      def reverse_lookup(side, type, target, file_rank = nil, available_pieces: usable_pieces, piece_lib: FEN,
                         alg_dict: method(:to_1d_pos)) = super

      # == Board Logic ==

      # Actions to perform when player input is valid
      # @param print_turn [Boolean] print board if is it set to true
      # @return [Boolean] true if the operation is a success
      def refresh(print_turn: true)
        update_board_state
        game_end_check
        board.print_turn(event_msgs) if print_turn
      end

      # Board state refresher
      # Generate all possible move and send it to board analysis
      def update_board_state
        @threats_map, @usable_pieces = board_analysis(fetch_all.each(&:query_moves))
      end

      # Override: Simulate next move - Find good moves
      # @param piece [ChessPiece] expects a ChessPiece object
      # @param t_data [Array<ChessPiece, String>] expects turn_data from Level
      # @param update_state [#call] expects #update_board_state method from Level
      # @param good_pos [Array<Integer>]
      # @return [Array<Integer>] good moves
      def simulate_next_moves(piece, t_data: turn_data, update_state: method(:update_board_state), good_pos: []) = super

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
        @kings = BW_HASH[:new_nil].call
        @turn_data, @white_turn, @castling_states, @en_passant, @half_move, @full_move = fen_data.values_at(
          :turn_data, :white_turn, :castling_states, :en_passant, :half, :full
        )
        @threats_map, @usable_pieces = Array.new(2) { BW_HASH[:new_arr].call }
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

        # Play turn
        player.play_turn

        # Post turn
        self.white_turn = !white_turn
      end

      # Set player side
      # @return [ChessPlayer, ChessComputer]
      def set_current_player = @player = white_turn ? w_player : b_player

      # Check for end game condition
      # @return [Boolean]
      def game_end_check = @game_ended = draw? || any_checkmate?(kings) ? true : false

      # Save turn handling
      def save_turn
        fen_str = fen_export(
          turn_data: turn_data, white_turn: white_turn, castling_states: castling_states,
          en_passant: format_en_passant, half: half_move, full: format_full_move
        )
        session[:fens].push(fen_str) if session.fetch(:fens)[-1] != fen_str
        controller.save(mute: true)
      end

      # Helper: Convert en passant data before export
      def format_en_passant = en_passant.nil? ? en_passant : [nil, to_alg_pos(en_passant[1])]

      # Helper: Process move history and full move counter
      # @return [Integer]
      def format_full_move
        w_moves, b_moves = all_moves
        move_pair = w_moves.zip(b_moves).reject { |turn| turn.include?(nil) }.last
        curr_turn = session[:moves].size + 1
        session[:moves][curr_turn] = move_pair if white_turn && !move_pair.nil?
        curr_turn
      end

      # Helper: Fetch moves history from both player
      # @return [Array<Array<String>>]
      def all_moves = [w_player, b_player].map(&:moves_history)

      # Restore En passant status based on FEN data
      def load_en_passant_state
        return if en_passant.nil?

        en_passant[0] = fetch_piece(en_passant[0], bypass: true)
        en_passant[1] = alg_map[en_passant[1].to_sym]
      end

      # == Endgame Logics ==

      # End game if is it a draw
      # @return [Boolean] the game is a draw when true
      def draw?
        update_board_state
        [
          stalemate?(player.side, usable_pieces, threats_map),
          insufficient_material?(*last_four),
          half_move_overflow?(half_move),
          threefold_repetition?(session[:fens])
        ].any?
      end

      # Determine the minimum qualifying requirement to enter the #insufficient_material? flow
      # @param pieces_pos [Array<Array<String>>] a combined array of all usable pieces from both colors
      # @return [Array<nil>, Array<Array<ChessPiece>, Array<String>>]
      def last_four(pieces = usable_pieces.values) = pieces.sum(&:size) > 4 ? [nil, nil] : group_fetch(pieces)
    end
  end
end
