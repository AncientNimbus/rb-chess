# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The EndgameLogic class defines the various logics to determine whether the game is a draw or checkmates
    # @author Ancient Nimbus
    class EndgameLogic
      # Check for end game condition
      # @param [Level] expects a Chess::Level class object
      # @return [Boolean]
      def self.game_end_check(...) = new(...).game_end_check

      # @!attribute [r] player
      #   @return [ChessPlayer, ChessComputer] player of the current turn
      # @!attribute [r] side
      #   @return [Symbol] side of the current player
      # @!attribute [r] usable_pieces
      #   @return [Hash] all usable pieces from both sides
      # @!attribute [r] threats_map
      #   @return [Hash] all threats affecting both sides
      # @!attribute [r] half_move
      #   @return [Integer] half move clock value
      # @!attribute [r] fen_records
      #   @return [Hash<String>] fen session history
      # @!attribute [r] kings
      #   @return [Hash<King>] all kings as hash
      # @!attribute [r] update_state
      #   @return [Method] refresh level state
      attr_reader :player, :side, :usable_pieces, :threats_map, :half_move, :fen_records, :kings, :update_state,
                  :group_fetch

      # @param level [Level] expects a Chess::Level class object
      def initialize(level)
        @level = level
        @player = level.player
        @side = player.side
        @usable_pieces = level.usable_pieces
        @threats_map = level.threats_map
        @half_move = level.half_move
        @fen_records = level.session[:fens]
        @kings = level.kings
        @update_state = level.update_board_state
        @group_fetch = level.method(:group_fetch)
      end

      # Check for end game condition
      # @return [Boolean]
      def game_end_check = draw? || any_checkmate? ? true : false

      private

      # == Checkmate ==

      # End game if either side achieved a checkmate
      # @return [Boolean] return true if either side is checkmate
      def any_checkmate? = kings.values.any?(&:checkmate?)

      # == Rules for Draw ==

      # End game if is it a draw
      # @return [Boolean] the game is a draw when true
      def draw?
        update_state
        [stalemate?, insufficient_material?(*last_four), half_move_overflow?, threefold_repetition?].any?
      end

      # Game is a stalemate
      # @return [Boolean] the game is a draw when true
      def stalemate? = usable_pieces[side].empty? && threats_map[side].empty?

      # Game is a draw due to insufficient material
      # @see https://support.chess.com/en/articles/8705277-what-does-insufficient-mating-material-mean
      # @param remaining_pieces [Array<ChessPiece>]
      # @param remaining_notations [Array<String>]
      # @return [Boolean] the game is a draw when true
      def insufficient_material?(remaining_pieces, remaining_notations)
        return false if remaining_pieces.nil? || remaining_notations.nil?
        return false unless bishops_insufficient_material?(remaining_pieces)

        insufficient_patterns = %w[KK KBK KKN KBKB KNKN]
        insufficient_patterns.any? { |combo| combo.chars.sort == remaining_notations.sort }
      end

      # Insufficient material helper: check if two bishops are from the same side or on the same color tile
      # @param pieces [Array<ChessPiece>] remaining ChessPiece
      # @return [Boolean] continue insufficient material flow
      def bishops_insufficient_material?(pieces)
        bishops = pieces.select { |piece| piece.is_a?(Bishop) }
        return true if bishops.size <= 1
        return false if bishops.size > 2

        bishop1, bishop2 = bishops
        return false if bishop1.side == bishop2.side

        b1_ord, b2_ord = bishops.map { |bishop| bishop.file.ord + bishop.rank.to_i }
        b1_ord == b2_ord
      end

      # Determine the minimum qualifying requirement to enter the #insufficient_material? flow
      # @return [Array<nil>, Array<Array<ChessPiece>, Array<String>>]
      def last_four
        pieces = usable_pieces.values
        pieces.sum(&:size) > 4 ? [nil, nil] : group_fetch.call(pieces)
      end

      # Game is a draw due to Fifty-move rule
      # @return [Boolean] the game is a draw when true
      def half_move_overflow? = half_move >= 100

      # Game is a draw due to Threefold Repetition
      # @return [Boolean] the game is a draw when true
      def threefold_repetition?
        return false unless fen_records.size > 10

        sectioned_fen_records = fen_records.last(100).map { |fen| fen.split(" ")[0...-2].join(" ") }
        sectioned_fen_records.count(sectioned_fen_records.last) >= 3
      end
    end
  end
end
