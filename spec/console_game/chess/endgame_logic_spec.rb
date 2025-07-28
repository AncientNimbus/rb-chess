# frozen_string_literal: true

require_relative "../../../lib/nimbus_file_utils/nimbus_file_utils"
require_relative "../../../lib/console_game/chess/level"

describe ConsoleGame::Chess::EndgameLogic do
  NimbusFileUtils.set_locale("en")
  let(:controller) { ConsoleGame::Chess::ChessInput.new }
  let(:session) { { event: "Integration test", site: "Level and Endgame logic", date: nil, round: nil, white: "Ancient", black: "Nimbus", result: nil, mode: 1, moves: {}, fens: [] } }
  let(:sides) { { white: ConsoleGame::Chess::ChessPlayer.new("Ancient", controller, :white), black: ConsoleGame::Chess::ChessPlayer.new("Nimbus", controller, :black) } }

  describe "#any_checkmate?" do
    context "when imported FEN session will result in black being checkmate" do
      subject(:fen_str) { "rnbqkbnr/ppppp2p/5p2/6pQ/8/4P3/PPPP1PPP/RNB1KBNR b KQkq - 1 1" }

      let(:level) { ConsoleGame::Chess::Level.new(controller, sides, session, fen_str) }

      it "returns true if black is checkmated" do
        allow($stdout).to receive(:puts)
        level.send(:init_level)
        result = level.send(:game_end_check)
        expect(result).to be true
      end
    end

    context "when imported FEN session will result in white being checkmate" do
      subject(:fen_str) { "rnb1kbnr/pppppppp/8/8/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 0 1" }

      let(:level) { ConsoleGame::Chess::Level.new(controller, sides, session, fen_str) }

      it "returns true if white is checkmated" do
        allow($stdout).to receive(:puts)
        level.send(:init_level)
        result = level.send(:game_end_check)
        expect(result).to be true
      end
    end

    context "when imported FEN session will result in white being checkmate 2" do
      subject(:fen_str) { "2k5/1p3p1p/2p5/P6p/4pbnP/2Nb1p2/5nK1/3r4 w - - 1 31" }

      let(:level) { ConsoleGame::Chess::Level.new(controller, sides, session, fen_str) }

      it "returns true if white is checkmated" do
        allow($stdout).to receive(:puts)
        level.send(:init_level)
        result = level.send(:game_end_check)
        expect(result).to be true
      end
    end

    context "when imported FEN session is a new game" do
      subject(:fen_str) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }

      let(:sides) { { white: ConsoleGame::Chess::ChessComputer.new("Ancient", controller, :white), black: ConsoleGame::Chess::ChessPlayer.new("Nimbus", controller, :black) } }
      let(:level) { ConsoleGame::Chess::Level.new(controller, sides, session, fen_str) }

      it "returns false" do
        allow(level.controller).to receive(:save)
        allow($stdout).to receive(:puts)
        level.send(:init_level)
        result = level.send(:game_end_check)
        expect(result).to be false
      end
    end
  end

  describe "#stalemate?" do
    context "when imported FEN session will result in stalemate draw" do
      subject(:fen_str) { "7k/5K2/6Q1/8/8/8/8/8 b - - 1 1" }

      let(:level) { ConsoleGame::Chess::Level.new(controller, sides, session, fen_str) }

      it "returns true if the game is a draw" do
        allow($stdout).to receive(:puts)
        level.send(:init_level)
        result = level.send(:game_end_check)
        expect(result).to be true
      end
    end
  end

  describe "#insufficient_material?" do
    context "when imported FEN session will result in an insufficient material draw" do
      subject(:fen_str) { "5K2/2B5/7k/4b3/8/8/8/8 b - - 0 1" }

      let(:level) { ConsoleGame::Chess::Level.new(controller, sides, session, fen_str) }

      it "returns true if the game is a draw" do
        allow($stdout).to receive(:puts)
        level.send(:init_level)
        result = level.send(:game_end_check)
        expect(result).to be true
      end
    end
  end

  describe "#threefold_repetition?" do
    context "when imported FEN session will result in an insufficient material draw" do
      subject(:fen_str) { "rnbqkbr1/p3pppp/1p5n/2pp4/P3PPPP/2P5/1P1P4/RNBQKBNR b KQq - 0 6" }

      let(:level) { ConsoleGame::Chess::Level.new(controller, sides, session, fen_str) }
      let(:fens) do
        [
          "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1",
          "rnbqkb1r/pppppppp/7n/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 1 1",
          "rnbqkb1r/pppppppp/7n/8/4PP2/8/PPPP2PP/RNBQKBNR b KQkq - 0 2",
          "rnbqkb1r/pp1ppppp/7n/2p5/4PP2/8/PPPP2PP/RNBQKBNR w KQkq - 0 2",
          "rnbqkb1r/pp1ppppp/7n/2p5/4PPP1/8/PPPP3P/RNBQKBNR b KQkq - 0 3",
          "rnbqkb1r/p2ppppp/1p5n/2p5/4PPP1/8/PPPP3P/RNBQKBNR w KQkq - 0 3",
          "rnbqkbr1/p3pppp/1p5n/2pp4/P3PPPP/2P5/1P1P4/RNBQKBNR b KQq - 0 6",
          "rnbqkb1r/p2ppppp/1p5n/2p5/4PPPP/8/PPPP4/RNBQKBNR b KQkq - 0 4",
          "rnbqkbr1/p2ppppp/1p5n/2p5/4PPPP/8/PPPP4/RNBQKBNR w KQq - 1 4",
          "rnbqkbr1/p3pppp/1p5n/2pp4/P3PPPP/2P5/1P1P4/RNBQKBNR b KQq - 0 6",
          "rnbqkbr1/p2ppppp/1p5n/2p5/4PPPP/8/PPPP4/RNBQKBNR w KQq - 1 5",
          "rnbqkbr1/p2ppppp/1p5n/2p5/4PPPP/2P5/PP1P4/RNBQKBNR b KQq - 0 5",
          "rnbqkbr1/p3pppp/1p5n/2pp4/4PPPP/2P5/PP1P4/RNBQKBNR w KQq - 0 5",
          "rnbqkbr1/p3pppp/1p5n/2pp4/4PPPP/2P5/PP1P4/RNBQKBNR w KQq - 0 6",
          "rnbqkbr1/p3pppp/1p5n/2pp4/P3PPPP/2P5/1P1P4/RNBQKBNR b KQq - 0 6"
        ]
      end

      it "returns true if the game is a draw" do
        allow($stdout).to receive(:puts)
        session[:fens] = fens
        level.send(:init_level)
        result = level.send(:game_end_check)
        expect(result).to be true
      end
    end
  end
end
