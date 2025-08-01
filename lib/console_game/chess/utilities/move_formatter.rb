# frozen_string_literal: true

require_relative "chess_utils"
require_relative "../input/algebraic_notation"

module ConsoleGame
  module Chess
    # Move Formatter is a class that convert legal chess move to PGN standard
    # It is compatible with most online chess site, and machine readable.
    # @author Ancient Nimbus
    class MoveFormatter
      include ChessUtils
      include AlgebraicNotation

      # @!attribute [r] move_pairs
      #   @return [Hash{Symbol => Array<String>}]
      # @!attribute [r] player
      #   @return [ChessPlayer, ChessComputer]
      # @!attribute [r] piece
      #   @return [ChessPiece]
      # @!attribute [r] last_move
      #   @return [String]
      attr_reader :level, :move_pairs, :player, :alg_reg, :piece, :last_move

      # @param player [ChessPlayer, ChessComputer]
      # @param active_piece [ChessPiece]
      def initialize(player)
        @player = player
        @alg_reg = regexp_algebraic
      end

      # Convert player move into pgn move
      # @return [String]
      def to_pgn_move
        init_query
        p alg_output_capture_gps(last_move)
        modify_last_move
        last_move
      end

      # Modify last move during a check event
      # @param mate [Boolean]
      def modify_last_move(mate: false)
        p move_pairs
        last_pair = move_pairs.values.last
        p last_pair
        # p move_pairs
      end

      private

      # Init active piece
      def init_query
        @level ||= player.level
        @move_pairs = level.session[:moves]
        @piece = player.piece_at_hand
        @last_move = piece.last_move
      end

      # Fetch previous move from session

      # Override Helper: Process regexp and returns a named capture groups
      # @param input [String] input value from prompt
      # @return [Hash]
      def alg_output_capture_gps(input) = super(input, alg_reg).merge({ input: })
    end
  end
end
