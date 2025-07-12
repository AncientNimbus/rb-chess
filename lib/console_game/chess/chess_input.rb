# frozen_string_literal: true

require_relative "../input"

module ConsoleGame
  module Chess
    # Input controller for the game Chess
    class ChessInput < Input
      attr_accessor :input_scheme, :input_parser
      attr_reader :alg_reg, :smith_reg, :level

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

      # Smith Input Regexp pattern
      # The first capture group is used to support move preview mode
      # The second capture group is used to support direct move and place
      SMITH_PATTERN = {
        base: "(?:[a-h][1-8])|(?:[a-h][1-8]){2}", promotion: "(?:[qrbn])"
      }.freeze

      # Regexp parser
      REG_PARSER = { alg: nil, smith: /[a-z]\d*/ }.freeze

      def initialize(game_manager = nil)
        super(game_manager)
        @alg_reg = regexp_algebraic
        @smith_reg = regexp_smith
        @input_scheme = smith_reg
        @input_parser = REG_PARSER[:smith]
      end

      # Store active level object
      # @param level [Chess::Level] expects a chess Level class object
      def link_level(level)
        @level = level
      end

      # == Core methods ==

      # Get user input and process them accordingly
      def turn_action
        output = ask("Pick a piece and make a move: ", reg: input_scheme, input_type: :custom)
        case input_scheme
        when smith_reg then validate_smith(output)
        when alg_reg then validate_algebraic(output)
        end
      end

      # Prompt user for the second time in the same turn if the first prompt was a preview move event
      def make_a_move
        output = ask("Make a move: ", reg: input_scheme, input_type: :custom)
        ops = case output.scan(input_parser)
              in [new_pos] then { type: :move_piece, args: [new_pos] }
              end
        make_a_move unless level.method(ops[:type]).call(*ops[:args])
      end

      # Prompt user for Pawn promotion option when notation for promotion is not provided at the previous prompt
      def promote_a_pawn
        ask("Your pawn is ready for a promotion ", reg: SMITH_PATTERN[:promotion], input_type: :custom)
      end

      private

      # == Smith notation ==

      # Input validation when input scheme is set to Smith notation
      # @param output [String] output value from prompt
      def validate_smith(output)
        ops = case output.scan(input_parser)
              in [curr_pos] then { type: :preview_move, args: [curr_pos] }
              in [curr_pos, new_pos] then { type: :direct_move, args: [curr_pos, new_pos] }
              in [curr_pos, new_pos, notation] then { type: :direct_promote, args: [curr_pos, new_pos, notation] }
              end
        turn_action unless level.method(ops[:type]).call(*ops[:args])
      end

      # == Algebraic notation ==

      # Input validation when input scheme is set to Algebraic notation
      # @param output [String] output value from prompt
      def validate_algebraic(output)
        p capture_gps = output.match(alg_reg)&.named_captures(symbolize_names: true)&.compact
        valid_ops = case capture_gps
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
        turn_action unless valid_ops
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

      # Change input mode to detect Smith Notation | command pattern: `smith`
      def smith(_arr = [])
        p "Input settings updated! The game will detect Smith notation."
        self.input_scheme = smith_reg
        self.input_parser = REG_PARSER[:smith]
      end

      # Change input mode to detect Algebraic Notation | command pattern: `alg`
      def alg(_arr = [])
        # p "Input settings updated! The game will detect Algebraic notation."
        # self.input_scheme = alg_reg # @todo: Not ready
      end

      # Update board settings | command pattern: `board`
      # @example usage example
      #  `--board size`
      #  `--board flip`
      def board(arr = [])
        case arr
        in ["size"] then level.adjust_board_size
        in ["flip"] then level.flip_setting
        else puts "Invalid command detected, type --help to view all possible commands." # @todo: Move to TF
        end
      end

      # == Unities ==

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

      # Algebraic Regexp pattern builder
      # @return [String]
      def regexp_smith
        "#{SMITH_PATTERN.values.join('')}?"
      end

      # Setup input commands
      def setup_commands
        super.merge({ "save" => method(:save), "load" => method(:load), "export" => method(:export),
                      "smith" => method(:smith), "alg" => method(:alg), "board" => method(:board) })
      end
    end
  end
end
