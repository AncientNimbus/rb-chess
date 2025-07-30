# frozen_string_literal: true

module ConsoleGame
  module Chess
    # ChessUtils is a module that provides shared logics that's used across multiple classes in chess.
    # @author Ancient Nimbus
    module ChessUtils
      # Algebraic chess notation to positional value hash
      ALG_MAP = [*"a".."h"].each_with_index.flat_map do |file, col|
        [*"#{file}1".."#{file}8"].map.with_index { |alg, row| [alg.to_sym, row * 8 + col] }
      end.to_h.freeze

      # Chess Piece notations reference
      ALG_REF = {
        k: { class: "King", notation: :k }, q: { class: "Queen", notation: :q }, r: { class: "Rook", notation: :r },
        b: { class: "Bishop", notation: :b }, n: { class: "Knight", notation: :n }, p: { class: "Pawn", notation: :p }
      }.freeze

      # Default symbol for white and black
      SIDES_SYM = %i[white black].freeze

      # Preferred time format
      STR_TIME = "%m/%d/%Y %I:%M %p"

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

      # == Board logics ==

      # Returns white as symbol
      def w_sym = SIDES_SYM[0]

      # Returns black as symbol
      def b_sym = SIDES_SYM[1]

      # Flip-flop, return :black if it is :white
      # @param side [Symbol] expects argument to be :black or :white
      # @return [Symbol, nil] :black or :white
      def opposite_of(side)
        return nil unless SIDES_SYM.include?(side)

        side == w_sym ? b_sym : w_sym
      end
    end
  end
end
