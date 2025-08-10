# frozen_string_literal: true

module ConsoleGame
  module Chess
    # The Moves Simulation class helps simulate the next possible moves of a chess piece
    # @author Ancient Nimbus
    class MovesSimulation
      # Simulates the next possible moves for a given chess position.
      # @return [Array<Integer>] good moves
      def self.simulate_next_moves(...) = new(...).simulate_next_moves

      # @!attribute [r] turn_data
      #   @return [Array<ChessPiece, String>] complete state of the current turn
      attr_reader :level, :piece, :turn_data, :i_am_the_king, :king, :smart_moves
      attr_accessor :good_pos

      # @param level [Level] expects a Chess::Level class object
      # @param piece [ChessPiece] expects a ChessPiece class objet
      # @param smart [Boolean] when true, it returns moves that is safe for itself too
      def initialize(level, piece, smart: false)
        @level = level
        @piece = piece
        @turn_data = level.turn_data
        @good_pos = []
        is_king = piece.is_a?(King)
        @king = is_king ? piece : level.kings[piece.side]
        @i_am_the_king = is_king
        @smart_moves = smart
      end

      # Simulate next move - Find good moves
      # @return [Set<Integer>] good moves
      def simulate_next_moves
        current_pos = piece.curr_pos
        turn_data[current_pos] = ""
        piece.possible_moves.each { |new_pos| simulate_move(new_pos) }
        restore_previous_state(current_pos)
        good_pos.compact.to_set
      end

      private

      # Simulation helper: find a good move
      # @param new_pos [Integer]
      def simulate_move(new_pos)
        tile = turn_data[new_pos]
        turn_data[new_pos] = piece
        piece.curr_pos = new_pos
        level.update_board_state
        good_pos.push(new_pos) if good_move?
        turn_data[new_pos] = tile
      end

      # Helper to determine good move
      def good_move? = !(i_am_the_king ? am_i_in_danger? : hows_the_king?)

      # Determine check conditions based on smart_moves
      def hows_the_king? = smart_moves ? (am_i_in_danger? && king_in_danger?) : king_in_danger?

      # Check yourself
      def am_i_in_danger? = piece.under_threat?

      # Check the king
      def king_in_danger? = king.under_threat?

      # Simulation helper: restore pre simulation state
      # @param current_pos [Integer]
      def restore_previous_state(current_pos)
        piece.curr_pos = current_pos
        turn_data[current_pos] = piece
        level.update_board_state
      end
    end
  end
end
