# frozen_string_literal: true

module ConsoleGame
  module Chess
    # Logic module for the game Chess in Console Game
    # @author Ancient Nimbus
    # @version 1.3.2
    module Logic
      # Default values
      PRESET = { bound: [8, 8], nil_hash: -> { Hash.new { |h, k| h[k] = nil } } }.freeze

      # A hash of lambda functions for calculating movement in 8 directions on a grid
      DIRECTIONS = {
        n: ->(value, step, row) { value + row * step },
        ne: ->(value, step, row) { value + row * step + step },
        e: ->(value, step, _row) { value + step },
        se: ->(value, step, row) { value - row * step + step },
        s: ->(value, step, row) { value - row * step },
        sw: ->(value, step, row) { value - row * step - step },
        w: ->(value, step, _row) { value - step },
        nw: ->(value, step, row) { value + row * step - step }
      }.freeze

      # Algebraic chess notation to positional value hash
      ALG_MAP = [*"a".."h"].each_with_index.flat_map do |file, col|
        [*"#{file}1".."#{file}8"].map.with_index { |alg, row| [alg.to_sym, row * 8 + col] }
      end.to_h.freeze

      private

      # Recursively find the next position depending on direction
      # @param pos [Integer] start position
      # @param path [Symbol] see DIRECTIONS for available options. E.g., :e for count from left to right
      # @param combination [Array<Integer>] default value is an empty array
      # @param length [Symbol, Integer] :max for maximum range within bound or custom length of the sequence
      # @param bound [Array<Integer>] grid size `[row, col]`
      # @return [Array<Integer>] array of numbers
      def pathfinder(pos = 0, path = :e, combination = nil, length: :max, bound: PRESET[:bound])
        combination ||= [pos]
        arr_size = combination.size
        return combination if arr_size == length

        next_value = DIRECTIONS.fetch(path) do |key|
          raise ArgumentError, "Invalid path: #{key}"
        end.call(pos, arr_size, bound[0])

        combination << next_value

        if out_of_bound?(next_value, bound) || not_adjacent?(path, combination)
          return length == :max ? combination[0..-2] : []
        end

        pathfinder(pos, path, combination, length:, bound:)
      end

      # Calculate valid sequence based on positional value
      # @param movements [Hash] expects a hash with DIRECTION as keys
      # @param pos [Integer] positional value within a matrix
      # @param paths [Hash] a hash with `nil` set as default value
      # @return [Hash<Array<Integer>>] an array of valid directional path within given bound
      def all_paths(movements, pos, paths: PRESET[:nil_hash].call)
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
      # @param movements [Hash] a hash with `nil` set as default value
      # @return [Hash]
      def movement_range(directions = [], range: 1, movements: PRESET[:nil_hash].call)
        DIRECTIONS.each_key { |k| movements[k] }
        directions.each { |dir| movements[dir] = range }
        movements
      end

      # Convert coordinate array to cell position
      # @param coord [Array<Integer>] `[row, col]`
      # @param bound [Array<Integer>] `[row, col]`
      # @return [Integer]
      def to_pos(coord = [0, 0], bound: PRESET[:bound])
        row, col = coord
        grid_width, _grid_height = bound
        pos_value = (row * grid_width) + col

        raise ArgumentError, "#{coord} is out of bound!" unless pos_value.between?(0, bound.reduce(:*) - 1)

        pos_value
      end

      # Convert cell position to coordinate array
      # @param pos [Integer] positional value
      # @param bound [Array<Integer>] `[row, col]`
      # @return [Array<Integer>]
      def to_coord(pos = 0, bound: PRESET[:bound])
        raise ArgumentError, "#{pos} is out of bound!" unless pos.between?(0, bound.reduce(:*) - 1)

        grid_width, _grid_height = bound
        pos.divmod(grid_width)
      end

      # Flip-flop, return :black if it is :white
      # @param side [Symbol] expects argument to be :black or :white
      # @return [Symbol] :black or :white
      def opposite_of(side = :white)
        return nil unless %i[black white].include?(side)

        side == :white ? :black : :white
      end

      # == Pathfinder ==

      # Helper method to check for out of bound cases for top and bottom borders
      # @param value [Integer]
      # @param bound [Array<Integer>] grid size `[row, col]`
      # @return [Boolean]
      def out_of_bound?(value, bound) = value.negative? || value > bound.reduce(:*) - 1

      # Helper method to check for out of bound cases for left and right borders (Previously: not_one_unit_apart?)
      # @param path [Symbol] see DIRECTIONS for available options. E.g., :e for count from left to right
      # @param values_arr [Array<Integer>]
      # @return [Boolean]
      def not_adjacent?(path, values_arr)
        return false unless %i[e w ne nw se sw].include?(path)

        first_col, prev_col, curr_col = [values_arr.first, *values_arr.last(2)].map { |pos| to_coord(pos)[1] }

        wraps_around_edge = ((first_col - curr_col).abs - (values_arr.size - 1)).abs != 0
        not_adjacent = (prev_col - curr_col).abs != 1

        wraps_around_edge || not_adjacent
      end

      # == Algebraic natation ==

      # Call the algebraic chess notation to positional value reference hash
      # @return [Hash<Integer>]
      def alg_map = ALG_MAP

      # Convert positional value to Algebraic notation string
      # @param pos [Integer]
      # @return [String]
      def to_alg_pos(pos) = alg_map.key(pos).to_s

      # Fetch positional value from Algebraic notation string or symbol
      # @param alg_pos [String, Symbol] expects notation e.g., `"e4"` or `:e4`
      # @return [Integer] 1D board positional value
      def to_1d_pos(alg_pos) = alg_map.fetch((alg_pos.is_a?(Symbol) ? alg_pos : alg_pos.to_sym))
    end
  end
end
