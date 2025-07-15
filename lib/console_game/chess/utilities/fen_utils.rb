# frozen_string_literal: true

module ConsoleGame
  module Chess
    # FenUtils is a helper module to perform FEN data parsing operations.
    # It is compatible with most online chess site, and machine readable.
    # @author Ancient Nimbus
    # @version v1.0.0
    module FenUtils
      # FEN default values
      FEN = {
        w_start: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
        k: { class: "King", notation: :k }, q: { class: "Queen", notation: :q }, r: { class: "Rook", notation: :r },
        b: { class: "Bishop", notation: :b }, n: { class: "Knight", notation: :n }, p: { class: "Pawn", notation: :p }
      }.freeze

      # FEN Raw data parser
      # @param level [Chess::Level] Chess level object
      # @param fen_str [String] expects a string in FEN format
      def parse_fen(level, fen_str = FEN[:w_start])
        fen = fen_str.split
        return fen_error(fen_str) if fen.size != 6

        fen_board, turn, c_state, ep_state, halfmove, fullmove = fen
        castling_states = parse_castling_str(c_state)
        turn_state = parse_active_color(turn)
        turn_data = parse_piece_placement(fen_board, level)
      end

      private

      # Process flow when there is an issue during FEN parsing
      # @param fen_str [String] expects a string in FEN format
      def fen_error(fen_str)
        puts "FEN error, operation cancelled. #{fen_str}" # @todo: Replace with TF
      end

      # Process FEN board data field
      # @param fen_board [String] expects an Array with FEN positions data
      # @param level [Chess::Level] Chess level object
      # @return [Array<ChessPiece, String>, nil] chess position data starts from a1..h8
      def parse_piece_placement(fen_board, level)
        turn_data = Array.new(8) { [] }
        pos_value = 0
        fen_board.split("/").reverse.each_with_index do |rank, row|
          return nil unless rank.match?(/\A[kqrbnp1-8]+\z/i)

          normalise_fen_rank(rank).each_with_index do |unit, col|
            turn_data[row][col] = /\A\d\z/.match?(unit) ? "" : piece_maker(pos_value, unit, level)
            pos_value += 1
          end
        end
        turn_data.flatten
      end

      # Process FEN active color field
      # @param active_color [String] expects a string with active color data
      # @return [Hash, nil] a hash containing data that indicates whether it is white's turn
      def parse_active_color(active_color)
        return nil unless %w[b w].include?(active_color)

        white_turn = active_color == "w"
        { white_turn: white_turn }
      end

      # Process FEN castling field
      # @param c_state [String] expects a string with castling data
      # @return [Hash, nil] a hash of castling statuses
      def parse_castling_str(c_state)
        castling_states = { K: false, Q: false, k: false, q: false }
        return castling_states if c_state.empty?

        c_state.split("").each do |char|
          char_as_sym = char.to_sym
          return nil unless castling_states.key?(char_as_sym)

          castling_states[char_as_sym] = true
        end
        castling_states
      end

      # Process FEN En-passant target square field
      # @param ep_state [String] expects a string with En-passant target square data
      # @return [Hash, nil] a hash of En-passant status
      def parse_en_passant(ep_state)
        return nil unless ep_state.match?(/\A[a-h][36]|-\z/)

        { en_passant: ep_state == "-" ? nil : ep_state }
      end

      # Initialize chess piece via string value
      # @param pos [Integer] positional value
      # @param fen_notation [String] expects a single letter that follows the FEN standard
      # @param level [Chess::Level] Chess level object
      # @return [Chess::King, Chess::Queen, Chess::Bishop, Chess::Rook, Chess::Knight, Chess::Pawn]
      def piece_maker(pos, fen_notation, level)
        side = fen_notation == fen_notation.capitalize ? :white : :black
        class_name = FEN[fen_notation.downcase.to_sym][:class]
        Chess.const_get(class_name).new(pos, side, level: level)
      end

      # Helper method to uncompress FEN empty cell values so that all arrays share the same size
      # @param fen_rank_str [String]
      # @return [Array] processed rank data array
      def normalise_fen_rank(fen_rank_str)
        fen_rank_str.split("").map { |elem| elem.sub(/\A\d\z/, "0" * elem.to_i).split("") }.flatten
      end
    end
  end
end
