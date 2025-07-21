# frozen_string_literal: true

require_relative "../logics/logic"
require_relative "../logics/display"
require_relative "../utilities/fen_import"

module ConsoleGame
  module Chess
    # Chess Piece is a parent class for the game Chess in Console Game
    # @author Ancient Nimbus
    class ChessPiece
      include Logic
      include Display
      include FenImport

      # Points system for chess pieces
      PTS_VALUES = { k: 100, q: 9, r: 5, b: 5, n: 3, p: 1 }.freeze

      attr_accessor :at_start, :curr_pos, :targets, :sights, :color, :moved
      attr_reader :level, :notation, :name, :icon, :pts, :movements, :start_pos, :side, :captured, :possible_moves,
                  :std_color, :highlight, :last_move

      # @param alg_pos [Symbol] expects board position in Algebraic notation
      # @param side [Symbol] specify unit side :black or :white
      # @param notation [Symbol] expects a chess notation of a specific piece, e.g., Knight = :n
      # @param movements [Hash] expects compass direction
      # @param range [Integer, Symbol] unit movement range
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
        # p "Moving to #{new_alg_pos}" # @todo: better feedback

        process_movement(level.turn_data, old_pos, new_pos)
        self.moved = true
      end

      # Query and update possible_moves
      # @param limiter [Array] limit piece movement when player is checked
      def query_moves(limiter = [])
        validate_moves(level.turn_data, curr_pos).map { |pos| alg_map.key(pos) }
        threat_response
        @possible_moves = possible_moves & limiter unless limiter.empty?
      end

      # Returns the algebraic notation of current position
      # @return [String] full algebraic position
      def info = to_alg_pos(curr_pos)

      # Returns the file of current position
      # @return [String] file of the piece
      def file = info[0]

      # Returns the rank of current position
      # @return [String] file of the piece
      def rank = info[1]

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
        @last_move = store_last_move(:move, old_pos)
        return curr_pos if new_tile.is_a?(String)

        captured << new_tile
        @last_move = store_last_move(:capture, old_pos)
        curr_pos
      end

      # Last move formatted as algebraic notation
      # @return [String]
      def store_last_move(move_type = :move, file = nil)
        alg_notation = notation.to_s.upcase
        move = "#{alg_notation}#{info}"
        if move_type == :capture
          move.insert(1, "x")
          move.insert(1, alg_map.key(file)[0])
        end
        # move.insert(-1, "+") if possible_moves.include?(level.kings[opposite_of(side)].curr_pos)
        move
      end

      # Valid movement
      # @param pos1 [Integer] original board positional value
      # @param pos2 [Integer] new board positional value
      # @return [Boolean]
      # def valid_moves?(pos1, pos2); end

      # == Threat Query ==

      # Handle events when the opposite active piece can capture self in the upcoming turn
      # Switch color when under threat
      def threat_response = self.color = under_threat_by?([level.active_piece], self) ? highlight : std_color

      # Determine if a piece is currently under threats
      # @param piece [ChessPiece]
      # @return [Boolean]
      def under_threat? = level.threats_map[opposite_of(side)].include?(curr_pos)

      # Determine if a piece might get attacked by multiple pieces, similar to #under_threat? but more specific
      # @param threat_side [Array<ChessPiece>]
      # @param target [ChessPiece]
      # @return [Boolean]
      def under_threat_by?(threat_side, target)
        return false unless target.is_a?(ChessPiece) && !threat_side.compact.empty?

        threat_side.any? { |piece| piece.targets.value?(target.curr_pos) && piece.possible_moves.include?(curr_pos) }
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
        possible_moves = all_paths(movements, pos)
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
    end
  end
end
