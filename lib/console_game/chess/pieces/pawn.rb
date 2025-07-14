# frozen_string_literal: true

require_relative "chess_piece"

module ConsoleGame
  module Chess
    # Pawn is a sub-class of ChessPiece for the game Chess in Console Game
    # @author Ancient Nimbus
    class Pawn < ChessPiece
      attr_reader :at_end

      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param level [Chess::Level] chess level object
      # @param side [Symbol] specify unit side :black or :white
      def initialize(alg_pos = :a2, side = :white, level: nil)
        movements = side == :white ? %i[n ne nw] : %i[s se sw]
        super(alg_pos, side, :p, movements: movements, range: 1, level: level)
        self.at_start = at_rank?(%i[a2 h2], %i[a7 h7])
        at_end?
      end

      # Override move
      # Move the chess piece to a new valid location
      # @param new_alg_pos [Symbol] expects board position in Algebraic notation, e.g., :e3
      # @param notation [String]
      def move(new_alg_pos, notation = nil)
        old_pos = curr_pos
        super(new_alg_pos)

        en_passant_reg if (old_pos - curr_pos).abs == 16
        en_passant_capture unless level.en_passant.nil?

        return unless at_end?

        notation = notation.nil? ? level.promote_opts : notation
        promote_to(notation.to_sym)
      end

      private

      # Handle En Passant detection event
      def en_passant_reg
        tiles_to_query = fetch_adjacent_tiles

        ghost_pos = side == :white ? curr_pos - 8 : curr_pos + 8
        level.en_passant = [self, ghost_pos] unless tiles_to_query.empty?
      end

      # Handle En Passant capture event
      def en_passant_capture
        captured_pawn, ghost_pos = level.en_passant
        return unless curr_pos == ghost_pos

        level.turn_data[captured_pawn.curr_pos] = ""
        level.en_passant = nil
      end

      # Helper: Return valid adjacent tiles
      def fetch_adjacent_tiles
        tiles_to_query = [curr_pos - 1, curr_pos + 1].map { |pos| level.turn_data.fetch(pos) }
        tiles_to_query.select { |tile| tile.is_a?(Pawn) && tile.info(:rank) == info(:rank) && tile.side != side }
      end

      # Perform pawn promotion
      # @param notation [Symbol]
      def promote_to(notation = :q)
        return puts "Invalid option for promotion!" unless %i[q r b n].include?(notation)

        class_name = FEN[notation][:class]
        new_unit = Chess.const_get(class_name).new(curr_pos, side, level: level)
        level.turn_data[curr_pos] = new_unit
        puts "Promoting Pawn to #{new_unit.name}." # @todo Proper feedback
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
        if %i[n s].include?(path)
          new_positions = [] if tile_data.is_a?(ChessPiece)
          targets[path] = nil
        elsif tile_data.is_a?(String)
          sights.push(*new_positions)
          new_positions = []
        end
        new_positions.push(en_passant_add)
      end

      # Helper: add en passant capture position to possible moves
      def en_passant_add
        level.en_passant[1] unless level.en_passant.nil?
      end

      # Override path
      # Path via Pathfinder
      # @param pos [Integer] board positional value
      # @param path [Symbol] compass direction
      # @param range [Symbol, Integer] movement range of the given piece or :max for furthest possible range
      # @return [Array<Integer>]
      def path(pos = 0, path = :e, range: 1)
        range = 2 if at_start && %i[n s].include?(path)
        super(pos, path, range: range)
      end
    end
  end
end
