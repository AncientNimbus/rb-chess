# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The EndgameLogic module defines the various logics to determine whether the game is a draw or checkmates
    # @author Ancient Nimbus
    module EndgameLogic
      # == Rules for Draw ==

      # Game is a stalemate
      # @param player_side [Symbol] :black or :white
      # @param usable_pieces [Hash<Array<String>>]
      # @param threats_map [Hash<Set<Integer>>]
      # @return [Boolean] the game is a draw when true
      def stalemate?(player_side, usable_pieces, threats_map)
        usable_pieces[player_side].empty? && threats_map[player_side].empty?
      end

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

        b1_ord, b2_ord = bishops.map { |bishop| bishop.info(:file).ord + bishop.info(:rank).to_i }
        b1_ord == b2_ord
      end

      # Game is a draw due to Fifty-move rule
      # @param half_move_count [Integer] half-move clock count
      # @return [Boolean] the game is a draw when true
      def half_move_overflow?(half_move_count)
        half_move_count >= 100
      end

      # Game is a draw due to Threefold Repetition
      # @param fen_records [Array<String>] expects :fens from a single session
      # @return [Boolean] the game is a draw when true
      def threefold_repetition?(fen_records)
        # fen_records = session[:fens]
        return false unless fen_records.size > 10

        sectioned_fen_records = fen_records.last(100).map { |fen| fen.split(" ")[0...-2].join(" ") }
        sectioned_fen_records.count(sectioned_fen_records.last) >= 3
      end
    end
  end
end
