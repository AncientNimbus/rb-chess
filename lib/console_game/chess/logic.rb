# frozen_string_literal: true

module ConsoleGame
  module Chess
    # Logic module for the game Chess in Console Game
    module Logic
      # Default values
      PRESET = {
        length: 4,
        bound: [8, 8]
      }.freeze

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

      # Recursively find the next position depending on direction
      # @param pos [Integer] start position
      # @param path [Symbol] see DIRECTIONS for available options. E.g., :e for count from left to right
      # @param combination [Array<Integer>] default value is an empty array
      # @param length [Symbol, Integer] :nax for maximum range within bound or custom length of the sequence
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

        pathfinder(pos, path, combination, length: length, bound: bound)
      end

      # Calculate valid sequence based on positional value
      # @param value [Integer] positional value within a matrix
      # @return [Array<Array<Integer>>] an array of valid directional path within given bound
      def valid_moves(value = 0, rules = 1)
        arr = []
        DIRECTIONS.each_key do |path|
          # range = rules.is_a?(Integer) ? rules : rules[path]
          # next if range.nil? || range.zero?

          sequence = pathfinder(value, path, length: rules)
          arr << sequence unless sequence.empty?
        end
        arr
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
      def to_coord(pos = 0, bound: PRESET[:bound])
        raise ArgumentError, "#{pos} is out of bound!" unless pos.between?(0, bound.reduce(:*) - 1)

        grid_width, _grid_height = bound
        pos.divmod(grid_width)
      end

      private

      # Helper method to check for out of bound cases for top and bottom borders
      # @param value [Integer]
      # @param bound [Array<Integer>] grid size `[row, col]`
      # @return [Boolean]
      def out_of_bound?(value, bound)
        value.negative? || value > bound.reduce(:*) - 1
      end

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
    end
  end
end
