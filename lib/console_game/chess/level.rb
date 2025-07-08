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
      attr_reader :mode, :controller, :w_player, :b_player, :sessions, :castling_states, :threats_map, :checked_status,
                  :usable_pieces

      def initialize(mode, input, side, sessions, import_fen = nil)
        @mode = mode
        @controller = input
        @w_player = side[:white]
        @b_player = side[:black]
        @turn = :white
        @session = sessions
        @turn_data = import_fen.nil? ? parse_fen(self) : parse_fen(self, import_fen)
        @en_passant = nil
        @castling_states = { K: nil, Q: nil, k: nil, q: nil }
        @threats_map = { white: [], black: [] }
        @checked_status = { king: nil, attackers: [], saviours: [] }
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
        update_board_state
        p usable_pieces
        print_chessboard

        assign_piece("h1")
        assign_piece("g1")

        # p active_piece.query_moves
        # assign_piece("g8")

        # active_piece.move(:g1)
        # print_chessboard

        p "checkmate?: #{checkmate?}"
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

      # Determine if the King is in a checkmate position
      # @param king_in_distress [King] expects a King object
      # @return [Boolean] true if it is a checkmate
      def checkmate?(king_in_distress = fetch_piece([King, :white]))
        return false unless in_check?(king_in_distress)

        allies = fetch_all(king_in_distress.side).select { |ally| ally unless ally.is_a?(King) }
        checked_status[:attackers].each do |attacker|
          return false if under_threat_by?(allies, attacker)
          return false if any_saviours?(allies, attacker, king_in_distress)
        end
        no_escape_route?(king_in_distress)
      end

      # Determine if there are no escape route for the King
      # @param king_in_distress [King] expects a King object
      # @return [Boolean] true if King cannot escape
      def no_escape_route?(king_in_distress)
        (king_in_distress.possible_moves - threats_map[opposite_of(king_in_distress.side)]).empty?
      end

      # Determine if there are any saviour
      # @param king_allies [Array<ChessPiece>] expects an array of King's army
      # @param attacker [ChessPiece]
      # @param king [King]
      # @return [Boolean] true if someone can come save the King
      def any_saviours?(king_allies, attacker, king)
        attacker_dir = attacker.targets.key(king.curr_pos)
        attack_path = pathfinder(attacker.curr_pos, attacker_dir, length: attacker.movements[attacker_dir])
        saviours = usable_pieces[king.side] = king_allies.map do |ally|
          ally.info unless (ally.possible_moves & attack_path).empty?
        end.compact
        !saviours.empty?
      end

      # Determine if the King is in check
      # @param king [King] expects a King object
      # @return [Boolean] true if the king is in check
      def in_check?(king = fetch_piece([King, :white]))
        return false unless king.is_a?(King)

        checked_status.transform_values! { |_| [] }

        is_checked = under_threat?(king)
        checked_event(king) if is_checked
        is_checked
      end

      # Process the checked event
      # @param king [King]
      def checked_event(king)
        checked_status[:king] = king
        find_checking_pieces(king)
        puts "#{king.side} #{king.name} is checked by #{checked_status[:attackers].map(&:info).join(', ')}."
      end

      # Find the pieces that is checking the King
      # @param king_in_distress [King] expects a King object
      # @return [nil, ChessPiece, Array<ChessPiece>]
      def find_checking_pieces(king_in_distress)
        # return checked_status[:attackers] << previous_piece if attacking?(previous_piece, king_in_distress)

        fetch_all(opposite_of(king_in_distress.side)).select do |piece|
          checked_status[:attackers] << piece if piece.targets.value?(king_in_distress.curr_pos)
        end
      end

      # Determine if a piece is currently under threats
      # #param piece [ChessPiece]
      def under_threat?(piece)
        opposite_side = opposite_of(piece.side)
        threats_map[opposite_side].include?(piece.curr_pos)
      end

      # Determine if a piece might get attacked by multiple pieces, similar to #under_threat? but more specific
      # @param threat_side [Array<ChessPiece>]
      # @param target [ChessPiece]
      # @return [Boolean]
      def under_threat_by?(threat_side, target)
        threat_side.any? { |piece| piece.targets.value?(target.curr_pos) }
      end

      # Determine if a certain piece is attacking another piece
      # @param attacker [ChessPiece] expects a chess piece from the offensive side
      # @param target [ChessPiece] expects a chess piece from the opposite side
      # @return [Boolean] true if it can attack
      def attacking?(attacker, target)
        return false if attacker.side == target.side

        true if attacker.targets.value?(target.curr_pos)
      end

      # Board state refresher
      def update_board_state
        grouped_pieces = pieces_group
        blunder_tiles(grouped_pieces)
        calculate_usable_pieces(grouped_pieces)
        checkmate?
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

      # == Utilities ==

      # Update turn data
      # Update chessboard display
      # User data handling
    end
  end
end
