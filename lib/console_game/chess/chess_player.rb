# frozen_string_literal: true

require_relative "../../pgn_utils/pgn_utils"
require_relative "../player"

module ConsoleGame
  module Chess
    # ChessPlayer is the Player object for the game Chess and it is a subclass of Player.
    class ChessPlayer < Player
      # @!attribute [w] piece_at_hand
      #   @return [ChessPiece]
      attr_accessor :side, :piece_at_hand
      # @!attribute [r] controller
      #   @return [ChessInput]
      attr_reader :level, :controller

      # @param game_manager [GameManager]
      # @param name [String]
      # @param controller [ChessInput]
      def initialize(game_manager = nil, name = "", controller = nil)
        super(game_manager, name, controller)
        @side = nil
        @piece_at_hand = nil
      end

      # Override: Initialise player save data
      def init_data
        @data = Hash.new do |hash, key|
          hash[key] = { event: nil, site: nil, date: nil, round: nil, white: nil, black: nil, result: nil, moves: {} }
        end
      end

      # Register session data
      # @param id [Integer] session id
      # @param p2_name [String] player 2's name
      # @param event [String] name of the event
      # @param site [String] name of the site
      # @param date [Time] time of the event
      def register_session(id, p2_name, event: "Ruby Arcade Chess Casual", site: "Ruby Arcade", date: Time.new.ceil)
        players = [name, p2_name].map { |name| Paint.unpaint(name) }
        white, black = side == :white ? players : players.reverse
        # @todo: to refactor
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
        puts "It is #{side}'s turn." # @todo: replace with TF string
        # Prompt player to enter notation value
        controller.turn_action(self)
        # Prompt player to enter move value when preview mode is used
        controller.make_a_move(self) unless piece_at_hand.nil?
      end

      # Preview a move, display the moves indictor
      # @param curr_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def preview_move(curr_alg_pos)
        return false unless level.assign_piece(curr_alg_pos)

        puts "Previewing #{piece_at_hand.name} at #{piece_at_hand.info}." # @todo Proper feedback
        level.refresh
      end

      # Chain with #preview_move, enables player make a move after previewing possible moves
      # @param new_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def move_piece(new_alg_pos)
        piece_at_hand.move(new_alg_pos)
        return false unless piece_at_hand.moved

        puts "Moving #{piece_at_hand.name} to #{piece_at_hand.info}." # @todo Proper feedback
        level.put_piece_down
        true
      end

      # Assign a piece and make a move on the same prompt
      # @param curr_alg_pos [String] algebraic position
      # @param new_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def direct_move(curr_alg_pos, new_alg_pos)
        level.assign_piece(curr_alg_pos) && move_piece(new_alg_pos)
      end

      # Pawn specific: Promote the pawn when it reaches the other end of the board
      # @param curr_alg_pos [String] algebraic position
      # @param new_alg_pos [String] algebraic position
      # @param notation [Symbol] algebraic notation
      # @return [Boolean] true if the operation is a success
      def direct_promote(curr_alg_pos, new_alg_pos, notation)
        return false unless level.assign_piece(curr_alg_pos) && piece_at_hand.is_a?(Pawn)

        piece_at_hand.move(new_alg_pos, notation)
        return false unless piece_at_hand.moved

        level.put_piece_down
        true
      end

      # Pawn specific: Present a list of option when player can promote a pawn
      def indirect_promote
        controller.promote_a_pawn
      end

      # Fetch and move
      # @param side [Symbol]
      # @param type [Symbol]
      # @param target [String]
      def fetch_and_move(side, type, target, file_rank = nil)
        piece = level.reverse_lookup(side, type, target, file_rank)

        return false if piece.nil?

        level.store_active_piece(piece)
        move_piece(target)
      end

      private

      # Store active level
      def link_level
        return if level == controller.level

        @level = controller.level
      end

      # Access player session keys
      def write_metadata(id, key, value)
        data[id][key] = value
      end
    end
  end
end
