# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/utilities/pgn_export"

describe ConsoleGame::Chess::PgnExport do
  describe "#export_session" do
    context "when session is a valid internal game session hash" do
      subject(:pgn_export) { described_class.export_session(session) }

      let(:session) { { event: "Dummy User vs Player 2", site: "Ruby Arcade Terminal Chess by Ancient Nimbus", date: "08/01/2025 09:17 AM", round: nil, white: "Dummy User", black: "Player 2", result: nil, mode: 1, moves: { 1 => %w[e4 e5], 2 => %w[d3 d6], 3 => %w[f3 b5], 4 => %w[g3 a6], 5 => %w[h3 Ra7], 6 => %w[h4 a5], 7 => %w[Nh3 Ra6], 8 => %w[g4 c5], 9 => %w[Be2 Be7], 10 => %w[d4 cxd4], 11 => %w[h5 a4], 12 => %w[b4 d3], 13 => %w[O-O Kf8], 14 => %w[Kh1 d2], 15 => ["Kg1", "dxc1=Q"], 16 => ["Rf2", "Qcxd1+"] }, white_moves: %w[e4 d3 f3 g3 h3 h4 Nh3 g4 Be2 d4 h5 b4 O-O Kh1 Kg1 Rf2 Rf1], black_moves: ["e5", "d6", "b5", "a6", "Ra7", "a5", "Ra6", "c5", "Be7", "cxd4", "a4", "d3", "Kf8", "d2", "dxc1=Q", "Qcxd1+"], fens: ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1", "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2", "rnbqkbnr/pppp1ppp/8/4p3/4P3/3P4/PPP2PPP/RNBQKBNR b KQkq - 0 2", "rnbqkbnr/ppp2ppp/3p4/4p3/4P3/3P4/PPP2PPP/RNBQKBNR w KQkq - 0 3", "rnbqkbnr/ppp2ppp/3p4/4p3/4P3/3P1P2/PPP3PP/RNBQKBNR b KQkq - 0 3", "rnbqkbnr/p1p2ppp/3p4/1p2p3/4P3/3P1P2/PPP3PP/RNBQKBNR w KQkq - 0 4", "rnbqkbnr/p1p2ppp/3p4/1p2p3/4P3/3P1PP1/PPP4P/RNBQKBNR b KQkq - 0 4", "rnbqkbnr/2p2ppp/p2p4/1p2p3/4P3/3P1PP1/PPP4P/RNBQKBNR w KQkq - 0 5", "rnbqkbnr/2p2ppp/p2p4/1p2p3/4P3/3P1PPP/PPP5/RNBQKBNR b KQkq - 0 5", "1nbqkbnr/r1p2ppp/p2p4/1p2p3/4P3/3P1PPP/PPP5/RNBQKBNR w KQk - 1 6", "1nbqkbnr/r1p2ppp/p2p4/1p2p3/4P2P/3P1PP1/PPP5/RNBQKBNR b KQk - 0 6", "1nbqkbnr/r1p2ppp/3p4/pp2p3/4P2P/3P1PP1/PPP5/RNBQKBNR w KQk - 0 7", "1nbqkbnr/r1p2ppp/3p4/pp2p3/4P2P/3P1PPN/PPP5/RNBQKB1R b KQk - 1 7", "1nbqkbnr/2p2ppp/r2p4/pp2p3/4P2P/3P1PPN/PPP5/RNBQKB1R w KQk - 2 8", "1nbqkbnr/2p2ppp/r2p4/pp2p3/4P1PP/3P1P1N/PPP5/RNBQKB1R b KQk - 0 8", "1nbqkbnr/5ppp/r2p4/ppp1p3/4P1PP/3P1P1N/PPP5/RNBQKB1R w KQk - 0 9", "1nbqkbnr/5ppp/r2p4/ppp1p3/4P1PP/3P1P1N/PPP1B3/RNBQK2R b KQk - 1 9", "1nbqk1nr/4bppp/r2p4/ppp1p3/4P1PP/3P1P1N/PPP1B3/RNBQK2R w KQk - 2 10", "1nbqk1nr/4bppp/r2p4/ppp1p3/3PP1PP/5P1N/PPP1B3/RNBQK2R b KQk - 0 10", "1nbqk1nr/4bppp/r2p4/pp2p3/3pP1PP/5P1N/PPP1B3/RNBQK2R w KQk - 0 11", "1nbqk1nr/4bppp/r2p4/pp2p2P/3pP1P1/5P1N/PPP1B3/RNBQK2R b KQk - 0 11", "1nbqk1nr/4bppp/r2p4/1p2p2P/p2pP1P1/5P1N/PPP1B3/RNBQK2R w KQk - 0 12", "1nbqk1nr/4bppp/r2p4/1p2p2P/pP1pP1P1/5P1N/P1P1B3/RNBQK2R b KQk b3 0 12", "1nbqk1nr/4bppp/r2p4/1p2p2P/pP2P1P1/3p1P1N/P1P1B3/RNBQK2R w KQk - 0 13", "1nbqk1nr/4bppp/r2p4/1p2p2P/pP2P1P1/3p1P1N/P1P1B3/RNBQ1RK1 b k - 1 13", "1nbq1knr/4bppp/r2p4/1p2p2P/pP2P1P1/3p1P1N/P1P1B3/RNBQ1RK1 w - - 2 14", "1nbq1knr/4bppp/r2p4/1p2p2P/pP2P1P1/3p1P1N/P1P1B3/RNBQ1R1K b - - 3 14", "1nbq1knr/4bppp/r2p4/1p2p2P/pP2P1P1/5P1N/P1PpB3/RNBQ1R1K w - - 0 15", "1nbq1knr/4bppp/r2p4/1p2p2P/pP2P1P1/5P1N/P1PpB3/RNBQ1RK1 b - - 1 15", "1nbq1knr/4bppp/r2p4/1p2p2P/pP2P1P1/5P1N/P1P1B3/RNqQ1RK1 w - - 0 16", "1nbq1knr/4bppp/r2p4/1p2p2P/pP2P1P1/5P1N/P1P1BR2/RNqQ2K1 b - - 1 16", "1nbq1knr/4bppp/r2p4/1p2p2P/pP2P1P1/5P1N/P1P1BR2/RN1q2K1 w - - 2 17", "1nbq1knr/4bppp/r2p4/1p2p2P/pP2P1P1/5P1N/P1P1B3/RN1q1RK1 b - - 3 17"] } }
      let(:export_data) do
        { path: "/Users/ramen/repos/rb-chess/user_data/pgn_export/dummy_user_vs_tester_2025_08_01.pgn", filename: "dummy_user_vs_tester_2025_08_01.pgn", export_data: "[Event \"Dummy User vs Tester\"]\n[Site \"Ruby Arcade Terminal Chess by Ancient Nimbus\"]\n[Date \"2025.08.01\"]\n[Round \"\"]\n[White \"Dummy User\"]\n[Black \"Tester\"]\n[Result \"\"]\n\n1. e4 e5 2. d3 d6 3. f3 b5 4. g3 a6 5. h3 Ra7 6. h4 a5 7. Nh3 Ra6 8. g4 c5\n9. Be2 Be7 10. d4 cxd4 11. h5 a4 12. b4 d3 13. O-O Kf8 14. Kh1 d2 15. Kg1 dxc1=Q 16. Rf2 Qcxd1+\n" }
      end
      let!(:result) { export_data }

      after do
        File.delete(result[:path]) if result && File.exist?(result[:path])
      end

      it "returns a data hash containing three keys: path, filename and export_data" do
        expect(result.keys).to eq(%i[path filename export_data])
      end

      it "returns a data hash" do
        expect(result).to eq(export_data)
      end
    end
  end
end
