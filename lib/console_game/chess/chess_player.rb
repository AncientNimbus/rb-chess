# frozen_string_literal: true

require_relative "../player"
require_relative "utilities/pgn_utils"

module ConsoleGame
  module Chess
    # ChessPlayer is the Player object for the game Chess and it is a subclass of Player.
    class ChessPlayer < Player
      # @!attribute [w] piece_at_hand
      #   @return [ChessPiece]
      attr_accessor :side, :piece_at_hand, :move_count
      # @!attribute [r] controller
      #   @return [ChessInput]
      attr_reader :level, :controller

      # @param name [String]
      # @param controller [ChessInput]
      def initialize(name = "", controller = nil)
        super(name, controller)
        @side = nil
        @piece_at_hand = nil
        @move_count = 0
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
      # @param p2_name [String] player 2's name
      # @param mode [Integer] game mode
      # @param event [String] name of the event
      # @param site [String] name of the site
      # @param date [Time] time of the event
      def register_session(id, p2_name, mode, event: "Casual", site: "Ruby Arcade by Ancient Nimbus",
                           date: Time.new.ceil)
        players = [name, p2_name].map { |name| Paint.unpaint(name) }
        white, black = side == :white ? players : players.reverse
        # @todo: to refactor
        write_metadata(id, :mode, mode)
        write_metadata(id, :white, white)
        write_metadata(id, :black, black)
        write_metadata(id, :event, event)
        write_metadata(id, :site, site)
        write_metadata(id, :date, date)
        data[id]
      end

      # == Game Logic ==

      # Play a turn in chess as a human player
      def play_turn
        link_level
        puts "It is #{name}'s turn." # @todo: replace with TF string
        # Prompt player to enter notation value
        controller.turn_action(self)
        level.reset_en_passant

        put_piece_down
      end

      # Preview a move, display the moves indictor
      # Prompt player to enter move value when preview mode is used
      # @param curr_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def preview_move(curr_alg_pos)
        return false unless assign_piece(curr_alg_pos)

        puts "Previewing #{piece_at_hand.name} at #{piece_at_hand.info}." # @todo Proper feedback
        level.refresh

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

        puts "Moving #{piece_at_hand.name} to #{piece_at_hand.info}." # @todo Proper feedback
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

      private

      # Handling piece assignment
      # @param alg_pos [String] algebraic notation
      # @return [ChessPiece]
      def assign_piece(alg_pos)
        put_piece_down
        piece = level.fetch_piece(alg_pos)
        return nil if piece.nil?

        # p "active piece: #{piece.side} #{piece.name}" # @todo: debug

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
        current_level.previous_piece = piece_at_hand
        self.piece_at_hand = piece
        current_level.active_piece = piece_at_hand
        current_level.previous_piece ||= piece_at_hand
        piece_at_hand
      end

      # Store active level
      def link_level
        return if level == controller.level

        @level = controller.level
      end

      # Helper: Explicitly state that player action has ended
      def turn_end
        piece_at_hand.is_a?(Pawn) ? level.half_move = 0 : level.half_move += 1
        # p piece_at_hand.last_move
        true
      end

      # Access player session keys
      def write_metadata(id, key, value)
        data[id][key] = value
      end
    end
  end
end
