# frozen_string_literal: true

require_relative "../logic"
require_relative "../display"

module ConsoleGame
  module Chess
    # Chess Piece is a parent class for the game Chess in Console Game
    # @author Ancient Nimbus
    class ChessPiece
      include Logic
      include Display

      # Points system for chess pieces
      PTS_VALUES = { k: 100, q: 9, r: 5, b: 5, n: 3, p: 1 }.freeze

      attr_accessor :at_start, :curr_pos, :targets, :sights, :color, :moved
      attr_reader :level, :notation, :name, :icon, :pts, :movements, :start_pos, :side, :captured, :possible_moves,
                  :std_color, :highlight

      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      # @param notation [Symbol] expects a chess notation of a specific piece, e.g., Knight = :n
      # @param level [Chess::Level] chess level object
      # @param at_start [Boolean] determine if the piece is at its start location
      def initialize(alg_pos = :e1, side = :white, notation = :k, movements: DIRECTIONS.keys, range: 1, level: nil,
                     at_start: true)
        @level = level
        @side = side
        @pts = PTS_VALUES[notation]
        piece_styling(notation)
        @start_pos = alg_pos.is_a?(Symbol) ? alg_map[alg_pos] : alg_pos
        @curr_pos = start_pos
        @at_start = at_start.nil? ? false : at_start # @todo Better logic??
        movements_trackers(movements, range)
      end

      # == Public methods ==

      # Move the chess piece to a new valid location
      # @param new_alg_pos [Symbol, Integer] expects board position in Algebraic notation, e.g., :e3
      def move(new_alg_pos)
        old_pos = curr_pos
        new_pos = new_alg_pos.is_a?(Integer) ? new_alg_pos : alg_map[new_alg_pos.to_sym]
        # return puts "This is not a valid move!" unless possible_moves.include?(new_pos)
        unless possible_moves.include?(new_pos)
          puts "This is not a valid move!"
          return self.moved = false
        end

        # print user message
        p "Moving to #{new_alg_pos}" # @todo: better feedback

        process_movement(level.turn_data, old_pos, new_pos)
        self.moved = true
      end

      # Query and update possible_moves
      def query_moves
        validate_moves(level.turn_data, curr_pos).map { |pos| alg_map.key(pos) }
        threat_response
      end

      # Return alg notation of current position
      # @param query [Symbol] expects `:file`, `:rank` or `:all`
      # @return [String] file, rank, or full algebraic position
      def info(query = :all)
        alg_pos = alg_map.key(curr_pos).to_s
        case query
        when :file then alg_pos[0]
        when :rank then alg_pos[1]
        else alg_pos
        end
      end

      private

      # == Setup ==

      # Initialize piece styling
      # @param notation [Symbol] expects a chess notation of a specific piece, e.g., Knight = :n
      def piece_styling(notation)
        @notation, @name, @icon = PIECES[notation].slice(:notation, :name, :style1).values
        @std_color, @highlight = THEME[:classic].slice(side, :highlight).values
        @color = std_color
      end

      # Initialize piece movements trackers
      # @param movements [Array]
      # @param range [Integer, Symbol]
      def movements_trackers(movements, range)
        @movements = movement_range(movements, range: range)
        @targets = movement_range(movements, range: nil)
        @sights = []
        @captured = []
        @moved = false
      end

      # == Move logic ==

      # Process movement
      # @param turn_data [Array<ChessPiece, String>]
      # @param old_pos [Integer]
      # @param new_pos [Integer]
      # @return [Integer] new location's positional value
      def process_movement(turn_data, old_pos, new_pos)
        self.at_start = false
        self.curr_pos = new_pos
        new_tile = turn_data[new_pos]

        turn_data[old_pos] = ""
        turn_data[new_pos] = self
        return curr_pos if new_tile.is_a?(String)

        captured << new_tile if new_tile.is_a?(ChessPiece)
        curr_pos
      end

      # Valid movement
      # @param pos1 [Integer] original board positional value
      # @param pos2 [Integer] new board positional value
      # @return [Boolean]
      def valid_moves?(pos1, pos2); end

      # == Threat Query ==

      # Handle events when the opposite active piece can capture self in the upcoming turn
      def threat_response
        # Switch color when under threat
        self.color = under_threat_by?([level.active_piece], self) ? highlight : std_color
      end

      # Determine if a piece is currently under threats
      # #param piece [ChessPiece]
      def under_threat?
        opposite_side = opposite_of(side)
        level.threats_map[opposite_side].include?(curr_pos)
      end

      # Determine if a piece might get attacked by multiple pieces, similar to #under_threat? but more specific
      # @param threat_side [Array<ChessPiece>]
      # @param target [ChessPiece]
      # @return [Boolean]
      def under_threat_by?(threat_side, target)
        return false unless target.is_a?(ChessPiece) && !threat_side.compact.empty?

        threat_side.any? { |piece| piece.targets.value?(target.curr_pos) }
      end

      # Returns the path of an attacking chess piece based on the current position of self
      # @param attacker [ChessPiece]
      # @return [Array<Integer>]
      def find_attacker_path(attacker)
        atk_direction = attacker.targets.key(curr_pos)
        pathfinder(attacker.curr_pos, atk_direction, length: attacker.movements[atk_direction])
      end

      # == Pathfinder related ==

      # Store all valid placement
      # @param pos [Integer] positional value within a matrix
      def validate_moves(turn_data, pos = curr_pos)
        self.sights = []
        targets.transform_values! { |_| nil }
        possible_moves = all_paths(pos)
        possible_moves.each do |path, positions|
          # remove blocked spot and onwards
          possible_moves[path] = detect_occupied_tiles(path, turn_data, positions)
        end
        @possible_moves = (possible_moves.values.flatten + targets.values).compact.to_set
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

          tile.side == side ? sights.push(pos) : targets[path] = pos
          # p "#{side} #{name} at #{alg_map.key(curr_pos)} is watching over #{sights}"
          new_positions = positions[1...idx]
          break
        end
        new_positions
      end

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
