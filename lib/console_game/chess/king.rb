# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # King is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class King < ChessPiece
      attr_accessor :checked
      attr_reader :checked_status

      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :e1, side = :white, level: nil)
        super(alg_pos, side, :k, level: level)
        @checked = false
        @checked_status = { checked: checked, attackers: [] }
      end

      # Determine if the King is in a checkmate position
      # @return [Boolean] true if it is a checkmate
      def checkmate?
        return false unless in_check?

        allies = level.fetch_all(side).select { |ally| ally unless ally.is_a?(King) }
        checked_status[:attackers].each do |attacker|
          return false if under_threat_by?(allies, attacker)
          return false if any_saviours?(allies, attacker)
        end
        god_save_the_king?
      end

      private

      # Determine if there are any saviour
      # @param king_allies [Array<ChessPiece>] expects an array of King's army
      # @param attacker [ChessPiece]
      # @param king [King]
      # @return [Boolean] true if someone can come save the King
      def any_saviours?(king_allies, attacker)
        attacker_dir = attacker.targets.key(curr_pos)
        attack_path = pathfinder(attacker.curr_pos, attacker_dir, length: attacker.movements[attacker_dir])

        saviours = level.usable_pieces[side] = king_allies.map do |ally|
          ally.info unless (ally.possible_moves & attack_path).empty?
        end.compact
        !saviours.empty?
      end

      # Determine if there are no escape route for the King
      # @return [Boolean] true if King cannot escape
      def god_save_the_king?
        (possible_moves - level.threats_map[opposite_of(side)]).empty?
      end

      # Determine if the King is checked
      # @return [Boolean] true if the king is checked
      def in_check?
        checked_status.transform_values! { |_| [] }
        self.checked = under_threat?
        checked_event if checked
        checked
      end

      # Override validate_moves
      # Store all valid placement
      # @param pos [Integer] positional value within a matrix
      def validate_moves(turn_data, pos = curr_pos)
        super(turn_data, pos)
        @possible_moves = possible_moves - level.threats_map[opposite_of(side)]
      end

      # Find the pieces that is checking the King
      # @param king_in_distress [King] expects a King object
      # @return [nil, ChessPiece, Array<ChessPiece>]
      def find_checking_pieces
        level.fetch_all(opposite_of(side)).select do |piece|
          checked_status[:attackers] << piece if piece.targets.value?(curr_pos)
        end
      end

      # Process the checked event
      def checked_event
        find_checking_pieces
        puts "#{side} #{name} is checked by #{checked_status[:attackers].map(&:info).join(', ')}."
      end
    end
  end
end
