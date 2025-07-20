# frozen_string_literal: true

module ConsoleGame
  module Chess
    # Module to parse Algebraic notation
    module AlgebraicNotation
      # Algebraic Input Regexp pattern
      #  keys:
      #  :pieces - Piece notations.
      #  :disambiguation - Useful when two (or more) identical pieces can move to the same square.
      #  :capture - Indicate the move is a capture.
      #  :destination - Indicate destination square.
      #  :promote - Pawn specific pattern, usable when Pawn reaches the other end of the board.
      #  :check - Optional check and checkmate indicator.
      #  :castling - King specific pattern usable when Castling move is possible.
      # @return [Hash<Symbol, String>] patterns required to construct algebraic notation input.
      ALG_PATTERN = {
        pieces: "(?<piece>[KQRBN])?",
        disambiguation: "(?<file_rank>[a-h][1-8]|[a-h])?",
        capture: "(?<capture>x)?",
        destination: "(?<target>[a-h][1-8])",
        promote: "(?:=(?<promote>[QRBN]))?",
        check: "(?<check>[+#])?",
        castling: "(?<castle>O-O(?:-O)?)"
      }.freeze

      private

      # == Algebraic notation ==

      # Input validation when input scheme is set to Algebraic notation
      # @param input [String] input value from prompt
      # @param side [Symbol] player side :white or :black
      # @param reg [String] regexp pattern
      # @return [Hash] a command pattern hash
      def validate_algebraic(input, side, reg)
        captures = alg_output_capture_gps(input, reg)
        return { type: :invalid_input, args: [input] } unless captures

        if captures[:castle]
          parse_castling(side, captures[:castle])
        elsif captures[:promote]
          parse_promote(side, captures)
        else
          parse_move(side, captures)
        end
      end

      # Helper: Process regexp and returns a named capture groups
      # @param input [String] input value from prompt
      # @param reg [String] regexp pattern
      # @return [Hash]
      def alg_output_capture_gps(input, reg) = input.match(reg)&.named_captures(symbolize_names: true)&.compact

      # Helper: parse castling input
      # @param side [Symbol] player side :white or :black
      # @param castle [String]
      # @return [Hash] a command pattern hash
      def parse_castling(side, castle)
        rank = side == :white ? "1" : "8"
        new_file = castle == "O-O" ? "g" : "c"
        { type: :direct_move, args: ["e#{rank}", "#{new_file}#{rank}"] }
      end

      # Helper: parse pawn promote & capture
      # @param side [Symbol] player side :white or :black
      # @param captures [hash]
      # @return [Hash] a command pattern hash
      def parse_promote(side, captures)
        target, promote = captures.slice(:target, :promote).values
        rank = side == :white ? "7" : "2"
        file = captures[:file_rank] || captures[:target][0]

        { type: :direct_promote, args: ["#{file}#{rank}", target, notation_to_sym(promote)] }
      end

      # Helper: parse pawn movement
      # @param side [Symbol] player side :white or :black
      # @param captures [hash]
      # @return [Hash] a command pattern hash
      def parse_move(side, captures)
        piece_type = notation_to_sym(captures[:piece] || :p)

        { type: :fetch_and_move, args: [side, piece_type, captures[:target], captures[:file_rank]].compact }
      end

      # == Utilities ==

      # Algebraic Regexp pattern builder
      # @return [Array<String>]
      def regexp_algebraic
        castling_gp = ALG_PATTERN.select { |k, _| k == :castling }.values.join
        regular_gp = ALG_PATTERN.reject { |k, _| k == :castling }.values.join
        [castling_gp, regular_gp]
      end

      # Helper: Convert algebraic notation to internal symbol
      # @param notation [String]
      # @return [Symbol]
      def notation_to_sym(notation)
        return notation if notation.is_a?(Symbol)

        notation.downcase.to_sym
      end
    end
  end
end
