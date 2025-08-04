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

      # @!attribute [r] w_player
      #   @return [ChessPlayer, ChessComputer]
      # @!attribute [r] b_player
      #   @return [ChessPlayer, ChessComputer]
      # @!attribute [r] kings
      #   @return [Hash{Symbol => King}]
      attr_accessor :fen_data, :white_turn, :turn_data, :active_piece, :en_passant, :player, :half_move, :full_move,
                    :game_ended, :event_msgs
      attr_reader :controller, :w_player, :b_player, :session, :board, :kings, :castling_states, :threats_map,
                  :usable_pieces, :opponent

      # @param input [ChessInput]
      # @param sides [Hash]
      #   @option sides [ChessPlayer, ChessComputer] :white Player who plays as White
      #   @option sides [ChessPlayer, ChessComputer] :black Player who plays as Black
      # @param session [Hash] current session
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
        add_check_marker
        board.print_turn(event_msgs) if print_turn
      end

      # Board state refresher
      def update_board_state = board_analysis.each { |var, v| instance_variable_set("@#{var}", v) }

      # Simulate next move - Find good moves
      # @param piece [ChessPiece] expects a ChessPiece object
      # @return [nil, Array<Integer>] good moves
      # @see MovesSimulation #simulate_next_moves
      def simulate_next_moves(piece) = piece.nil? ? nil : MovesSimulation.simulate_next_moves(self, piece)

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

      # == Export ==

      # Update session moves record
      def update_session_moves
        move_pairs = build_move_pairs(*all_moves)
        rebuild_moves_record(move_pairs)
      end

      # Check for end game condition
      # @return [Hash, nil] if it is hash message the game will end.
      # @see EndgameLogic #game_end_check
      def game_end_check
        case EndgameLogic.game_end_check(self)
        in nil then self.game_ended = false
        in { draw: type } then handle_result(type:)
        in { checkmate: side } then handle_result(type: "checkmate", side:)
        end
      end

      private

      # Initialise the chessboard
      def init_level
        @kings = PieceAnalysis.bw_nil_hash
        @threats_map, @usable_pieces = Array.new(2) { PieceAnalysis.bw_arr_hash }
        @event_msgs = []
        fen_data.each { |field, v| instance_variable_set("@#{field}", v) }
        set_current_player
        refresh(print_turn: false)
        greet_player
      end

      # greet player on load, message should change depending on load state
      def greet_player
        keypath = full_move == 1 ? "session.new" : "session.load"
        event_msgs.push(board.s(keypath, { event: session[:event], p1: player.name }))
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
      def set_current_player
        @player, @opponent = white_turn ? [w_player, b_player] : [b_player, w_player]
      end

      # Generate all possible move and send it to board analysis
      # @see PieceAnalysis #board_analysis
      # @return [Hash]
      def board_analysis = PieceAnalysis.board_analysis(fetch_all.each(&:query_moves))

      # == Endgame Logics ==

      # Handle checkmate and draw event
      # @param type [String] grounds of draw
      # @param side [Symbol, nil] player side
      # @return [Boolean]
      def handle_result(type:, side: nil)
        update_event_status(type:)
        save_turn
        winner = session[opposite_of(side)]
        kings[side].color = "#CC0000" if type == "checkmate"
        event_msgs << board.s("level.endgame.#{type}", { win_player: winner })
        board.print_turn(event_msgs[-1])
        @game_ended = true
      end

      # Update event state
      def update_event_status(type:) = session[:event].sub!(board.s("status.ongoing"), board.s("status.#{type}"))

      # Add checked or checkmate marker to opponent's last move
      def add_check_marker
        side = player.side
        return unless kings[side].checked

        last_move = opponent.moves_history[-1]
        return if last_move.nil? || last_move.match?(/\A[a-zA-Z1-8]*[+#]\z/)

        marker = game_ended ? "#" : "+"
        opponent.moves_history[-1] = last_move + marker
      end

      # == Data Handling ==

      # Parse FEN string data and convert this to usable internal data hash
      # @param fen_import [String, nil] expects a complete FEN string
      # @return [Hash<Hash>] FEN data hash for internal use
      # @see FenImport #parse_fen
      def parse_fen(fen_import = nil) = FenImport.parse_fen(self, fen_import)

      # Convert internal data to FEN friendly string
      # @return [String] fen string
      # @see FenExport #to_fen
      def to_fen = FenExport.to_fen(self)

      # Save turn handling
      def save_turn
        save_player_move
        @full_move = calculate_full_move
        fen_str = to_fen
        session[:fens].push(fen_str) if session.fetch(:fens)[-1] != fen_str
        controller.save(mute: true)
      end

      # Save player move to session
      def save_player_move
        key = player.side == w_sym ? :white_moves : :black_moves
        last_move = player.moves_history.last
        session[key] << last_move unless last_move.nil? || session[key].last == last_move
      end

      # Calculate the full move
      # @return [Integer]
      def calculate_full_move = session[:black_moves].size + 1

      # Rebuild session moves record
      def rebuild_moves_record(move_pairs)
        session[:moves] = {}
        move_pairs.each_with_index { |pair, i| session[:moves][i + 1] = pair }
      end

      # Fetch moves history from both player
      # @return [Array<Array<String>>]
      def all_moves = [w_player, b_player].map(&:moves_history)

      # Build a nested array of move pairs
      # @return [Array<Array<String>>] move_pair
      def build_move_pairs(w_moves, b_moves) = w_moves.zip(b_moves).reject { |turn| turn.include?(nil) }
    end
  end
end
