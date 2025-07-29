# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/utilities/chess_utils"

describe ConsoleGame::Chess::ChessUtils do
  subject(:chess_utils_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::ChessUtils } }

  describe "#alg_map" do
    let(:alg_dict) { { a1: 0, a2: 8, a3: 16, a4: 24, a5: 32, a6: 40, a7: 48, a8: 56, b1: 1, b2: 9, b3: 17, b4: 25, b5: 33, b6: 41, b7: 49, b8: 57, c1: 2, c2: 10, c3: 18, c4: 26, c5: 34, c6: 42, c7: 50, c8: 58, d1: 3, d2: 11, d3: 19, d4: 27, d5: 35, d6: 43, d7: 51, d8: 59, e1: 4, e2: 12, e3: 20, e4: 28, e5: 36, e6: 44, e7: 52, e8: 60, f1: 5, f2: 13, f3: 21, f4: 29, f5: 37, f6: 45, f7: 53, f8: 61, g1: 6, g2: 14, g3: 22, g4: 30, g5: 38, g6: 46, g7: 54, g8: 62, h1: 7, h2: 15, h3: 23, h4: 31, h5: 39, h6: 47, h7: 55, h8: 63 } }

    it "returns a hash with algebraic notation as keys, positional grid number as values" do
      result = chess_utils_test.alg_map
      expect(result).to eq(alg_dict)
    end
  end

  describe "#to_alg_pos" do
    it "returns a1 when grid positional value is 0" do
      result = chess_utils_test.to_alg_pos(0)
      expect(result).to eq("a1")
    end
  end

  describe "#to_1d_pos" do
    context "when value is a symbol" do
      it "returns 0 when algebraic notation value is :a1" do
        result = chess_utils_test.to_1d_pos(:a1)
        expect(result).to eq(0)
      end
    end

    context "when value is a string" do
      it "returns 0 when algebraic notation value is a1" do
        result = chess_utils_test.to_1d_pos("a1")
        expect(result).to eq(0)
      end
    end
  end

  describe "#opposite_of" do
    context "when side is :white" do
      let(:side) { :white }

      it "returns :black" do
        result = chess_utils_test.opposite_of(side)
        expect(result).to eq(:black)
      end
    end

    context "when side is :black" do
      let(:side) { :black }

      it "returns :black" do
        result = chess_utils_test.opposite_of(side)
        expect(result).to eq(:white)
      end
    end

    context "when side is invalid" do
      let(:invalid_symbol) { :something_else }
      let(:not_a_symbol) { ":white" }

      it "returns nil if symbol is :something_else" do
        result = chess_utils_test.opposite_of(invalid_symbol)
        expect(result).to be_nil
      end

      it "returns nil" do
        result = chess_utils_test.opposite_of(not_a_symbol)
        expect(result).to be_nil
      end
    end
  end
end
