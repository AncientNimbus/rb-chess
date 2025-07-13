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
      #  :promotion - Pawn specific pattern, usable when Pawn reaches the other end of the board.
      #  :check - Optional check and checkmate indicator.
      #  :castling - King specific pattern usable when Castling move is possible.
      # @return [Hash<Symbol, String>] patterns required to construct algebraic notation input.
      ALG_PATTERN = {
        pieces: "(?<piece>[KQRBN])?",
        disambiguation: "(?<file>[a-h])?(?<rank>[1-8])?",
        capture: "(?<capture>x)?",
        destination: "(?<target>[a-h][1-8])",
        promotion: "(?:=(?<promotion>[QRBN]))?",
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
        case alg_output_capture_gps(input, reg)
        in { castle:, **nil } then parse_castling(input, side)
        in { file:, capture:, target:, promotion:, **nil } then { type: :move_promote, args: [file, target, promotion] }
        in { file:, capture:, target:, **nil } then { type: :pawn_capture, args: [file, target] }
        in { target:, promotion:, **nil } then { type: :pawn_promote, args: [target, promotion] }
        in { piece:, target:, capture:, **nil } then { type: :piece_capture, args: [piece, target] }
        in { piece:, file:, target:, **nil } then { type: :disambiguated_move, args: [piece, file, target] }
        in { piece:, target:, **nil } then { type: :piece_move, args: [piece, target] }
        in { target:, **nil } then { type: :pawn_move, args: [target] }
        else { type: :invalid_notation, args: [input] }
        end
      end

      # Helper: Process regexp and returns a named capture groups
      # @param input [String] input value from prompt
      # @param reg [String] regexp pattern
      # @return [Hash]
      def alg_output_capture_gps(input, reg)
        input.match(reg)&.named_captures(symbolize_names: true)&.compact
      end

      # Helper: parse castling input
      # @param input [String] input value from prompt
      # @param side [Symbol] player side :white or :black
      # @return [Hash] a command pattern hash
      def parse_castling(input, side)
        rank = side == :white ? "1" : "8"
        dir = input == "O-O" ? "g" : "c"
        curr_pos = "e#{rank}"
        new_pos = "#{dir}#{rank}"
        { type: :direct_move, args: [curr_pos, new_pos] }
      end

      # == Utilities ==

      # Algebraic Regexp pattern builder
      # @param notation_override [Hash]
      #   @option :k [String] Notation for King
      #   @option :q [String] Notation for Queen
      #   @option :r [String] Notation for Rook
      #   @option :b [String] Notation for Bishop
      #   @option :n [String] Notation for Knight
      # @return [Array<Hash>]
      def regexp_algebraic
        castling_gp = ALG_PATTERN.select { |k, _| k == :castling }.values.join
        regular_gp = ALG_PATTERN.reject { |k, _| k == :castling }.values.join
        [castling_gp, regular_gp]
      end
    end
  end
end
