# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/utilities/fen_utils"
require_relative "../../../lib/console_game/chess/level"

describe ConsoleGame::Chess::FenUtils do
  subject(:fen_utils_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::FenUtils } }

  describe "#parse_fen" do
    context "when value is a complete and valid FEN data string" do
      it "returns a hash" do
        skip "not ready"
      end
    end
  end

  describe "#fen_error" do
    context "when the method is called" do
      it "returns a string with the problematic FEN string attached" do
        skip "not ready"
      end
    end
  end

  describe "#to_turn_data" do
    let(:level_double) { instance_double(ConsoleGame::Chess::Level) }

    context "when the value is a valid FEN string of a new game" do
      let(:standard_new_board) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR" }

      it "returns a 1d array of the board state with 64 elements" do
        result = fen_utils_test.send(:to_turn_data, standard_new_board, level_double)
        expect(result.size).to eq(64)
      end
    end

    context "when the value is a valid FEN string of an ongoing game" do
      let(:ongoing_game_board) { "r5rk/ppp4p/3p4/2b2Q2/3pPP2/2P2n2/PP3P1R/RNB4K" }

      it "returns a 1d array of the board state with 64 elements" do
        result = fen_utils_test.send(:to_turn_data, ongoing_game_board, level_double)
        expect(result.size).to eq(64)
      end
    end

    context "when the value is not a valid FEN string sequence" do
      let(:invalid_sequence) { "r5ABC/ppzzp4p/3p4/9/3pPP2/2P2n2/TEST/RNB4K" }

      it "returns nil" do
        result = fen_utils_test.send(:to_turn_data, invalid_sequence, level_double)
        expect(result).to be_nil
      end
    end
  end

  describe "#parse_active_color" do
    context "when value is a valid FEN active color data: w" do
      let(:active_color) { "w" }

      it "returns a hash where white_turn is set to true" do
        result = fen_utils_test.send(:parse_active_color, active_color)
        expect(result).to eq({ white_turn: true })
      end
    end

    context "when value is a valid FEN active color data: b" do
      let(:active_color) { "b" }

      it "returns a hash where white_turn is set to true" do
        result = fen_utils_test.send(:parse_active_color, active_color)
        expect(result).to eq({ white_turn: false })
      end
    end

    context "when value is invalid" do
      let(:active_color) { "c" }

      it "returns nil" do
        result = fen_utils_test.send(:parse_active_color, active_color)
        expect(result).to be_nil
      end
    end
  end

  describe "#parse_castling_str" do
    context "when value is a valid FEN castling sequence: KQkq" do
      let(:castling_state) { "KQkq" }

      it "returns a hash where all castling moves are possible" do
        result = fen_utils_test.send(:parse_castling_str, castling_state)
        expect(result).to eq({ K: true, Q: true, k: true, q: true })
      end
    end

    context "when value is a valid FEN castling sequence: Kq" do
      let(:castling_state) { "Kq" }

      it "returns a hash where white Kingside castling and black Queenside castling are possible" do
        result = fen_utils_test.send(:parse_castling_str, castling_state)
        expect(result).to eq({ K: true, Q: false, k: false, q: true })
      end
    end

    context "when value is a valid FEN castling sequence: k" do
      let(:castling_state) { "k" }

      it "returns a hash where only black Kingside castling is possible" do
        result = fen_utils_test.send(:parse_castling_str, castling_state)
        expect(result).to eq({ K: false, Q: false, k: true, q: false })
      end
    end

    context "when value is a valid FEN castling sequence is empty" do
      let(:castling_state) { "" }

      it "returns a hash where no castling moves are available" do
        result = fen_utils_test.send(:parse_castling_str, castling_state)
        expect(result).to eq({ K: false, Q: false, k: false, q: false })
      end
    end

    context "when value is not a valid FEN castling sequence" do
      let(:castling_state) { "ABcd" }

      it "returns nil" do
        result = fen_utils_test.send(:parse_castling_str, castling_state)
        expect(result).to be_nil
      end
    end
  end

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

  describe "#normalise_fen_rank" do
    context "when the value is a valid FEN string of rank 1 in a new game" do
      let(:standard_new_rank1) { "rnbqkbnr" }

      it "returns a 1D array of string where empty tiles are replaced with 0 and each letters are separated" do
        result = fen_utils_test.send(:normalise_fen_rank, standard_new_rank1)
        expect(result).to eq(%w[r n b q k b n r])
      end

      it "returns a 1D array of string where the length of the array is 8" do
        result = fen_utils_test.send(:normalise_fen_rank, standard_new_rank1)
        expect(result.size).to eq(8)
      end
    end

    context "when the value is a valid FEN string of rank 3 in a new game" do
      let(:standard_new_rank3) { "8" }

      it "returns a 1D array of string where empty tiles are replaced with 0 and each letters are separated" do
        result = fen_utils_test.send(:normalise_fen_rank, standard_new_rank3)
        expect(result).to eq(%w[0 0 0 0 0 0 0 0])
      end

      it "returns a 1D array of string where the length of the array is 8" do
        result = fen_utils_test.send(:normalise_fen_rank, standard_new_rank3)
        expect(result.size).to eq(8)
      end
    end

    context "when the value is a valid FEN string of rank 1 in an ongoing game" do
      let(:ongoing_game_board_rank1) { "r5rk" }

      it "returns a 1D array of string where empty tiles are replaced with 0 and each letters are separated" do
        result = fen_utils_test.send(:normalise_fen_rank, ongoing_game_board_rank1)
        expect(result).to eq(%w[r 0 0 0 0 0 r k])
      end

      it "returns a 1D array of string where the length of the array is 8" do
        result = fen_utils_test.send(:normalise_fen_rank, ongoing_game_board_rank1)
        expect(result.size).to eq(8)
      end
    end
  end
end
