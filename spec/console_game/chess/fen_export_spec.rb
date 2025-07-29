# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/utilities/fen_import"
require_relative "../../../lib/console_game/chess/utilities/fen_export"
require_relative "../../../lib/console_game/chess/level"

describe ConsoleGame::Chess::FenExport do
  subject(:fen_import) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::FenImport } }
  let(:level_double) { instance_double(ConsoleGame::Chess::Level) }

  describe "#to_fen" do
    subject(:fen_export) { described_class.new(level_double) }

    context "when a value is a valid internal array of a new chess session" do
      let(:session_data) { fen_import.parse_fen(nil) }

      before do
        turn_data, white_turn, castling_states, en_passant, half_move, full_move =
          session_data.values_at(:turn_data, :white_turn, :castling_states, :en_passant, :half, :full)
        allow(level_double).to receive_messages(
          fen_data: session_data, turn_data:, white_turn:, castling_states:, en_passant:, half_move:, full_move:
        )
      end

      it "returns a position placements of a new game in FEN format" do
        result = fen_export.to_fen
        expect(result).to eq("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
      end
    end

    context "when a value is a valid internal array of an ongoing chess session" do
      subject(:fen_data) { "r1b1kbnr/pp4pp/3p1p2/n2Pp3/1Q6/6q1/PPP1PPPP/RNB1KBNR w KQkq e6 0 1" }

      let(:session_data) { fen_import.parse_fen(level_double, fen_data) }

      before do
        turn_data, white_turn, castling_states, en_passant, half_move, full_move =
          session_data.values_at(:turn_data, :white_turn, :castling_states, :en_passant, :half, :full)
        allow(level_double).to receive_messages(
          fen_data: session_data, turn_data:, white_turn:, castling_states:, en_passant:, half_move:, full_move:
        )
      end

      it "returns a position placements of an ongoing game in FEN format" do
        result = fen_export.to_fen
        expect(result).to eq("r1b1kbnr/pp4pp/3p1p2/n2Pp3/1Q6/6q1/PPP1PPPP/RNB1KBNR w KQkq e6 0 1")
      end
    end
  end
end
