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

      attr_accessor :turn, :turn_data, :active_piece, :previous_piece, :en_passant
      attr_reader :mode, :controller, :w_player, :b_player, :sessions, :kings, :castling_states, :threats_map,
                  :usable_pieces

      def initialize(mode, input, sides, sessions, import_fen = nil)
        @mode = mode
        @controller = input
        @w_player = sides[:white]
        @b_player = sides[:black]
        @session = sessions
        @turn = :white
        @turn_data = import_fen.nil? ? parse_fen(self) : parse_fen(self, import_fen)
        @en_passant = nil
        @castling_states = { K: nil, Q: nil, k: nil, q: nil }
        @threats_map = { white: [], black: [] }
        @kings = { white: nil, black: nil }
        @usable_pieces = { white: [], black: [] }
      end

      # == Flow ==

      # Start level
      def open_level
        p "Setting up game level"
        init_level
      end

      # Initialise the chessboard
      def init_level
        kings_table
        # p kings[:white].side
        update_board_state
        p usable_pieces
        print_chessboard

        # assign_piece("h1")
        assign_piece("g5")

        active_piece.move(:g1)
        update_board_state
        print_chessboard
        p usable_pieces
        # p active_piece.query_moves
        # assign_piece("g8")

        p "checkmate: #{any_checkmate?}"
      end

      # Game loop
      def game_loop; end

      # Endgame handling

      # == Board Logic ==

      # Reset En Passant status when it is not used at the following turn
      def reset_en_passant
        return if en_passant.nil?

        self.en_passant = nil if active_piece.curr_pos != en_passant[1]
      end

      # Handling piece assignment
      # @param alg_pos [String] algebraic notation
      def assign_piece(alg_pos)
        # add player side validation
        piece = fetch_piece(alg_pos)
        return if piece.nil?

        p "active piece: #{piece.side} #{piece.name}"
        @previous_piece = active_piece
        @active_piece = piece
        self.previous_piece ||= active_piece
      end

      # Print the chessboard
      def print_chessboard
        chessboard = build_board(to_matrix(turn_data), size: 1)
        print_msg(*chessboard, pre: "* ")
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

      # Get and store both Kings
      def kings_table
        fetch_all(type: King).each { |king| kings[king.side] = king }
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
        threats_map[side] = bad_moves.flatten.sort.to_set
      end

      # End game if either side achieved a checkmate
      # @param grouped_pieces [Hash<ChessPiece>]
      def any_checkmate?
        kings.values.any?(&:checkmate?)
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

      # == Utilities ==

      private

      # Fetch a single chess piece
      # @param query [String, Array<Object, Symbol>] algebraic notation `"e4"` or search by piece `[Queen, :white]`
      # @return [ChessPiece]
      def fetch_piece(query)
        if query.is_a?(String) && usable_pieces[turn].include?(query)
          piece = turn_data[alg_map[query.to_sym]]
        elsif query.is_a?(Array)
          obj, side = query
          piece = fetch_all(side).find { |piece| piece.is_a?(obj) }
          # @todo add error handling
        else
          return puts "'#{query}' is invalid, please enter a correct notation"
        end
        piece
      end

      # Update turn data
      # Update chessboard display
      # User data handling
    end
  end
end
