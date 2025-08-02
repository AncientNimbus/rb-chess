# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The EndgameLogic class defines the various logics to determine whether the game is a draw or checkmates
    # @author Ancient Nimbus
    class EndgameLogic
      # Check for end game condition
      # @return [Hash, nil]
      def self.game_end_check(...) = new(...).game_end_check

      # @!attribute [r] level
      #   @return [Level] current level
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
      attr_reader :level, :player, :side, :usable_pieces, :threats_map, :half_move, :fen_records, :kings

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
      end

      # Check for end game condition
      # @return [Hash, nil]
      def game_end_check
        condition = draw?
        return condition unless condition.nil?

        condition = any_checkmate?
        return condition unless condition.nil?

        nil
      end

      private

      # == Checkmate ==

      # End game if either side achieved a checkmate
      # @return [Hash, nil] return a message if either side is checkmate
      def any_checkmate?
        fallen_king = kings.values.select(&:checkmate?)
        fallen_king.empty? ? nil : { checkmate: fallen_king.first.side }
      end

      # == Rules for Draw ==

      # End game if is it a draw
      # @return [Hash, nil] the game is a draw when true
      def draw? = [stalemate?, fifty_move?, threefold_repetition?, insufficient_material?(*last_four)].compact.first

      # Game is a stalemate
      # @return [Hash, nil] returns a message if it is a draw
      def stalemate? = usable_pieces[side].empty? && threats_map[side].empty? ? { draw: "stalemate" } : nil

      # Game is a draw due to Fifty-move rule
      # @return [Hash, nil] returns a message if it is a draw
      def fifty_move? = half_move >= 100 ? { draw: "fifty_move" } : nil

      # Game is a draw due to Threefold Repetition
      # @return [Hash, nil] returns a message if it is a draw
      def threefold_repetition?
        return nil unless fen_records.size > 10

        sectioned_fen_records = fen_records.last(100).map { |fen| fen.split(" ")[0...-2].join(" ") }
        sectioned_fen_records.count(sectioned_fen_records.last) >= 3 ? { draw: "threefold" } : nil
      end

      # Game is a draw due to insufficient material
      # @see https://support.chess.com/en/articles/8705277-what-does-insufficient-mating-material-mean
      # @param remaining_pieces [Array<ChessPiece>]
      # @param remaining_notations [Array<String>]
      # @return [Hash, nil] returns a message if it is a draw
      def insufficient_material?(remaining_pieces, remaining_notations)
        return nil if remaining_pieces.nil? || remaining_notations.nil?
        return nil unless bishops_insufficient_material?(remaining_pieces)

        insufficient_patterns = %w[KK KBK KKN KBKB KNKN]
        return nil unless insufficient_patterns.any? { |combo| combo.chars.sort == remaining_notations.sort }

        { draw: "insufficient" }
      end

      # Determine the minimum qualifying requirement to enter the #insufficient_material? flow
      # @return [Array<nil>, Array<Array<ChessPiece>, Array<String>>]
      def last_four
        pieces = usable_pieces.values
        pieces.sum(&:size) > 4 ? [nil, nil] : level.group_fetch(pieces)
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
    end
  end
end
