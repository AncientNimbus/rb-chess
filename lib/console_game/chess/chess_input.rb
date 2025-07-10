# frozen_string_literal: true

require_relative "../input"

module ConsoleGame
  module Chess
    # Input controller for the game Chess
    class ChessInput < Input
      attr_reader :alg_pattern

      def initialize(game_manager = nil)
        super(game_manager)
        @alg_pattern = regexp_algebraic
      end

      # == Core methods ==

      # == Chess Related Inputs ==

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
        pieces: "[KQRBN]?", disambiguation: "[a-h]?[1-8]?", capture: "x?", destination: "[a-h][1-8]",
        promotion: "(?:=[QRBN])?", check: "[+#]?", castling: "O-O(?:-O)?"
      }.freeze

      # Algebraic Regexp pattern builder
      # @param notation_override [Hash]
      #   @option :k [String] Notation for King
      #   @option :q [String] Notation for Queen
      #   @option :r [String] Notation for Rook
      #   @option :b [String] Notation for Bishop
      #   @option :n [String] Notation for Knight
      # @return [String]
      def regexp_algebraic
        castling_gp = ALG_PATTERN.select { |k, _| k == :castling }.values.join
        regular_gp = ALG_PATTERN.reject { |k, _| k == :castling }.values.join
        regexp_capturing_gp([castling_gp, regular_gp])
      end

      # == Console Commands ==

      # Exit sequences | command patterns: `exit`
      def quit(_arg = [])
        print_msg(s("cli.lobby.exit"), pre: "*")
        exit
      end

      # Display help string | command pattern: `help`
      def help(_arr = [])
        print_msg("Type --exit to exit the program")
      end

      # Display system info | command pattern: `info`
      def info(_arr = [])
        p "Will print game info"
      end

      # Save session to player data | command pattern: `save`
      def save(_arr = [])
        p "Will save session to player session, then store player data to user profile"
      end

      # Load session from player data | command pattern: `load`
      def load(_arr = [])
        p "Will allow player to switch between other sessions stored within their own user profile"
      end

      # Export current game session as pgn file | command pattern: `export`
      def export(_arr = [])
        p "Will export session to local directory as a pgn file"
      end

      # Change input mode to detect Smith Notation
      def smith(_arr = [])
        p "Input settings updated! The game will detect Smith notation."
      end

      # Change input mode to detect Algebraic Notation
      def alg(_arr = [])
        p "Input settings updated! The game will detect Algebraic notation."
      end

      private

      # == Unities ==

      # Setup input commands
      def setup_commands
        super.merge({ "save" => method(:save), "load" => method(:load), "export" => method(:export),
                      "smith" => method(:smith), "alg" => method(:alg) })
      end
    end
  end
end
