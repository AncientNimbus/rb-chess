# frozen_string_literal: true

require_relative "logic"
require_relative "display"

module ConsoleGame
  module Chess
    # Chess Piece is a parent class for the game Chess in Console Game
    # @author Ancient Nimbus
    class ChessPiece
      include Logic
      include Display

      # Points system for chess pieces
      PTS_VALUES = { k: 100, q: 9, r: 5, b: 5, n: 3, p: 1 }.freeze

      attr_accessor :at_start, :curr_pos, :targets
      attr_reader :notation, :name, :icon, :pts, :movements, :start_pos, :side, :color, :possible_moves

      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      # @param notation [Symbol] expects a chess notation of a specific piece, e.g., Knight = :n
      def initialize(alg_pos = :e1, side = :white, notation = :k, movements: DIRECTIONS.keys, range: 1)
        @side = side
        @color = THEME[:classic][side]
        @notation = PIECES[notation][:notation]
        @name = PIECES[notation][:name]
        @icon = PIECES[notation][:style1]
        @pts = PTS_VALUES[notation]
        @start_pos = alg_pos.is_a?(Symbol) ? alg_map[alg_pos] : alg_pos
        @curr_pos = start_pos
        @at_start = true
        @movements = movement_range(movements, range: range)
        @targets = movement_range(movements, range: nil)
      end

      # Move the chess piece to a new valid location
      # @param level [Chess::Level] active chess level
      # @param new_alg_pos [Symbol] expects board position in Algebraic notation, e.g., :e3
      def move(level, new_alg_pos)
        query_moves(level)
        old_pos = curr_pos
        new_pos = alg_map[new_alg_pos]
        return "This is not a valid move" unless possible_moves.include?(new_pos)

        self.at_start = false
        self.curr_pos = new_pos
        # print user message
        p "Moving to #{new_alg_pos}"
        # refresh turn_data
        level.turn_data[old_pos] = ""
        level.turn_data[new_pos] = self
      end

      # Query and update possible_moves
      # @param level [Chess::Level] active chess level
      def query_moves(level)
        validate_moves(level.turn_data, curr_pos)
      end

      private

      # Calculate valid sequence based on positional value
      # @param pos [Integer] positional value within a matrix
      # @return [Hash<Array<Integer>>] an array of valid directional path within given bound
      def all_paths(pos = curr_pos)
        paths = Hash.new { |h, k| h[k] = nil }
        movements.each do |path, range|
          next if range.nil?

          sequence = path(pos, path, range: range)
          paths[path] = sequence unless sequence.empty?
        end
        paths
      end

      # Path via Pathfinder
      # @param pos [Integer] board positional value
      # @param path [Symbol] compass direction
      # @param range [Symbol, Integer] movement range of the given piece or :max for furthest possible range
      # @return [Array<Integer>]
      def path(pos = 0, path = :e, range: 1)
        seq_length = range.is_a?(Integer) ? range + 1 : range
        path = pathfinder(pos, path, length: seq_length)
        path.size > 1 ? path : []
      end

      # Valid movement
      # @param pos1 [Integer] original board positional value
      # @param pos2 [Integer] new board positional value
      # @return [Boolean]
      def valid_moves?(pos1, pos2); end

      # Store all valid placement
      # @param pos [Integer] positional value within a matrix
      def validate_moves(turn_data, pos = curr_pos)
        targets.default
        possible_moves = all_paths(pos)
        possible_moves.each do |path, positions|
          # remove blocked spot and onwards
          possible_moves[path] = detect_occupied_tiles(path, turn_data, positions)
        end
        @possible_moves = possible_moves.values.flatten
      end

      # Detect blocked tile based on the given positions
      # @param path [Symbol]
      # @param turn_data [Array] board data array
      # @param positions [Array] rank array
      # @return [Array]
      def detect_occupied_tiles(path, turn_data, positions)
        new_positions = positions[1..]
        positions.each_with_index do |pos, idx|
          tile = turn_data[pos]
          next unless tile != self && tile.is_a?(ChessPiece)

          targets[path] = pos if tile.side != side
          new_positions = positions[1..idx]
          break
        end
        new_positions
      end

      # Possible movement direction for the given piece
      # @param directions [Array<Symbol>] possible paths
      # @param range [Symbol, Integer] movement range of the given piece or :max for furthest possible range
      def movement_range(directions = [], range: 1)
        movements = Hash.new { |h, k| h[k] = nil }
        DIRECTIONS.each_key { |k| movements[k] }
        directions.each { |dir| movements[dir] = range }
        movements
      end
    end
  end
end
