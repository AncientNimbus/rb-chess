# frozen_string_literal: true

require_relative "../../input"
require_relative "../logics/display"
require_relative "smith_notation"
require_relative "algebraic_notation"

module ConsoleGame
  module Chess
    # Input controller for the game Chess
    class ChessInput < Input
      include Display
      include SmithNotation
      include AlgebraicNotation

      attr_accessor :input_scheme, :input_parser
      attr_reader :alg_reg, :smith_reg, :level, :active_side, :chess_manager

      # @param game_manager [GameManager]
      # @param chess_manager [Game]
      def initialize(game_manager = nil, chess_manager = nil)
        super(game_manager)
        @chess_manager = chess_manager
        notation_patterns_builder
        @input_scheme = smith_reg
        @input_parser = SMITH_PARSER
      end

      # Store active level object
      # @param level [Chess::Level] expects a chess Level class object
      def link_level(level) = @level = level

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
        input = ask("Make a move: ", reg: SMITH_PATTERN[:gp1], input_type: :custom, empty: true)
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

      # Chess Override: process user input
      # @param msg [String] first print
      # @param cmds [Hash] expects a list of commands hash
      # @param err_msg [String] second print
      # @param reg [Regexp, String, Array<String>] pattern to match, use an Array when input type is :range
      # @param empty [Boolean] allow empty input value, default to false
      # @param input_type [Symbol] expects the following option: :any, :range, :custom
      # @return [String]
      def ask(msg = "", cmds: commands, err_msg: s("cmd.std_err"), reg: ".*", empty: false, input_type: :any) = super

      # == Console Commands ==

      # Exit sequences | command patterns: `exit`
      def quit(_args = [])
        print_msg(s("cmd.exit"))
        super
      end

      # Display help string | command pattern: `help`
      def help(args = [])
        keypath = case args
                  in ["alg"] then "alg_h"
                  in ["smith"] then "sm_h"
                  else "help"
                  end
        print_msg(s(keypath))
      end

      # Display system info | command pattern: `info`
      def info(_args = [])
        str = level.nil? ? s("cmd.info", { ver: chess_manager.ver }) : s("cmd.info2", build_info_data)
        print_msg(str)
      end

      # Save session to player data | command pattern: `save`
      # @param mute [Boolean] bypass printing when use at the background
      def save(_args = [], mute: false)
        return cmd_disabled if level.nil?

        game_manager.save_user_profile(mute:)
      end

      # Load another session from player data | command pattern: `load`
      def load(_args = [])
        return cmd_disabled if level.nil?

        # save(mute: true)
        print_msg(s("cmd.load"), pre: "* ")
        chess_manager.setup_game
      end

      # Export current game session as pgn file | command pattern: `export`
      # @todo: not ready
      def export(_args = [])
        print_msg(s("cmd.soon"), pre: "* ")
        # return cmd_disabled if level.nil?

        # print_msg(s("cmd.export"), pre: "* ")
      end

      # Change input mode to detect Smith Notation | command pattern: `smith`
      def smith(_args = [])
        return cmd_disabled if level.nil?

        print_msg(s("cmd.input.smith"), pre: "* ")
        self.input_scheme = smith_reg
        self.input_parser = SMITH_PARSER
      end

      # Change input mode to detect Algebraic Notation | command pattern: `alg`
      def alg(_args = [])
        return cmd_disabled if level.nil?

        print_msg(s("cmd.input.alg"), pre: "* ")
        self.input_scheme = alg_reg
      end

      # Update board settings | command pattern: `board`
      # @example usage example
      #  `--board size`
      #  `--board flip`
      def board(args = [])
        return cmd_disabled if level.nil?

        case args
        in ["size"] then level.board.adjust_board_size
        in ["flip"] then level.board.flip_setting
        else print_msg(s("cmd.err"), pre: D_MSG[:warn_prefix])
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

      # Print command is disabled at this stage
      def cmd_disabled = print_msg(s("cmd.disabled"), pre: D_MSG[:warn_prefix])

      # Helper to build session info data
      # @return [Hash]
      def build_info_data
        date, fens, event, white, black = level.session.values_at(:date, :fens, :event, :white, :black)
        { date: Time.new(date).strftime("%m/%d/%Y %I:%M %p"), fen: fens.last,
          event: event, w_player: white, b_player: black, ver: chess_manager.ver }
      end
    end
  end
end
