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

      attr_accessor :turn_data, :active_piece, :previous_piece, :en_passant, :threats_map
      attr_reader :mode, :controller, :w_player, :b_player, :sessions, :castling_states

      def initialize(mode, input, side, sessions, import_fen = nil)
        @mode = mode
        @controller = input
        @w_player = side[:white]
        @b_player = side[:black]
        @session = sessions
        @turn_data = import_fen.nil? ? parse_fen(self) : parse_fen(self, import_fen)
        @en_passant = nil
        @castling_states = { K: nil, Q: nil, k: nil, q: nil }
        @threats_map = { white: [], black: [] }
      end

      # == Flow ==

      # Start level
      def open_level
        p "Setting up game level"
        init_level
      end

      # Initialise the chessboard
      def init_level
        print_chessboard

        assign_piece("g8")
        p active_piece.query_moves
        blunder_tiles
        p checkmate?

        active_piece.move(:g1)
        print_chessboard
        blunder_tiles
        p checkmate?
        threats_map[:black].each { |pos| p alg_map.key(pos) if alg_map.key(pos) == :f2 }

        # assign_piece("a1")
        # assign_piece("h7")
        # assign_piece("f2")
        # puts "Previous piece is #{previous_piece.side.capitalize} #{previous_piece.name}"
      end

      # Game loop
      def game_loop; end

      # Endgame handling

      # == Utilities ==

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

      # Determine if the King is in a checkmate position
      # @param king_in_distress [King] expects a King object
      # @return [Boolean] true if it is a checkmate
      def checkmate?(king_in_distress = fetch_piece([King, :white]))
        return false unless in_check?(king_in_distress)

        opposite_side = king_in_distress.side == :white ? :black : :white
        # p "king_in_distress.possible_moves: #{king_in_distress.possible_moves}"
        # p "threats_map[king_in_distress.side]: #{threats_map[king_in_distress.side]}"
        # p "threats_map[opposite_side]: #{threats_map[opposite_side]}"
        # find out which piece is checking the King, solved with var: previous_piece
        # Add a check to see if the immediate check can be neutralise by other piece
        return false if threats_map[king_in_distress.side].include?(previous_piece.curr_pos)

        (king_in_distress.possible_moves - threats_map[opposite_side]).empty? # No safe square for King to go
      end

      # Determine if the King is in check
      # @param king [King] expects a King object
      # @return [Boolean] true if the king is in check
      def in_check?(king = fetch_piece([King, :white]))
        return unless king.is_a?(King)

        opposite_side = king.side == :white ? :black : :white
        is_checked = threats_map[opposite_side].include?(king.curr_pos)
        puts "#{king.side.capitalize} #{king.name} is checked by #{previous_piece.side.capitalize} #{previous_piece.name}."
        is_checked
      end

      # Calculate all blunder tile for each side
      def blunder_tiles
        threats_map.transform_values! { |_| [] }
        grouped_pieces = { white: nil, black: nil }
        grouped_pieces[:white], grouped_pieces[:black] = generate_moves(:all).partition { |piece| piece.side == :white }
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

      # Grab all pieces, only whites or only blacks
      # @param side [Symbol] expects :all, :white or :black
      # @return [Array<ChessPiece>] a list of chess pieces
      def fetch_all(side = :all)
        all_pieces = turn_data.select { |tile| tile if tile.is_a?(ChessPiece) }
        return all_pieces unless %i[black white].include?(side)

        all_pieces.select { |piece| piece if piece.side == side }
      end

      # Fetch a single chess piece
      # @param query [String, Array<Object, Symbol>] algebraic notation `"e4"` or search by piece `[Queen, :white]`
      # @return [ChessPiece]
      def fetch_piece(query)
        if query.is_a?(String)
          piece = turn_data[alg_map[query.to_sym]]
          return puts "'#{query}' is empty, please enter a correct notation" if piece == ""
        elsif query.is_a?(Array)
          obj, side = query
          piece = fetch_all(side).find { |piece| piece.is_a?(obj) }
          # @todo add error handling
        end
        piece
      end

      # Update turn data
      # Update chessboard display

      # User data handling
    end
  end
end
