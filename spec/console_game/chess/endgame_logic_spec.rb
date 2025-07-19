# frozen_string_literal: true

# require_relative "../../../lib/console_game/chess/logics/endgame_logic"
require_relative "../../../lib/console_game/chess/level"

describe ConsoleGame::Chess::EndgameLogic do
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
        result = level.any_checkmate?(level.kings)
        expect(result).to be true
      end
    end

    context "when imported FEN session will result in white being checkmate" do
      subject(:fen_str) { "rnb1kbnr/pppppppp/8/8/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 0 1" }

      let(:level) { ConsoleGame::Chess::Level.new(controller, sides, session, fen_str) }

      it "returns true if white is checkmated" do
        allow($stdout).to receive(:puts)
        level.send(:init_level)
        result = level.any_checkmate?(level.kings)
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
        result = level.any_checkmate?(level.kings)
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
        result = level.stalemate?(level.player.side, level.usable_pieces, level.threats_map)
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
        remaining_pieces, remaining_notations = level.send(:insufficient_material_qualifier, level.usable_pieces.values)
        result = level.insufficient_material?(remaining_pieces, remaining_notations)
        expect(result).to be true
      end
    end
  end
end
