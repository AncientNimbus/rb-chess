# frozen_string_literal: true

require_relative "game"
require_relative "logic"
require_relative "board"
require_relative "piece_analysis"

module ConsoleGame
  module Chess
    # The Level class handles the core game loop of the game Chess
    # @author Ancient Nimbus
    class Level
      include Console
      include Logic
      include PieceAnalysis

      attr_accessor :white_turn, :turn_data, :active_piece, :previous_piece, :en_passant, :player
      attr_reader :mode, :controller, :w_player, :b_player, :sessions, :board, :kings, :castling_states,
                  :threats_map, :usable_pieces

      # @param mode [Integer]
      # @param input [ChessInput]
      # @param sides [hash]
      #   @option sides [ChessPlayer, ChessComputer] :white Player who plays as White
      #   @option sides [ChessPlayer, ChessComputer] :black Player who plays as Black
      # @param sessions [hash]
      # @param import_fen [String] expects a valid FEN string
      def initialize(mode, input, sides, sessions, import_fen = nil)
        @mode = mode
        @controller = input
        @w_player, @b_player = sides.values
        @session = sessions
        @turn_data = import_fen.nil? ? parse_fen(self) : parse_fen(self, import_fen)
        @board = Board.new(self)
      end

      # == Flow ==

      # Start level
      def open_level
        init_level
        play_chess until any_checkmate?
        end_game
      end

      # Initialise the chessboard
      def init_level
        # p "Setting up game level"
        controller.link_level(self)
        @white_turn = true
        @castling_states = { K: true, Q: true, k: true, q: true }
        @kings = { white: nil, black: nil }
        @threats_map = { white: [], black: [] }
        @usable_pieces = { white: [], black: [] }
        @en_passant = nil
        @player = w_player
        kings_table
      end

      # Main Game Loop
      def play_chess
        self.player = white_turn ? w_player : b_player
        # Pre turn
        puts "It is #{player.side}'s turn."
        refresh
        # Play turn
        player.is_a?(ChessComputer) ? ai_actions : human_actions(player)
        # Post turn
        # Pass control to the other side
        self.white_turn = !white_turn
      end

      # Endgame handling
      def end_game
        p "Game session complete, \nShould return to game.rb"
      end

      # == Game Logic ==

      # Turn events when player is a human
      # @param player [ChessPlayer]
      def human_actions(player)
        # Prompt player to enter notation value
        controller.turn_action(player)
        # Prompt player to enter move value when preview mode is used
        controller.make_a_move unless active_piece.nil?
      end

      # Turn events when player is a computer
      def ai_actions
        p "Computer's move"
      end

      # Preview a move, display the moves indictor
      # @param curr_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def preview_move(curr_alg_pos)
        return false unless assign_piece(curr_alg_pos)

        puts "Previewing #{active_piece.name} at #{active_piece.info}." # @todo Proper feedback
        refresh
      end

      # Chain with #preview_move, enables player make a move after previewing possible moves
      # @param new_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def move_piece(new_alg_pos)
        active_piece.move(new_alg_pos)
        return false unless active_piece.moved

        puts "Moving #{active_piece.name} to #{active_piece.info}." # @todo Proper feedback
        put_piece_down
        true
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
        return false unless assign_piece(curr_alg_pos) && active_piece.is_a?(Pawn)

        active_piece.move(new_alg_pos, notation)
        return false unless active_piece.moved

        put_piece_down
        true
      end

      # Fetch and move
      # @param side [Symbol]
      # @param type [Symbol]
      # @param target [String]
      def fetch_and_move(side, type, target, file_rank = nil)
        type = Chess.const_get(PRESET.dig(type, :class))
        piece = reverse_lookup(side, type, alg_map[target.to_sym], file_rank)

        return false if piece.nil?

        self.active_piece = piece
        move_piece(target)
      end

      # Pawn specific: Present a list of option when player can promote a pawn
      def promote_opts
        refresh
        controller.promote_a_pawn
      end

      # Reset En Passant status when it is not used at the following turn
      def reset_en_passant
        return if en_passant.nil?

        self.en_passant = nil if active_piece.curr_pos != en_passant[1]
      end

      # == Utilities ==

      # Fetch a single chess piece
      # @param query [String] algebraic notation `"e4"`
      # @param side [Symbol] expects :all, :white or :black
      # @param usable_pieces [Hash<Array<String>>] algebraic notations in string
      # @return [ChessPiece]
      def fetch_piece(query)
        return puts "'#{query}' is not a valid notation." unless usable_pieces[player.side].include?(query)

        turn_data[alg_map[query.to_sym]]
      end

      # Grab all pieces, only whites or only blacks
      # @param side [Symbol] expects :all, :white or :black
      # @param type [ChessPiece, King, Queen, Rook, Bishop, Knight, Pawn] limit selection
      # @return [Array<ChessPiece>] a list of chess pieces
      def fetch_all(side = :all, type: ChessPiece)
        turn_data.select { |tile| tile.is_a?(type) && (%i[black white].include?(side) ? tile.side == side : true) }
      end

      # Lookup a piece based on its possible move position
      # @param side [Symbol]
      # @param type [King, Queen, Bishop, Knight, Rook, Pawn]
      # @param new_alg_pos [Integer]
      # @param file_rank [String]
      def reverse_lookup(side, type, new_alg_pos, file_rank = nil)
        filtered_pieces = fetch_all(side, type: type)
        result = filtered_pieces.select do |piece|
          piece.possible_moves.include?(new_alg_pos) && (file_rank.nil? || piece.info.include?(file_rank))
        end
        return nil if result.size > 1

        result[0]
      end

      private

      # == Board Logic ==

      # Actions to perform when player input is valid
      # @return [Boolean] true if the operation is a success
      def refresh
        update_board_state
        board.print_chessboard
        true
      end

      # Handling piece assignment
      # @param alg_pos [String] algebraic notation
      # @return [ChessPiece]
      def assign_piece(alg_pos)
        put_piece_down
        piece = fetch_piece(alg_pos)
        return nil if piece.nil?

        # p "active piece: #{piece.side} #{piece.name}" # @todo: debug

        @previous_piece = active_piece
        @active_piece = piece
        self.previous_piece ||= active_piece
        active_piece
      end

      # Unassign active piece
      def put_piece_down
        self.active_piece = nil
      end

      # Get and store both Kings
      def kings_table
        fetch_all(type: King).each { |king| kings[king.side] = king }
      end

      # Generate possible moves & targets for all pieces, all whites or all blacks
      # @param side [Symbol] expects :all, :white or :black
      def generate_moves(side = :all)
        side = :all unless %i[black white].include?(side)
        fetch_all(side).each(&:query_moves)
      end

      # Board state refresher
      def update_board_state
        grouped_pieces = pieces_group
        @threats_map, @usable_pieces = board_analysis(grouped_pieces)
        # puts usable_pieces
        # puts threats_map
        any_checkmate?
      end

      # Refresh possible move and split chess pieces into two group
      # @return [Hash]
      def pieces_group
        grouped_pieces = { white: nil, black: nil }
        grouped_pieces[:white], grouped_pieces[:black] = generate_moves(:all).partition { |piece| piece.side == :white }
        grouped_pieces
      end

      # End game if either side achieved a checkmate
      def any_checkmate?
        kings.values.any?(&:checkmate?)
      end

      # User data handling
    end
  end
end
