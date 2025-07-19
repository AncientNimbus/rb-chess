# frozen_string_literal: true

require_relative "game"
require_relative "logics/logic"
require_relative "logics/piece_analysis"
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
      include FenImport
      include FenExport

      # @!attribute [w] player
      #   @return [ChessPlayer, ChessComputer]
      attr_accessor :white_turn, :turn_data, :active_piece, :en_passant, :player, :half_move, :full_move
      attr_reader :controller, :w_player, :b_player, :fen_data, :session, :board, :kings, :castling_states,
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
        @fen_data = import_fen.nil? ? parse_fen(self) : parse_fen(self, import_fen)
        @turn_data, @white_turn, @castling_states, @en_passant, @half_move, @full_move = fen_data.values_at(
          :turn_data, :white_turn, :castling_states, :en_passant, :half, :full
        )
        @board = Board.new(self)
        controller.link_level(self)
      end

      # == Flow ==

      # Start level
      def open_level
        init_level
        play_chess until game_ended
      end

      # == Game Logic ==

      # Pawn specific: Present a list of option when player can promote a pawn
      def promote_opts
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
      # @param bypass [Boolean] for internal use only, use this to bypass user-end validation
      # @return [ChessPiece]
      def fetch_piece(query, bypass: false)
        return puts "'#{query}' is not a valid notation." unless usable_pieces[player.side].include?(query) || bypass

        turn_data[alg_map[query.to_sym]]
      end

      # Fetch a group of pieces notation from turn_data based on algebraic notation
      # @param query [Array<String>]
      # @param pieces [Array<ChessPiece>]
      # @return [Array<Array<ChessPiece>, Array<String>>]
      def group_fetch(query, pieces: [])
        notations = query.flatten.map do |alg_pos|
          pieces << (piece = fetch_piece(alg_pos, bypass: true))
          piece.notation
        end
        [pieces, notations]
      end

      # Grab all pieces, only whites or only blacks
      # @param side [Symbol] expects :all, :white or :black
      # @param type [ChessPiece, King, Queen, Rook, Bishop, Knight, Pawn] limit selection
      # @return [Array<ChessPiece>] a list of chess pieces
      def fetch_all(side = :all, type: ChessPiece)
        turn_data.select { |tile| tile.is_a?(type) && (%i[black white].include?(side) ? tile.side == side : true) }
      end

      # Lookup a piece based on its possible move position
      # @param side [Symbol] :black or :white
      # @param type [Symbol] expects a notation
      # @param target [String] expects a algebraic notation
      # @param file_rank [String] expects a file rank data
      # @return [ChessPiece, nil]
      def reverse_lookup(side, type, target, file_rank = nil)
        type = Chess.const_get(FEN.dig(type, :class))
        filtered_pieces = fetch_all(side, type: type)
        result = refined_lookup(filtered_pieces, side, alg_map[target.to_sym], file_rank)
        result.size > 1 ? nil : result[0]
      end

      # == Board Logic ==

      # Actions to perform when player input is valid
      # @param print_board [Boolean] print board if is it set to true
      # @return [Boolean] true if the operation is a success
      def refresh(print_board: true)
        update_board_state
        game_ended
        board.print_chessboard if print_board
      end

      private

      # Initialise the chessboard
      def init_level
        @threats_map, @usable_pieces, = Array.new(2) { BW_HASH[:new_arr].call }
        @player = white_turn ? w_player : b_player
        @kings = BW_HASH[:new_nil].call.tap { |kings| fetch_all(type: King).each { |king| kings[king.side] = king } }
        load_en_passant_state
        refresh(print_board: false)
      end

      # Main Game Loop
      def play_chess
        # Pre turn
        save_turn
        self.player = white_turn ? w_player : b_player
        refresh
        return if game_ended

        # Play turn
        player.play_turn

        # Post turn
        self.white_turn = !white_turn
      end

      # Board state refresher
      # Generate all possible move and send it to board analysis
      def update_board_state
        @threats_map, @usable_pieces = board_analysis(fetch_all.each(&:query_moves))
      end

      # Check for end game condition
      # @return [Boolean]
      def game_ended
        any_checkmate?(kings) || draw?
      end

      # Save turn handling
      def save_turn
        fen_str = fen_export(
          turn_data: turn_data, white_turn: white_turn, castling_states: castling_states,
          en_passant: format_en_passant, half: half_move, full: full_move
        )
        session[:fens].push(fen_str) if session.fetch(:fens)[-1] != fen_str
        controller.save
      end

      # Helper: Convert en passant data before export
      def format_en_passant
        en_passant.nil? ? en_passant : [nil, to_alg_pos(en_passant[1])]
      end

      # Restore En passant status based on FEN data
      def load_en_passant_state
        return if en_passant.nil?

        en_passant[0] = fetch_piece(en_passant[0], bypass: true)
        en_passant[1] = alg_map[en_passant[1].to_sym]
      end

      # Helper: Filter pieces by checking whether it is usable at the current term with file info for extra measure
      # @param filtered_pieces [Array<ChessPiece>]
      # @param side [Symbol] :black or :white
      # @param new_pos [Integer] expects a positional value
      # @param file_rank [String] expects a file rank data
      # @return [Array<ChessPiece>]
      def refined_lookup(filtered_pieces, side, new_pos, file_rank)
        filtered_pieces.select do |piece|
          next unless usable_pieces[side].include?(piece.info)

          piece.possible_moves.include?(new_pos) && (file_rank.nil? || piece.info.include?(file_rank))
        end
      end

      # == Endgame Logics ==

      # End game if is it a draw
      # @return [Boolean] the game is a draw when true
      def draw?
        update_board_state
        [
          stalemate?(player.side, usable_pieces, threats_map),
          insufficient_material?(*insufficient_material_qualifier),
          half_move_overflow?(half_move),
          threefold_repetition?(session[:fens])
        ].any?
      end

      # Determine the minimum qualifying requirement to enter the #insufficient_material? flow
      # @param remaining_pieces_pos [Array<Array<String>>] a combined array of all usable pieces from both colors
      # @return [Array<nil>, Array<Array<ChessPiece>, Array<String>>]
      def insufficient_material_qualifier(remaining_pieces_pos = usable_pieces.values)
        remaining_pieces_pos.sum(&:size) > 4 ? [nil, nil] : group_fetch(remaining_pieces_pos)
      end
    end
  end
end
