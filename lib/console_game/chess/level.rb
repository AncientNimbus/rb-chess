# frozen_string_literal: true

require_relative "game"
require_relative "logic"
require_relative "display"

module ConsoleGame
  module Chess
    # The Level class handles the core game loop of the game Chess
    # @author Ancient Nimbus
    class Level
      include Console
      include Logic
      include Display

      attr_accessor :white_turn, :turn_data, :active_piece, :previous_piece, :en_passant, :player
      attr_reader :mode, :controller, :w_player, :b_player, :sessions, :kings, :castling_states, :threats_map,
                  :usable_pieces

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
        p "Setting up game level"
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
        puts "It is #{player.side}'s turn."
        ops_successful
        # Prompt player to enter notation value
        controller.turn_action
        # Prompt player to enter move value when preview mode is used
        controller.make_a_move unless active_piece.nil?
        # Turn end handling
        # Pass control to the other side
        self.white_turn = !white_turn
      end

      # Endgame handling
      def end_game
        p "Game session complete, \nShould return to game.rb"
      end

      # == Game Logic ==

      # Preview a move, display the moves indictor
      # @param curr_alg_pos [String] algebraic position
      # @return [Boolean] true if the operation is a success
      def preview_move(curr_alg_pos)
        return false unless assign_piece(curr_alg_pos)

        puts "Previewing #{active_piece.name} at #{active_piece.info}." # @todo Proper feedback
        ops_successful
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

      # Reset En Passant status when it is not used at the following turn
      def reset_en_passant
        return if en_passant.nil?

        self.en_passant = nil if active_piece.curr_pos != en_passant[1]
      end

      # == Utilities ==

      # Fetch a single chess piece
      # @param query [String, Array<Object, Symbol>] algebraic notation `"e4"` or search by piece `[Queen, :white]`
      # @return [ChessPiece]
      def fetch_piece(query)
        case query
        in String
          return puts "'#{query}' is not a valid notation." unless usable_pieces[player.side].include?(query)

          turn_data[alg_map[query.to_sym]]
        in Array
          obj, side = query
          fetch_all(side).find { |piece| piece.is_a?(obj) } # @todo add error handling
        end
      end

      # Grab all pieces, only whites or only blacks
      # @param side [Symbol] expects :all, :white or :black
      # @param type [ChessPiece, King, Queen, Rook, Bishop, Knight, Pawn] limit selection
      # @return [Array<ChessPiece>] a list of chess pieces
      def fetch_all(side = :all, type: ChessPiece)
        all_pieces = turn_data.select { |tile| tile if tile.is_a?(type) }
        return all_pieces unless %i[black white].include?(side)

        all_pieces.select { |piece| piece if piece.side == side }
      end

      private

      # == Board Logic ==

      # Actions to perform when player input is valid
      # @return [Boolean] true if the operation is a success
      def ops_successful
        update_board_state
        print_chessboard
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
        blunder_tiles(grouped_pieces)
        calculate_usable_pieces(grouped_pieces)
        any_checkmate?
      end

      # Refresh possible move and split chess pieces into two group
      # @return [Hash]
      def pieces_group
        grouped_pieces = { white: nil, black: nil }
        grouped_pieces[:white], grouped_pieces[:black] = generate_moves(:all).partition { |piece| piece.side == :white }
        grouped_pieces
      end

      # Calculate usable pieces of the given turn
      # @param grouped_pieces [Hash<ChessPiece>]
      def calculate_usable_pieces(grouped_pieces)
        grouped_pieces.each do |side, pieces|
          usable_pieces[side] = pieces.map { |piece| piece.info unless piece.possible_moves.empty? }.compact
        end
      end

      # Calculate all blunder tile for each side
      # @param grouped_pieces [Hash<ChessPiece>]
      def blunder_tiles(grouped_pieces)
        threats_map.transform_values! { |_| [] }
        grouped_pieces.each { |side, pieces| add_pos_to_blunder_tracker(side, pieces) }
      end

      # Helper: add blunder tiles to session variable
      # @param side [Symbol] expects :all, :white or :black
      # @param pieces [ChessPiece]
      def add_pos_to_blunder_tracker(side, pieces)
        bad_moves = []
        pawns, back_row = pieces.partition { |piece| piece.is_a?(Pawn) }
        pawns.each { |piece| bad_moves << piece.sights }
        back_row.each do |piece|
          bad_moves << piece.sights
          bad_moves << piece.possible_moves.compact
        end
        edit_threats_map(side, bad_moves)
      end

      # Helper: Add bad_moves to threats_map
      # @param side [Symbol] expects :all, :white or :black
      # @param bad_moves [Array]
      def edit_threats_map(side, bad_moves)
        threats_map[side] = bad_moves.flatten.sort.to_set
      end

      # End game if either side achieved a checkmate
      # @param grouped_pieces [Hash<ChessPiece>]
      def any_checkmate?
        kings.values.any?(&:checkmate?)
      end

      # == Display logic ==

      # Print the chessboard
      def print_chessboard
        chessboard = build_board(rendering_data, side: player.side, size: 1)
        print_msg(*chessboard, pre: "* ")
      end

      # Pre-process turn data before sending it to display module
      # @return [Array] 2D array respect to bound limit
      def rendering_data
        display_data = highlight_moves(turn_data.dup)
        to_matrix(display_data)
      end

      # Temporary display move indicator highlight on the board
      # @param display_data [Array<ChessPiece, String>] 1D copied of turn_data
      def highlight_moves(display_data)
        return display_data if active_piece.nil?

        highlight ||= THEME[:classic].slice(:icon, :highlight)
        active_piece.possible_moves.each { |move| display_data[move] = highlight if display_data[move].is_a?(String) }
        display_data
      end

      # User data handling
    end
  end
end
