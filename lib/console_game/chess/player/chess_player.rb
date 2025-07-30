# frozen_string_literal: true

require_relative "../../player"
require_relative "../utilities/pgn_utils"
require_relative "../utilities/chess_utils"

module ConsoleGame
  module Chess
    # ChessPlayer is the Player object for the game Chess and it is a subclass of Player.
    class ChessPlayer < Player
      include ChessUtils
      # @!attribute [w] piece_at_hand
      #   @return [ChessPiece]
      attr_accessor :side, :piece_at_hand
      # @!attribute [r] controller
      #   @return [ChessInput]
      attr_reader :level, :controller, :moves_history, :session_id

      # @param name [String]
      # @param controller [ChessInput]
      # @param color [Symbol] :black or :white
      def initialize(name = "", controller = nil, color = nil)
        super(name, controller)
        @side = color
        @piece_at_hand = nil
        @moves_history = []
      end

      # Override: Initialise player save data
      def init_data
        @data = Hash.new do |hash, key|
          hash[key] =
            { event: nil, site: nil, date: nil, round: nil, white: nil, black: nil, result: nil, mode: nil, moves: {},
              fens: [] }
        end
      end

      # Register session data
      # @param id [Integer] session id
      # @param [Hash] metadata fields for PGN style data
      # @option mode [Integer] game mode
      # @option white [String] white player name
      # @option black [String] black player name
      # @option event [String] name of the event
      # @option site [String] name of the site
      # @return [Hash] session data
      def register_session(id, **metadata)
        @session_id = id
        metadata.each { |k, v| write_metadata(k, v) }
        data[id]
      end

      # Store active level
      # @param active_level [Level]
      def link_level(active_level)
        return if level == active_level

        @level = active_level
      end

      # == Game Logic ==

      # Play a turn in chess as a human player, input action is handled by ChessInput
      # Placeholder method for ChessComputer
      def play_turn; end

      # Preview a move, display the moves indictor
      # Prompt player to enter move value when preview mode is used
      # @param curr_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def preview_move(curr_alg_pos)
        return false unless assign_piece(curr_alg_pos)

        level.refresh
        sub = { name: piece_at_hand.name, info: piece_at_hand.info }
        controller.print_msg(controller.s("level.preview", sub), pre: "* ")

        # Second prompt to complete the turn
        controller.make_a_move(self)
        true
      end

      # Chain with #preview_move, enables player make a move after previewing possible moves
      # @param new_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def move_piece(new_alg_pos)
        piece_at_hand.move(new_alg_pos)
        return false unless piece_at_hand.moved

        sub = { player: name, name: piece_at_hand.name, info: piece_at_hand.info }
        level.event_msgs << controller.s("level.move", sub)

        turn_end
      end

      # Assign a piece and make a move on the same prompt
      # @param curr_alg_pos [String] algebraic position
      # @param new_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def direct_move(curr_alg_pos, new_alg_pos)
        assign_piece(curr_alg_pos) && move_piece(new_alg_pos)
      end

      # Pawn specific: Promote the pawn when it reaches the other end of the board
      # @param curr_alg_pos [String] algebraic position
      # @param new_alg_pos [String] algebraic position
      # @param notation [Symbol] algebraic notation
      # @return [Boolean] true if the operation is a success
      def direct_promote(curr_alg_pos, new_alg_pos, notation)
        return false unless assign_piece(curr_alg_pos) && piece_at_hand.is_a?(Pawn)

        piece_at_hand.move(new_alg_pos, notation)
        return false unless piece_at_hand.moved

        turn_end
      end

      # Pawn specific: Present a list of option when player can promote a pawn
      def indirect_promote
        level.refresh
        controller.promote_a_pawn
      end

      # Fetch and move
      # @param side [Symbol]
      # @param type [Symbol]
      # @param target [String]
      def fetch_and_move(side, type, target, file_rank = nil)
        piece = level.reverse_lookup(side, type, target, file_rank)

        return false if piece.nil?

        store_active_piece(piece)
        move_piece(target)
      end

      # Invalid input
      def invalid_input(input)
        keypath = input.empty? ? "cmd.input.done" : "'cmd.input.err"
        level.board.print_msg(level.board.s(keypath, { input: input }), pre: "* ")
        false
      end

      private

      # Handling piece assignment
      # @param alg_pos [String] algebraic notation
      # @return [ChessPiece]
      def assign_piece(alg_pos)
        put_piece_down
        piece = level.fetch_piece(alg_pos, bypass: false)
        return level.board.print_after_cb("level.err.notation") if piece.nil?

        store_active_piece(piece)
      end

      # Unassign active piece
      def put_piece_down
        level.active_piece = nil
        self.piece_at_hand = nil
      end

      # store active piece
      # @param piece [ChessPiece]
      # @param current_level [Level]
      # @return [ChessPiece]
      def store_active_piece(piece, current_level = level)
        self.piece_at_hand = piece
        current_level.active_piece = piece_at_hand
        piece_at_hand
      end

      # States that player action has ended
      # @return [Boolean]
      def turn_end
        piece_at_hand.is_a?(Pawn) ? level.half_move = 0 : level.half_move += 1
        moves_history << piece_at_hand.last_move
        level.reset_en_passant
        put_piece_down
        true
      end

      # Access player session keys
      def write_metadata(key, value)
        data[session_id][key] = value.is_a?(String) ? Paint.unpaint(value) : value
      end
    end
  end
end
