# frozen_string_literal: true

require_relative "chess_utils"

module ConsoleGame
  module Chess
    # FenImport is a class that performs FEN data parsing operations.
    # It is compatible with most online chess site, and machine readable.
    # @author Ancient Nimbus
    # @version v1.2.0
    class FenImport
      include ChessUtils
      # FEN default values
      FEN = { w_start: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }.merge(ALG_REF).freeze

      # FEN Raw data parser (FEN import)
      # @param level [Level] expects chess Level object
      # @param fen_import [String] expects a complete FEN string
      # @return [Hash<Hash>] FEN data hash for internal use
      def self.parse_fen(...) = new(...).parse_fen

      # @!attribute [r] level
      #   @return [Level] chess Level object
      # @!attribute [r] fen_str
      #   @return [String] a complete FEN string
      attr_reader :level, :fen_str

      # @param level [Level] expects chess Level object
      # @param fen_import [String, nil] expects a complete FEN string
      def initialize(level, fen_import = nil)
        @level = level
        @fen_str = fen_import.nil? ? FEN[:w_start] : fen_import
      end

      # == FEN Import ==

      # FEN Raw data parser (FEN import)
      # @return [Hash<Hash>] FEN data hash for internal use
      def parse_fen
        fen = fen_str&.split
        return fen_error if fen.nil? || fen.size != 6

        fen_data = process_fen_data(fen)
        return fen_error if fen_data.any?(&:nil?)

        board_data, active_player, castling, en_passant, h_move, f_move = fen_data
        { **board_data, **active_player, **castling, **en_passant, **h_move, **f_move }
      end

      private

      # Helper: Batch process FEN parsing operations
      # @param fen_data [Array<String>] expects splitted FEN as an array
      # @return [Array<Hash, nil>]
      def process_fen_data(fen_data)
        fen_board, active_color, c_state, ep_state, halfmove, fullmove = fen_data
        [
          parse_piece_placement(fen_board), parse_active_color(active_color), parse_castling_str(c_state),
          parse_en_passant(ep_state), parse_move_num(halfmove, :half), parse_move_num(fullmove, :full)
        ]
      end

      # Process flow when there is an issue during FEN parsing
      # @param err_msg [String] error message during FEN error
      def fen_error(err_msg: "FEN error, '#{fen_str}' is not a valid sequence. Starting a new game...")
        puts err_msg
        self.class.parse_fen(level)
      end

      # Process FEN board data field
      # @param fen_board [String] expects an Array with FEN positions data
      # @return [Hash<Array<ChessPiece, String>>, nil] chess position data starts from a1..h8
      def parse_piece_placement(fen_board)
        turn_data = Array.new(8) { [] }
        pos_value = 0
        fen_board.split("/").reverse.each_with_index do |rank, row|
          return nil unless rank.match?(/\A[kqrbnp1-8]+\z/i)

          normalise_fen_rank(rank).each_with_index do |unit, col|
            turn_data[row][col] = /\A\d\z/.match?(unit) ? "" : piece_maker(pos_value, unit)
            pos_value += 1
          end
        end
        @board_data = { turn_data: turn_data.flatten }
      end

      # Process the active colour field
      # @param color [String]
      # @return [Hash<Boolean>, nil]
      def parse_active_color(color) = %w[b w].include?(color) ? { white_turn: color == "w" } : nil

      # Process FEN castling field
      # @param c_state [String] expects a string with castling data
      # @return [Hash<Hash<Boolean>>, nil] a hash of castling statuses
      def parse_castling_str(c_state)
        castling_states = { K: false, Q: false, k: false, q: false }
        return { castling_states: castling_states } if c_state.empty? || c_state == "-"

        c_state.split("").each do |char|
          char_as_sym = char.to_sym
          return nil unless castling_states.key?(char_as_sym)

          castling_states[char_as_sym] = true
        end
        { castling_states: castling_states }
      end

      # Process FEN En-passant target square field
      # @param ep_state [String] expects a string with En-passant target square data
      # @return [Hash, nil] a hash of En-passant status
      def parse_en_passant(ep_state)
        return nil unless ep_state.match?(/\A[a-h][36]|-\z/)

        ep_pawn_rank = ep_state.include?("6") ? "5" : "4"
        ep_pawn = "#{ep_state[0]}#{ep_pawn_rank}"

        { en_passant: ep_state == "-" ? nil : [fetch_ep_pawn(ep_pawn), ep_ghost_pos(ep_state)] }
      end

      # En-passant helper: convert en passant pawn location to real pawn object
      # @param alg_pos [String] expects algebraic notation
      def fetch_ep_pawn(alg_pos) = @board_data[:turn_data].fetch(to_1d_pos(alg_pos))

      # En-passant helper: convert ghost position to positional value
      # @param alg_pos [String] expects algebraic notation
      def ep_ghost_pos(alg_pos) = to_1d_pos(alg_pos)

      # Process FEN Half-move clock or Full-move field
      # @param num [String] expects a string with either half-move or full-move data
      # @param type [Symbol] specify the key type for the hash
      # @return [Hash, nil] a hash of either half-move or full-move data
      def parse_move_num(num, type) = num.match?(/\A\d+\z/) && %i[half full].include?(type) ? { type => num.to_i } : nil

      # Initialize chess piece via string value
      # @param pos [Integer] positional value
      # @param fen_notation [String] expects a single letter that follows the FEN standard
      # @return [Chess::King, Chess::Queen, Chess::Bishop, Chess::Rook, Chess::Knight, Chess::Pawn]
      def piece_maker(pos, fen_notation)
        side = fen_notation == fen_notation.capitalize ? :white : :black
        class_name = FEN[fen_notation.downcase.to_sym][:class]
        Chess.const_get(class_name).new(pos, side, level:)
      end

      # Helper method to uncompress FEN empty cell values so that all arrays share the same size
      # @param str [String]
      # @return [Array] processed rank data array
      def normalise_fen_rank(str) = str.split("").map { |c| c.sub(/\A\d\z/, "0" * c.to_i).split("") }.flatten
    end
  end
end
