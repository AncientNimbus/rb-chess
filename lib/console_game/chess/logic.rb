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

      # Recursively find the next value depending on direction
      # @param value [Integer] start value
      # @param path [Symbol] see DIRECTIONS for available options. E.g., :e for count from left to right
      # @param combination [Array<Integer>] default value is an empty array
      # @param length [Integer] expected array length
      # @param bound [Array<Integer>] grid size `[row, col]`
      # @return [Array<Integer>] array of numbers
      def direction(value = 0, path = :e, combination = nil, length: PRESET[:length], bound: PRESET[:bound])
        combination ||= [value]
        arr_size = combination.size
        return combination if arr_size == length

        next_value = DIRECTIONS.fetch(path) do |key|
          raise ArgumentError, "Invalid path: #{key}"
        end.call(value, arr_size, bound[0])

        combination << next_value

        if arr_size >= 1
          return [] if out_of_bound?(next_value, bound)
          return [] if not_one_unit_apart?(path, combination, bound[1])
        end

        direction(value, path, combination, length: length, bound: bound)
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

      # Helper method to check for out of bound cases for left and right borders
      # @param path [Symbol] see DIRECTIONS for available options. E.g., :e for count from left to right
      # @param values_arr [Array<Integer>]
      # @param col [Integer] column
      # @return [Boolean]
      def not_one_unit_apart?(path, values_arr, col)
        return false unless %i[e w ne nw se sw].include?(path)

        ((values_arr.first % col - values_arr.last % col).abs - (values_arr.size - 1)).abs != 0
      end
    end
  end
end
