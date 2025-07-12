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
        pieces: "(?<piece>[KQRBN])?", disambiguation: "(?<file>[a-h])?(?<rank>[1-8])?",
        capture: "(?<capture>x)?", destination: "(?<target>[a-h][1-8])", promotion: "(?:=(?<promotion>[QRBN]))?",
        check: "(?<check>[+#])?", castling: "(?<castle>O-O(?:-O)?)"
      }.freeze

      private

      # == Algebraic notation ==

      # Input validation when input scheme is set to Algebraic notation
      # @param output [String] output value from prompt
      # @return [Hash] a command pattern hash
      def validate_algebraic(output)
        p capture_gps = output.match(alg_reg)&.named_captures(symbolize_names: true)&.compact
        case capture_gps
        in { castle:, **nil } then p "Should castle: #{castle}" # char size 3 or 5
        in { file:, capture:, target:, promotion:, **nil } then p "#{file} Pawn capture #{target} and promote to #{promotion}"
        in { file:, capture:, target:, **nil } then p "#{file} Pawn captures #{target}"
        in { target:, promotion:, **nil } then p "Promoting #{target} Pawn to #{promotion}"
        in { piece:, target:, capture:, **nil } then p "#{piece} captures #{target}"
        in { piece:, file:, target:, **nil } then p "#{piece} from #{file} to #{target}"
        in { piece:, target:, **nil } then p "Moving #{piece} to #{target}"
        in { target:, **nil } then p "Moving Pawn to #{target}"
        else p "Invalid notation, please try again."
        end
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
