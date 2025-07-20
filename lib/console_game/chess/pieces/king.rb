# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # King is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class King < ChessPiece
      attr_accessor :checked
      attr_reader :checked_status, :castle_dirs, :castle_config, :castle_key

      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      # @param level [Level] Chess::Level object
      def initialize(alg_pos = :e1, side = :white, level: nil)
        super(alg_pos, side, :k, level: level)
        @castle_dirs = %i[e w]
        @checked = false
        @checked_status = { checked: checked, attackers: [] }
      end

      # Override move
      # Move the chess piece to a new valid location
      # @param new_alg_pos [Symbol] expects board position in Algebraic notation, e.g., :e3
      def move(new_alg_pos)
        old_pos = curr_pos
        disable_castling
        super(new_alg_pos)

        castling_event(old_pos)
      end

      # Override query_moves
      # Query and update possible_moves
      def query_moves
        king_to_the_table
        can_castle?
        super
      end

      # == King specific logics ==

      # Determine if the King is in a checkmate position
      # @return [Boolean] true if it is a checkmate
      def checkmate?
        return false unless in_check?

        allies = level.fetch_all(side).select { |ally| ally unless ally.is_a?(King) }
        checked_status[:attackers].each do |attacker|
          return false if under_threat_by?(allies, attacker)
          return false if any_saviours?(allies, attacker)
        end
        crown_has_fallen?
      end

      private

      # Add king reference to level
      def king_to_the_table
        return unless level.kings[side].nil?

        level.kings[side] = self
      end

      # Determine if the King can perform castling
      def can_castle?
        return false unless at_start

        @castle_key ||= side == :white ? %i[K Q] : %i[k q]
        @castle_config ||= castle_key.zip(castle_dirs)
        castle_config.each do |set|
          key, dir = set
          castle_dirs.delete(dir) if level.castling_states[key] == false
        end
        # p castle_dirs
        true
      end

      # Process castling event
      # @param old_pos [Integer] previous position
      def castling_event(old_pos)
        distance = curr_pos - old_pos
        return unless distance.abs == 2

        alg_pos = distance.positive? ? "h#{rank}" : "a#{rank}"

        rook_query, rook_pos = file == "g" ? [alg_pos, curr_pos - 1] : [alg_pos, curr_pos + 1]
        rook = level.fetch_piece(rook_query)
        rook.move(rook_pos)

        p "King is castling"
      end

      # disable castling
      def disable_castling
        return unless at_start

        castle_key.each { |key| level.castling_states[key] = false }
      end

      # Override validate_moves
      # Store all valid placement
      # @param turn_data [Array] turn data from level object
      # @param pos [Integer] positional value within a matrix
      def validate_moves(turn_data, pos = curr_pos)
        super(turn_data, pos)
        @possible_moves = possible_moves - level.threats_map[opposite_of(side)]
      end

      # Override path
      # Path via Pathfinder
      # @param pos [Integer] board positional value
      # @param path [Symbol] compass direction
      # @param range [Symbol, Integer] movement range of the given piece or :max for furthest possible range
      # @return [Array<Integer>]
      def path(pos = 0, path = :e, range: 1)
        range = 2 if at_start && castle_dirs.include?(path)
        super(pos, path, range: range)
      end

      # == Checkmate event flow ==

      # Determine if there are any saviour
      # @param king_allies [Array<ChessPiece>] expects an array of King's army
      # @param attacker [ChessPiece]
      # @return [Boolean] true if someone can come save the King
      def any_saviours?(king_allies, attacker)
        attack_path = find_attacker_path(attacker)
        saviours = find_saviours(king_allies, attack_path)
        limit_saviours_movements(saviours, attack_path)
        add_saviours(saviours)
        !saviours.empty?
      end

      # Helper for any_saviours?, find all saviours
      # @param king_allies [Array<ChessPiece>] expects an array of King's army
      # @param attack_path [Array<Integer>]
      # @return [Array<ChessPiece>]
      def find_saviours(king_allies, attack_path)
        king_allies.map { |ally| ally unless (ally.possible_moves & attack_path).empty? }.compact
      end

      # Helper for any_saviours?, Update and limits saviours path to attacker's path
      # @param saviours [Array<ChessPiece>] expects an array of King's saviours
      # @param attack_path [Array<Integer>]
      def limit_saviours_movements(saviours, attack_path) = saviours.each { |ally| ally.query_moves(attack_path) }

      # Helper for any_saviours?, add saviours and King to the usable pieces if King still move
      # @param saviours [Array<ChessPiece>] expects an array of King's saviours
      def add_saviours(saviours)
        saviours.push(self) unless possible_moves.empty?
        level.usable_pieces[side] = saviours.map(&:info)
      end

      # Determine if there are no escape route for the King
      # @return [Boolean] true if King cannot escape
      def crown_has_fallen? = (possible_moves - level.threats_map[opposite_of(side)]).empty?

      # == Check event flow ==

      # Determine if the King is checked
      # @return [Boolean] true if the king is checked
      def in_check?
        checked_status.transform_values! { |_| [] }
        self.checked = under_threat?
        checked_event if checked
        checked
      end

      # Process the checked event
      def checked_event
        find_checking_pieces
        puts "#{side} #{name} is checked by #{checked_status[:attackers].map(&:info).join(', ')}."
      end

      # Find the pieces that is checking the King
      # @return [nil, ChessPiece, Array<ChessPiece>]
      def find_checking_pieces
        level.fetch_all(opposite_of(side)).select do |piece|
          checked_status[:attackers] << piece if piece.targets.value?(curr_pos)
        end
      end
    end
  end
end
