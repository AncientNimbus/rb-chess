# frozen_string_literal: true

require_relative "../../input"
require_relative "smith_notation"
require_relative "algebraic_notation"

module ConsoleGame
  module Chess
    # Input controller for the game Chess
    class ChessInput < Input
      include SmithNotation
      include AlgebraicNotation

      attr_accessor :input_scheme, :input_parser
      attr_reader :alg_reg, :smith_reg, :level, :active_side

      def initialize(game_manager = nil)
        super(game_manager)
        notation_patterns_builder
        @input_scheme = smith_reg
        @input_parser = SMITH_PARSER
      end

      # Store active level object
      # @param level [Chess::Level] expects a chess Level class object
      def link_level(level)
        @level = level
      end

      # == Core methods ==

      # Get user input and process them accordingly
      # @param player [ChessPlayer]
      def turn_action(player)
        input = ask("Pick a piece and make a move: ", reg: input_scheme, input_type: :custom, empty: true)
        ops = case input_scheme
              when smith_reg then validate_smith(input)
              when alg_reg then validate_algebraic(input, player.side, input_scheme)
              end
        turn_action(player) unless player.method(ops[:type]).call(*ops[:args])
      end

      # Prompt user for the second time in the same turn if the first prompt was a preview move event
      # @param player [ChessPlayer]
      def make_a_move(player)
        input = ask("Make a move: ", reg: SMITH_PATTERN[:gp1], input_type: :custom)
        ops = case input.scan(input_parser)
              in [new_pos] then { type: :move_piece, args: [new_pos] }
              else { type: :invalid_input, args: [input] }
              end
        make_a_move(player) unless player.method(ops[:type]).call(*ops[:args])
      end

      # Prompt user for Pawn promotion option when notation for promotion is not provided at the previous prompt
      def promote_a_pawn
        ask("Your pawn is ready for a promotion ", reg: SMITH_PATTERN[:promotion], input_type: :custom)
      end

      # == Console Commands ==

      # Exit sequences | command patterns: `exit`
      def quit(_args = [])
        print_msg(s("cli.lobby.exit"), pre: "*")
        exit
      end

      # Display help string | command pattern: `help`
      def help(_args = [])
        print_msg("Type --exit to exit the program")
      end

      # Display system info | command pattern: `info`
      def info(_args = [])
        p "Will print game info"
      end

      # Save session to player data | command pattern: `save`
      def save(_args = [])
        return if level.nil?

        p "Will save session to player session, then store player data to user profile"
        game_manager.user.save_profile
      end

      # Load session from player data | command pattern: `load`
      def load(_args = [])
        return if level.nil?

        p "Will allow player to switch between other sessions stored within their own user profile"
      end

      # Export current game session as pgn file | command pattern: `export`
      def export(_args = [])
        return if level.nil?

        p "Will export session to local directory as a pgn file"
      end

      # Change input mode to detect Smith Notation | command pattern: `smith`
      def smith(_args = [])
        return if level.nil?

        puts "The game will detect Smith notation starting from the next prompt, press 'enter' to confirm."
        self.input_scheme = smith_reg
        self.input_parser = SMITH_PARSER
      end

      # Change input mode to detect Algebraic Notation | command pattern: `alg`
      def alg(_args = [])
        return if level.nil?

        puts "The game will detect Algebraic notation starting from the next prompt, press 'enter' to confirm."
        self.input_scheme = alg_reg
      end

      # Update board settings | command pattern: `board`
      # @example usage example
      #  `--board size`
      #  `--board flip`
      def board(args = [])
        return if level.nil?

        case args
        in ["size"] then level.board.adjust_board_size
        in ["flip"] then level.board.flip_setting
        else puts "Invalid command detected, type --help to view all possible commands." # @todo: Move to TF
        end
      end

      private

      # == Utilities ==

      # Create regexp patterns for various input modes
      def notation_patterns_builder
        @alg_reg = regexp_capturing_gp(regexp_algebraic)
        @smith_reg = regexp_smith
      end

      # Setup input commands
      def setup_commands
        super.merge({ "save" => method(:save), "load" => method(:load), "export" => method(:export),
                      "smith" => method(:smith), "alg" => method(:alg), "board" => method(:board) })
      end
    end
  end
end
