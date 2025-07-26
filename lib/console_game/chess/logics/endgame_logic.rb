# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The EndgameLogic module defines the various logics to determine whether the game is a draw or checkmates
    # @author Ancient Nimbus
    module EndgameLogic
      private

      # == Checkmate ==

      # End game if either side achieved a checkmate
      # @param kings [Hash<King>] a hash with Kings in it
      # @return [Boolean] return true if either side is checkmate
      def any_checkmate?(kings) = kings.values.any?(&:checkmate?)

      # == Rules for Draw ==

      # End game if is it a draw
      # @param side [Symbol] current player side
      # @param usable_pieces [Hash] expects a usable_pieces hash from chess level
      # @param threats_map [Hash] expects a threat_map hash from chess level
      # @param last_four [Array<nil>, Array<Array<ChessPiece>, Array<String>>]
      # @param half_move [Integer] half move clock
      # @param session [Array<String>] fen history
      # @return [Boolean] the game is a draw when true
      def draw?(side:, usable_pieces:, threats_map:, last_four:, half_move:, session:)
        [
          stalemate?(side, usable_pieces, threats_map), insufficient_material?(*last_four),
          half_move_overflow?(half_move), threefold_repetition?(session)
        ].any?
      end

      # Game is a stalemate
      # @param side [Symbol] expects player side, :black or :white
      # @param usable_pieces [Hash<Array<String>>]
      # @param threats_map [Hash<Set<Integer>>]
      # @return [Boolean] the game is a draw when true
      def stalemate?(side, usable_pieces, threats_map) = usable_pieces[side].empty? && threats_map[side].empty?

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

      # Game is a draw due to Fifty-move rule
      # @param half_move_count [Integer] half-move clock count
      # @return [Boolean] the game is a draw when true
      def half_move_overflow?(half_move_count) = half_move_count >= 100

      # Game is a draw due to Threefold Repetition
      # @param fen_records [Array<String>] expects :fens from a single session
      # @return [Boolean] the game is a draw when true
      def threefold_repetition?(fen_records)
        return false unless fen_records.size > 10

        sectioned_fen_records = fen_records.last(100).map { |fen| fen.split(" ")[0...-2].join(" ") }
        sectioned_fen_records.count(sectioned_fen_records.last) >= 3
      end
    end
  end
end
