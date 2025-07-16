# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/utilities/fen_import"
require_relative "../../../lib/console_game/chess/utilities/fen_export"
require_relative "../../../lib/console_game/chess/level"

describe ConsoleGame::Chess::FenExport do
  subject(:fen_export_test) { dummy_class.new }

  let(:dummy_class) do
    Class.new do
      include ConsoleGame::Chess::FenImport
      include ConsoleGame::Chess::FenExport
    end
  end

  describe "#to_fen" do
    let(:level_double) { instance_double(ConsoleGame::Chess::Level) }

    context "when a value is a valid internal array of a new chess session" do
      let(:session_data) { fen_export_test.parse_fen(level_double) }

      it "returns a position placements of a new game in FEN format" do
        result = fen_export_test.send(:to_fen, session_data)
        expect(result).to eq("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
      end
    end

    context "when a value is a valid internal array of an ongoing chess session" do
      subject(:fen_data) { "r1b1kbnr/pp4pp/3p1p2/n2Pp3/1Q6/6q1/PPP1PPPP/RNB1KBNR w KQkq e6 0 1" }

      let(:session_data) { fen_export_test.parse_fen(level_double, fen_data) }

      it "returns a position placements of an ongoing game in FEN format" do
        result = fen_export_test.send(:to_fen, session_data)
        expect(result).to eq("r1b1kbnr/pp4pp/3p1p2/n2Pp3/1Q6/6q1/PPP1PPPP/RNB1KBNR w KQkq e6 0 1")
      end
    end
  end

  describe "#to_turn_data" do
    let(:level_double) { instance_double(ConsoleGame::Chess::Level) }

    context "when a value is a valid internal array of a new chess session" do
      let(:turn_data) { fen_export_test.parse_fen(level_double)[:turn_data] }

      it "returns a position placements of a new game in FEN format" do
        result = fen_export_test.send(:to_turn_data, turn_data)
        expect(result).to eq("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
      end
    end

    context "when a value is a valid internal array of an ongoing chess session" do
      subject(:fen_data) { "r5rk/ppp4p/3p4/2b2Q2/3pPP2/2P2n2/PP3P1R/RNB4K b - - 0 18" }

      let(:turn_data) { fen_export_test.parse_fen(level_double, fen_data)[:turn_data] }

      it "returns a position placements of an ongoing game in FEN format" do
        result = fen_export_test.send(:to_turn_data, turn_data)
        expect(result).to eq("r5rk/ppp4p/3p4/2b2Q2/3pPP2/2P2n2/PP3P1R/RNB4K")
      end
    end

    context "when a value is a valid internal array of an ongoing chess session where white king is in checked" do
      subject(:fen_data) { "rn2k1nr/p1p1pppp/1b5b/3p3P/1p3P2/3BP1N1/PPP2qPQ/R3K1R1 w Qkq - 0 1" }

      let(:turn_data) { fen_export_test.parse_fen(level_double, fen_data)[:turn_data] }

      it "returns a position placements of an ongoing game in FEN format" do
        result = fen_export_test.send(:to_turn_data, turn_data)
        expect(result).to eq("rn2k1nr/p1p1pppp/1b5b/3p3P/1p3P2/3BP1N1/PPP2qPQ/R3K1R1")
      end
    end
  end
end
