# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/utilities/fen_utils"
require_relative "../../../lib/console_game/chess/level"

describe ConsoleGame::Chess::FenUtils do
  subject(:fen_utils_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::FenUtils } }

  describe "#piece_maker" do
    let(:level_double) { instance_double(ConsoleGame::Chess::Level) }

    context "when board position is 0, and placing a white rook to active level" do
      let(:pos) { 0 }
      let(:fen_notation) { "R" }

      it "returns a new Rook class object" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Rook)
      end

      it "where the Rook object's side is set to :white" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the Rook object's algebraic position is set to a1" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("a1")
      end
    end

    context "when board position is 8, and placing a white pawn to active level" do
      let(:pos) { 8 }
      let(:fen_notation) { "P" }

      it "returns a new Pawn class object" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Pawn)
      end

      it "where the Pawn object's side is set to :white" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the Pawn object's algebraic position is set to a2" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("a2")
      end
    end

    context "when board position is 2, and placing a white bishop to active level" do
      let(:pos) { 2 }
      let(:fen_notation) { "B" }

      it "returns a new bishop class object" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Bishop)
      end

      it "where the bishop object's side is set to :white" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the bishop object's algebraic position is set to c1" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("c1")
      end
    end

    context "when board position is 3, and placing a white queen to active level" do
      let(:pos) { 3 }
      let(:fen_notation) { "Q" }

      it "returns a new Queen class object" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Queen)
      end

      it "where the Queen object's side is set to :white" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the Queen object's algebraic position is set to d1" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("d1")
      end
    end

    context "when board position is 4, and placing a white king to active level" do
      let(:pos) { 4 }
      let(:fen_notation) { "K" }

      it "returns a new King class object" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::King)
      end

      it "where the King object's side is set to :white" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the King object's algebraic position is set to e1" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("e1")
      end
    end

    context "when board position is 63, and placing a black rook to active level" do
      let(:pos) { 63 }
      let(:fen_notation) { "r" }

      it "returns a new Rook class object" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Rook)
      end

      it "where the Rook object's side is set to :black" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:black)
      end

      it "where the Rook object's algebraic position is set to h8" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("h8")
      end
    end

    context "when board position is 62, and placing a black knight to active level" do
      let(:pos) { 62 }
      let(:fen_notation) { "n" }

      it "returns a new Knight class object" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Knight)
      end

      it "where the Knight object's side is set to :black" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:black)
      end

      it "where the Knight object's algebraic position is set to g8" do
        result = fen_utils_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("g8")
      end
    end
  end

  # describe "#parse_castling_str" do
  #   context "" do
  #   end
  # end

  describe "#normalise_fen_rank" do
    context "when the value is a valid FEN string of a new game" do
      let(:standard_new_board) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR" }

      it "returns a 1D array of string where empty tiles are replaced with 0 and each letters are separated" do
        result = fen_utils_test.send(:normalise_fen_rank, standard_new_board)
        expect(result).to eq(["r", "n", "b", "q", "k", "b", "n", "r", "/", "p", "p", "p", "p", "p", "p", "p", "p", "/", "0", "0", "0", "0", "0", "0", "0", "0", "/", "0", "0", "0", "0", "0", "0", "0", "0", "/", "0", "0", "0", "0", "0", "0", "0", "0", "/", "0", "0", "0", "0", "0", "0", "0", "0", "/", "P", "P", "P", "P", "P", "P", "P", "P", "/", "R", "N", "B", "Q", "K", "B", "N", "R"])
      end

      it "returns a 1D array of string where the length of the array is 71" do
        result = fen_utils_test.send(:normalise_fen_rank, standard_new_board)
        expect(result.size).to eq(71)
      end
    end

    context "when the value is a valid FEN string of an ongoing game" do
      let(:standard_new_board) { "r5rk/ppp4p/3p4/2b2Q2/3pPP2/2P2n2/PP3P1R/RNB4K" }

      it "returns a 1D array of string where empty tiles are replaced with 0 and each letters are separated" do
        result = fen_utils_test.send(:normalise_fen_rank, standard_new_board)
        expect(result).to eq(["r", "0", "0", "0", "0", "0", "r", "k", "/", "p", "p", "p", "0", "0", "0", "0", "p", "/", "0", "0", "0", "p", "0", "0", "0", "0", "/", "0", "0", "b", "0", "0", "Q", "0", "0", "/", "0", "0", "0", "p", "P", "P", "0", "0", "/", "0", "0", "P", "0", "0", "n", "0", "0", "/", "P", "P", "0", "0", "0", "P", "0", "R", "/", "R", "N", "B", "0", "0", "0", "0", "K"])
      end

      it "returns a 1D array of string where the length of the array is 71" do
        result = fen_utils_test.send(:normalise_fen_rank, standard_new_board)
        expect(result.size).to eq(71)
      end
    end
  end
end
