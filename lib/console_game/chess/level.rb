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

      attr_accessor :turn_data, :active_piece, :previous_piece, :en_passant
      attr_reader :mode, :controller, :w_player, :b_player, :sessions, :castling_states, :threats_map, :checked_status

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
        @checked_status = { king: nil, attackers: [] }
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

        assign_piece("g5")
        # assign_piece("g8")
        p active_piece.query_moves

        # active_piece.move(:g1)
        blunder_tiles
        print_chessboard
        p "checkmate?: #{checkmate?}"
        # blunder_tiles
        # p "checkmate?: #{checkmate?}"
        # threats_map[:black].each { |pos| p alg_map.key(pos) if alg_map.key(pos) == :f2 }
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

        opposite_side = opposite_of(king_in_distress.side)
        # p "king_in_distress.possible_moves: #{king_in_distress.possible_moves}"
        # p "threats_map[king_in_distress.side]: #{threats_map[king_in_distress.side]}"
        # p "threats_map[opposite_side]: #{threats_map[opposite_side]}"
        # Detect if the check can be neutralise by other piece
        checked_status[:attackers].each do |attacker|
          next unless !under_attack?(attacker) && no_escape_route?(king_in_distress, opposite_side)

          # Check if there are any friendlies that can blocked the path
          any_saviours = fetch_all(king_in_distress.side).any? do |piece|
            !(piece.possible_moves & attacker.possible_moves).empty?
          end
          return false if any_saviours
        end
        true
      end

      # Determine if the King can escape
      # @param king_in_distress [King] expects a King object
      # @param offensive_side [Symbol] expects :white or :black
      # @return [Boolean] true if the King can escape
      def no_escape_route?(king_in_distress, offensive_side)
        (king_in_distress.possible_moves - threats_map[offensive_side]).empty? # empty means no escape route
      end

      # Determine if the King is in check
      # @param king [King] expects a King object
      # @return [Boolean] true if the king is in check
      def in_check?(king = fetch_piece([King, :white]))
        return false unless king.is_a?(King)

        is_checked = under_attack?(king)

        if is_checked
          checked_status[:king] = king
          find_checking_pieces(king)
          puts "#{king.side} #{king.name} is checked by #{checked_status[:attackers].map(&:info).join(', ')}."
        end

        is_checked
      end

      # Find the pieces that is checking the King
      # @param king_in_distress [King] expects a King object
      # @return [nil, ChessPiece, Array<ChessPiece>]
      def find_checking_pieces(king_in_distress)
        return checked_status[:attackers] << previous_piece if attacking?(previous_piece, king_in_distress)

        fetch_all(opposite_of(king_in_distress.side)).select do |piece|
          checked_status[:attackers] << piece if piece.targets.value?(king_in_distress.curr_pos)
        end
      end

      # Determine if a certain piece is attacking another piece
      # @param attacker [ChessPiece] expects a chess piece from the offensive side
      # @param target [ChessPiece] expects a chess piece from the opposite side
      # @return [Boolean] true if it can attack
      def attacking?(attacker, target)
        return false if attacker.side == target.side

        true if attacker.targets.value?(target.curr_pos)
      end

      # Determine if a piece might get attacked
      # @param piece [ChessPiece]
      # @return [Boolean]
      def under_attack?(piece)
        opposite_side = opposite_of(piece.side)
        threats_map[opposite_side].include?(piece.curr_pos)
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
