# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Pawn is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Pawn < ChessPiece
      attr_reader :at_end

      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :a2, side = :white, level: nil)
        @at_end = false
        super(alg_pos, side, :p, movements: %i[n ne nw], range: 1, level: level)
        self.at_start = at_rank?(%i[a2 h2], %i[a7 h7])
        at_end?
      end

      # Move the chess piece to a new valid location
      # @param new_alg_pos [Symbol] expects board position in Algebraic notation, e.g., :e3
      def move(new_alg_pos)
        super(new_alg_pos)
        promote_to if at_end?
      end

      private

      # Perform pawn promotion
      # @param notation [Symbol]
      def promote_to(notation = :q)
        return puts "Invalid option for promotion!" unless %i[q r b n].include?(notation)

        class_name = PRESET[notation][:class]
        new_unit = Chess.const_get(class_name).new(curr_pos, side, level: level)
        level.turn_data[curr_pos] = new_unit
      end

      # Check if the pawn is at the other end of the board
      def at_end?
        @at_end = at_rank?(%i[a8 h8], %i[a1 h1])
      end

      # Parallel query to check if pawn is at a certain rank
      # @param white_range [Array<Symbol>] `[:a2, :h2]`
      # @param black_range [Array<Symbol>] `[:a7, :h7]`
      # @return [Boolean]
      def at_rank?(white_range = %i[a2 h2], black_range = %i[a7 h7])
        w_min, w_max, b_min, b_max = [white_range, black_range].flatten.map { |alg| alg_map[alg] }
        case side
        when :white then return true if [*w_min..w_max].any?(curr_pos)
        when :black then return true if [*b_min..b_max].any?(curr_pos)
        end
        false
      end

      # Override detect_occupied_tiles
      # Detect blocked tile based on the given positions
      # @param path [Symbol]
      # @param turn_data [Array] board data array
      # @param positions [Array] rank array
      # @return [Array]
      def detect_occupied_tiles(path, turn_data, positions)
        new_positions = super(path, turn_data, positions)
        tile_data = new_positions.empty? ? nil : turn_data[new_positions.first]
        if path == :n
          new_positions = [] if tile_data.is_a?(ChessPiece)
          targets[path] = nil
        elsif tile_data.is_a?(String)
          new_positions = []
        end
        new_positions
      end

      # Override path
      # Path via Pathfinder
      # @param pos [Integer] board positional value
      # @param path [Symbol] compass direction
      # @param range [Symbol, Integer] movement range of the given piece or :max for furthest possible range
      # @return [Array<Integer>]
      def path(pos = 0, path = :e, range: 1)
        range = 2 if at_start && path == :n
        super(pos, path, range: range)
      end
    end
  end
end
