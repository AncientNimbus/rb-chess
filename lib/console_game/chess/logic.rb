# frozen_string_literal: true

module ConsoleGame
  module Chess
    # Logic module for the game Chess in Console Game
    # @author Ancient Nimbus
    # @version 1.0.0
    module Logic
      # Default values
      PRESET = {
        length: 4,
        bound: [8, 8],
        fen_start: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
        k: { class: "King", notation: :k },
        q: { class: "Queen", notation: :q },
        r: { class: "Rook", notation: :r },
        b: { class: "Bishop", notation: :b },
        n: { class: "Knight", notation: :n },
        p: { class: "Pawn", notation: :p }
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

        pathfinder(pos, path, combination, length: length, bound: bound)
      end

      # Generate and memorize the algebraic chess notation to positional value reference hash
      def alg_map
        @alg_map ||= algebraic_notation_generator
      end

      # FEN Raw data parser
      # @fen_str [String] expects a string in FEN format
      def parse_fen(fen_str = PRESET[:fen_start])
        fen = fen_str.split
        return nil if fen.size != 6

        fen_board, turn, c_state, ep_state, halfmove, fullmove = fen
      end

      # Process FEN board data
      # @param fen_board [Array<String>] expects an Array with FEN positions data
      # @return [Array<Array<ChessPiece, String>>] chess position data starts from a1..h8
      def to_turn_data(fen_board)
        turn_data = Array.new { {} }
        pos_value = 0
        fen_board.split("/").reverse.each_with_index do |rank, row|
          turn_data[row] = []
          normalise_fen_rank(rank).each_with_index do |unit, col|
            turn_data[row][col] = /\A\d\z/.match?(unit) ? "" : piece_maker(pos_value, unit)
            pos_value += 1
          end
        end
        turn_data
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

      # == Pathfinder ==

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

      # == Algebraic natation ==

      # Algebraic chess notation to positional value generator
      # @return [Hash] Algebraic notation to positional values map
      def algebraic_notation_generator
        alg_map = {}
        [*"a".."h"].each_with_index do |file, idx|
          col = pathfinder(idx, :n, length: :max)
          [*"#{file}1".."#{file}8"].each_with_index { |alg, i| alg_map[alg.to_sym] = col[i] }
        end
        alg_map
      end

      # == FEN Parser ==

      # Initialize chess piece via string value
      # @param pos [Integer] positional value
      # @param notation [String] expects a single letter that follows the FEN standard
      # @return [Chess::King, Chess::Queen, Chess::Bishop, Chess::Rook, Chess::Knight, Chess::Pawn]
      def piece_maker(pos, notation)
        side = notation == notation.capitalize ? :white : :black
        class_name = PRESET[notation.downcase.to_sym][:class]
        Chess.const_get(class_name).new(pos, side)
      end

      # Helper method to uncompress FEN empty cell values so that all arrays share the same size
      # @param fen_rank_str [String]
      # @return [Array] processed rank data array
      def normalise_fen_rank(fen_rank_str)
        fen_rank_str.split("").map { |elem| elem.sub(/\A\d\z/, "0" * elem.to_i).split("") }.flatten
      end
    end
  end
end
