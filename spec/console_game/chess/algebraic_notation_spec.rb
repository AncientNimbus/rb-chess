# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/input/algebraic_notation"

describe ConsoleGame::Chess::AlgebraicNotation do
  subject(:algebraic_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::AlgebraicNotation } }

  describe "#validate_algebraic" do
    # context "when input value is a valid entry to trigger preview move" do
    #   it "returns a command pattern hash where type is preview_move and position is extracted into an Array" do

    #   end
    # end
  end

  describe "#alg_output_capture_gps" do
    # context "when input value is a valid entry to trigger preview move" do
    #   it "returns a command pattern hash where type is preview_move and position is extracted into an Array" do
    #   end
    # end
  end

  describe "#parse_castling" do
    context "when side is a white king is performing kingside castling" do
      let(:side) { :white }
      let(:captures) { "O-O" }

      it "returns a command pattern hash where type is direct_move and current position and new position are extracted into an Array" do
        result = algebraic_test.send(:parse_castling, side, captures)
        expect(result).to eq({ type: :direct_move, args: %w[e1 g1] })
      end
    end

    context "when side is a white king is performing queenside castling" do
      let(:side) { :white }
      let(:captures) { "O-O-O" }

      it "returns a command pattern hash where type is direct_move and current position and new position are extracted into an Array" do
        result = algebraic_test.send(:parse_castling, side, captures)
        expect(result).to eq({ type: :direct_move, args: %w[e1 c1] })
      end
    end

    context "when side is a black king is performing kingside castling" do
      let(:side) { :black }
      let(:captures) { "O-O" }

      it "returns a command pattern hash where type is direct_move and current position and new position are extracted into an Array" do
        result = algebraic_test.send(:parse_castling, side, captures)
        expect(result).to eq({ type: :direct_move, args: %w[e8 g8] })
      end
    end

    context "when side is a black king is performing queenside castling" do
      let(:side) { :black }
      let(:captures) { "O-O-O" }

      it "returns a command pattern hash where type is direct_move and current position and new position are extracted into an Array" do
        result = algebraic_test.send(:parse_castling, side, captures)
        expect(result).to eq({ type: :direct_move, args: %w[e8 c8] })
      end
    end
  end

  describe "#parse_promote" do
    context "when side is a white pawn is marching directly towards e8 and intends to promote to queen" do
      let(:side) { :white }
      let(:captures) { { target: "e8", promote: "Q" } }

      it "returns a command pattern hash where type is direct_promote and current position, new position and notation are extracted into an Array" do
        result = algebraic_test.send(:parse_promote, side, captures)
        expect(result).to eq({ type: :direct_promote, args: ["e7", "e8", :q] })
      end
    end

    context "when side is a black pawn is marching directly towards e1 and intends to promote to bishop" do
      let(:side) { :black }
      let(:captures) { { target: "e1", promote: "B" } }

      it "returns a command pattern hash where type is direct_promote and current position, new position and notation are extracted into an Array" do
        result = algebraic_test.send(:parse_promote, side, captures)
        expect(result).to eq({ type: :direct_promote, args: ["e2", "e1", :b] })
      end
    end

    context "when side is a white pawn is performing a captures towards b8 and intends to promote to rook" do
      let(:side) { :white }
      let(:captures) { { file_rank: "a", capture: "x", target: "b8", promote: "R" } }

      it "returns a command pattern hash where type is direct_promote and current position, new position and notation are extracted into an Array" do
        result = algebraic_test.send(:parse_promote, side, captures)
        expect(result).to eq({ type: :direct_promote, args: ["a7", "b8", :r] })
      end
    end

    context "when side is a black pawn is performing a captures towards b1 and intends to promote to knight" do
      let(:side) { :black }
      let(:captures) { { file_rank: "a", capture: "x", target: "b1", promote: "R" } }

      it "returns a command pattern hash where type is direct_promote and current position, new position and notation are extracted into an Array" do
        result = algebraic_test.send(:parse_promote, side, captures)
        expect(result).to eq({ type: :direct_promote, args: ["a2", "b1", :r] })
      end
    end
  end

  describe "#parse_move" do
    context "when side is a white knight is performing a captures towards a5 from file c" do
      let(:side) { :white }
      let(:captures) { { piece: "N", file_rank: "c", capture: "x", target: "a5" } }

      it "returns a command pattern hash where type is fetch_and_move and side, notation, new position and file are extracted into an Array" do
        result = algebraic_test.send(:parse_move, side, captures)
        expect(result).to eq({ type: :fetch_and_move, args: [:white, :n, "a5", "c"] })
      end
    end

    context "when side is a black knight is marching towards c3 from file b" do
      let(:side) { :black }
      let(:captures) { { piece: "N", file_rank: "b", target: "c3" } }

      it "returns a command pattern hash where type is fetch_and_move and side, notation, new position and file are extracted into an Array" do
        result = algebraic_test.send(:parse_move, side, captures)
        expect(result).to eq({ type: :fetch_and_move, args: [:black, :n, "c3", "b"] })
      end
    end

    context "when side is a white knight is marching towards c6" do
      let(:side) { :black }
      let(:captures) { { piece: "N", target: "c6" } }

      it "returns a command pattern hash where type is fetch_and_move and side, notation, new position are extracted into an Array" do
        result = algebraic_test.send(:parse_move, side, captures)
        expect(result).to eq({ type: :fetch_and_move, args: [:black, :n, "c6"] })
      end
    end

    context "when side is a white pawn is marching towards b5" do
      let(:side) { :white }
      let(:captures) { { target: "b5" } }

      it "returns a command pattern hash where type is fetch_and_move and side, notation, new position are extracted into an Array" do
        result = algebraic_test.send(:parse_move, side, captures)
        expect(result).to eq({ type: :fetch_and_move, args: [:white, :p, "b5"] })
      end
    end

    context "when side is a black pawn is performing a capture towards a5 from file b" do
      let(:side) { :black }
      let(:captures) { { file_rank: "b", capture: "x", target: "a5" } }

      it "returns a command pattern hash where type is fetch_and_move and side, notation, new position and file are extracted into an Array" do
        result = algebraic_test.send(:parse_move, side, captures)
        expect(result).to eq({ type: :fetch_and_move, args: [:black, :p, "a5", "b"] })
      end
    end
  end

  describe "#regexp_algebraic" do
    context "when the method is call" do
      it "returns an array with two regular expression patterns for algebraic notation as string" do
        result = algebraic_test.send(:regexp_algebraic)
        expect(result).to eq(["(?<castle>O-O(?:-O)?)", "(?<piece>[KQRBN])?(?<file_rank>[a-h][1-8]|[a-h])?(?<capture>x)?(?<target>[a-h][1-8])(?:=(?<promote>[QRBN]))?(?<check>[+#])?"])
      end
    end
  end

  describe "#notation_to_sym" do
    context "when notation value is a valid uppercase string" do
      it "returns the string as a symbol in lowercase" do
        notation = "Q"
        result = algebraic_test.send(:notation_to_sym, notation)
        expect(result).to eq(:q)
      end
    end

    context "when notation value already a symbol" do
      it "returns the symbol as it is" do
        notation = :r
        result = algebraic_test.send(:notation_to_sym, notation)
        expect(result).to eq(:r)
      end
    end
  end
end
