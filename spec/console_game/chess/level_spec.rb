# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/level"
require_relative "../../../lib/nimbus_file_utils/nimbus_file_utils"

describe ConsoleGame::Chess::Level do
  NimbusFileUtils.set_locale("en")
  let(:controller) { ConsoleGame::Chess::ChessInput.new }
  let(:session) { { event: "Level Integration test", site: "Level and Movement logic", date: nil, round: nil, white: "Ancient", black: "Nimbus", result: nil, mode: 1, moves: {}, fens: [] } }
  let(:sides) { { white: ConsoleGame::Chess::ChessPlayer.new("Ancient", controller, :white), black: ConsoleGame::Chess::ChessPlayer.new("Nimbus", controller, :black) } }

  describe "#open_level" do
    context "when imported FEN is a new session and it is white's turn" do
      subject(:fen_str) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
      end

      it "enters the game loop and white pawn moves from a2 to a3" do
        allow(Readline).to receive(:readline).and_return("a2a3")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.turn_data[16].is_a?(ConsoleGame::Chess::Pawn)
        expect(result).to be true
      end
    end

    context "when imported FEN is an ongoing session and it is black's turn" do
      subject(:fen_str) { "rnbqkbnr/pppppppp/8/8/8/4P3/PPPP1PPP/RNBQKBNR b KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
      end

      it "enters the game loop and black pawn moves from h7 to h5" do
        allow(Readline).to receive(:readline).and_return("h7h5")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.turn_data[39].is_a?(ConsoleGame::Chess::Pawn)
        expect(result).to be true
      end
    end

    context "when black's is about to capture a pawn with a knight" do
      subject(:fen_str) { "r1bqkbnr/pppppppp/2n5/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "enters the game loop and black knight captures pawn from c6" do
        allow(Readline).to receive(:readline).and_return("Nxd4")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.turn_data[27].is_a?(ConsoleGame::Chess::Knight)
        expect(result).to be true
      end
    end
  end

  describe "#init_level" do
    context "when imported FEN is a new game string" do
      subject(:fen_str) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
      end

      it "initialised a new level and game_ended is false" do
        level_test.send(:init_level)
        result = level_test.game_ended
        expect(result).to be false
      end
    end
  end
end
