# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The EndGameLogic module defines the various logics to determine whether the game is a draw or checkmates
    # @author Ancient Nimbus
    module EndGameLogic
      # == Rules for Draw ==

      # Game is a stalemate
      # @param player_side [Symbol] :black or :white
      # @param usable_pieces [Hash<Array<String>>]
      # @param threats_map [Hash<Array<Integer>>]
      # @return [Boolean] the game is a draw when true
      def stalemate?(player_side, usable_pieces:, threats_map:)
        usable_pieces[player_side].empty? && threats_map[player_side].empty?
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
