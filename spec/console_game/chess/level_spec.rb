# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/level"
require_relative "../../../lib/nimbus_file_utils/nimbus_file_utils"

describe ConsoleGame::Chess::Level do
  NimbusFileUtils.set_locale("en")
  let(:controller) { ConsoleGame::Chess::ChessInput.new }
  let(:session) { { event: "Level Integration test", site: "Level and Movement logic", date: nil, round: nil, white: "Ancient", black: "Nimbus", result: nil, mode: 1, moves: {}, fens: [], white_moves: [], black_moves: [] } }
  let(:sides) { { white: ConsoleGame::Chess::ChessPlayer.new("Ancient", controller, :white), black: ConsoleGame::Chess::ChessPlayer.new("Nimbus", controller, :black) } }

  describe "Test Pawn opening move" do
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
  end

  describe "Test Capturing move" do
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

  describe "Test En passant" do
    context "when white's is about to fell into en passant trap where a black pawn is waiting at d4" do
      subject(:fen_str) { "rnbqkbnr/ppp1pppp/8/8/3p4/N4N2/PPPPPPPP/R1BQKB1R w KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "enters the game loop and white pawn to move from e2 to e4, trigger en passant" do
        allow(Readline).to receive(:readline).and_return("e4")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.en_passant[1]
        expect(result).to eq(20)
      end
    end

    context "when black's is about to make en passant move to capture white pawn at e4" do
      subject(:fen_str) { "rnbqkbnr/ppp1pppp/8/8/3pP3/N4N2/PPPP1PPP/R1BQKB1R b KQkq e3 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "enters the game loop and moves to e3, white pawn at e4 is removed and en_passant is reset" do
        allow(Readline).to receive(:readline).and_return("dxe3")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.en_passant.nil? && level_test.turn_data[28] == ""
        expect(result).to be true
      end
    end

    context "when black's is about opting not to capture white pawn at e4" do
      subject(:fen_str) { "rnbqkbnr/ppp1pppp/8/8/3pP3/N4N2/PPPP1PPP/R1BQKB1R b KQkq e3 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "enters the game loop and moves to e3, white pawn at e4 is removed and en_passant is reset" do
        allow(Readline).to receive(:readline).and_return("d3")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.en_passant.nil? && level_test.turn_data[28].is_a?(ConsoleGame::Chess::Pawn)
        expect(result).to be true
      end
    end
  end

  describe "Test Pawn promotion" do
    context "when white pawn is reaching the last tile and promotes to a Queen" do
      subject(:fen_str) { "2bqkbnr/P3pppp/2n5/8/3pP3/N4N2/1PPP1PPP/R1BQKB1R w KQk - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "enters the game loop, white pawn moves from a7 to a8 and promotes to a Queen" do
        allow(Readline).to receive(:readline).and_return("a8=Q")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.turn_data[56].is_a?(ConsoleGame::Chess::Queen)
        expect(result).to be true
      end
    end

    context "when white pawn is reaching the last tile, captures a black knight and promotes to a Rook" do
      subject(:fen_str) { "1nbqkbnr/P3pppp/8/8/3pP3/N4N2/1PPP1PPP/R1BQKB1R w KQk - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "enters the game loop, white pawn captures black knight in b8 and promotes to a Rook" do
        allow(Readline).to receive(:readline).and_return("axb8=R")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.turn_data[57].is_a?(ConsoleGame::Chess::Rook)
        expect(result).to be true
      end
    end

    context "when black pawn is reaching the last tile and promotes to a Bishop" do
      subject(:fen_str) { "1nbqkbnr/P3pppp/8/8/4P3/5N2/pPPP1PPP/2BQKB1R b Kk - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
      end

      it "enters the game loop, black pawn moves from a2 to a1 and promotes to a Bishop" do
        allow(Readline).to receive(:readline).and_return("a2a1b")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.turn_data[0].is_a?(ConsoleGame::Chess::Bishop)
        expect(result).to be true
      end
    end

    context "when black pawn is reaching the last tile and promotes to a Knight" do
      subject(:fen_str) { "1nbqkbnr/P3pppp/8/8/4P3/5N2/pPPP1PPP/2BQKB1R b Kk - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
      end

      it "enters the game loop, black pawn moves from a2 to a1 and promotes to a Knight" do
        allow(Readline).to receive(:readline).and_return("a2a1", "n")
        allow(level_test).to receive(:game_ended).and_return(false, false, false, true)
        level_test.open_level
        result = level_test.turn_data[0].is_a?(ConsoleGame::Chess::Knight)
        expect(result).to be true
      end
    end
  end

  describe "Test King castling" do
    context "when white king's castling right is available" do
      subject(:fen_str) { "r3k2r/pp1qpppp/1npp1n2/3bb3/4P3/N1PP1N2/PPQBBPPP/R3K2R w KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "enters the game loop, if input is O-O, Kingside castling is triggered, white king's new position is g1 and rook's position is f1" do
        allow(Readline).to receive(:readline).and_return("O-O")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.turn_data[5].is_a?(ConsoleGame::Chess::Rook) && level_test.turn_data[6].is_a?(ConsoleGame::Chess::King)
        expect(result).to be true
      end

      it "enters the game loop, if input is O-O-O, Queenside castling is triggered, white king's new position is c1 and rook's position is d1" do
        allow(Readline).to receive(:readline).and_return("O-O-O")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.turn_data[3].is_a?(ConsoleGame::Chess::Rook) && level_test.turn_data[2].is_a?(ConsoleGame::Chess::King)
        expect(result).to be true
      end
    end

    context "when black king's castling right is available" do
      subject(:fen_str) { "r3k2r/pp1qpppp/1npp1n2/3bb3/4P3/N1PP1N2/PPQBBPPP/R3K2R b KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
      end

      it "enters the game loop, if input is e8g8, Kingside castling is triggered, black king's new position is g8 and rook's position is f8" do
        allow(Readline).to receive(:readline).and_return("e8", "g8")
        allow(level_test).to receive(:game_ended).and_return(false, false, false, true)
        level_test.open_level
        result = level_test.turn_data[61].is_a?(ConsoleGame::Chess::Rook) && level_test.turn_data[62].is_a?(ConsoleGame::Chess::King)
        expect(result).to be true
      end

      it "enters the game loop, if input is e8c8, Queenside castling is triggered, black king's new position is c8 and rook's position is d8" do
        allow(Readline).to receive(:readline).and_return("e8c8")
        allow(level_test).to receive(:game_ended).and_return(false, false, false, true)
        level_test.open_level
        result = level_test.turn_data[59].is_a?(ConsoleGame::Chess::Rook) && level_test.turn_data[58].is_a?(ConsoleGame::Chess::King)
        expect(result).to be true
      end
    end
  end

  describe "Test Computer's movements" do
    context "when both players are Chess Computer player" do
      subject(:fen_str) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }

      let(:sides) { { white: ConsoleGame::Chess::ChessComputer.new("Robocop", controller, :white), black: ConsoleGame::Chess::ChessComputer.new("Data", controller, :black) } }
      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
      end

      it "enters the game loop and each take turn to make a move" do
        allow(level_test).to receive(:game_ended).and_return(false, false, false, false, true)
        level_test.open_level
        result = level_test.send(:all_moves).flatten.compact.size
        expect(result).to eq(2)
      end
    end
  end

  describe "Test user's commands" do
    context "when prompt input is --board size" do
      subject(:fen_str) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "adjusts the chessboard size by making it bigger" do
        allow(Readline).to receive(:readline).and_return("--board size", "e4")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.board.board_size == 2
        expect(result).to be true
      end
    end

    context "when prompt input is --board flip" do
      subject(:fen_str) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }

      let(:level_test) { described_class.new(controller, sides, session, fen_str) }

      before do
        allow($stdout).to receive(:puts)
        allow(level_test).to receive(:save_turn)
        controller.input_scheme = controller.alg_reg
      end

      it "disable the chessboard flip feature" do
        allow(Readline).to receive(:readline).and_return("--board flip", "e4")
        allow(level_test).to receive(:game_ended).and_return(false, false, true)
        level_test.open_level
        result = level_test.board.flip_board == false
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
