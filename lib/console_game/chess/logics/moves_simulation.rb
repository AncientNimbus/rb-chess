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
      # @!attribute [r] update_state
      #   @return [Method] refresh level state
      attr_reader :level, :piece, :turn_data, :update_state

      # @param level [Level] expects a Chess::Level class object
      # @param piece [ChessPiece] expects a ChessPiece class objet
      def initialize(level, piece)
        @level = level
        @piece = piece
        @turn_data = level.turn_data
        @update_state = level.update_board_state
      end

      # Simulate next move - Find good moves
      # @return [Array<Integer>] good moves
      def simulate_next_moves
        good_pos = []
        current_pos = piece.curr_pos
        turn_data[current_pos] = ""
        piece.possible_moves.each { |new_pos| good_pos << simulate_move(new_pos) }
        restore_previous_state(current_pos)
        good_pos
      end

      private

      # Simulation helper: find a good move
      # @param new_pos [Integer]
      # @return [Integer]
      def simulate_move(new_pos)
        tile = turn_data[new_pos]
        piece.curr_pos = new_pos
        update_state
        turn_data[new_pos] = tile
        new_pos unless piece.under_threat?
      end

      # Simulation helper: restore pre simulation state
      # @param current_pos [Integer]
      def restore_previous_state(current_pos)
        piece.curr_pos = current_pos
        turn_data[current_pos] = piece
        update_state
      end
    end
  end
end
