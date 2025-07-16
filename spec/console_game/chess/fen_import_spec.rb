# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/utilities/fen_import"
require_relative "../../../lib/console_game/chess/level"

describe ConsoleGame::Chess::FenImport do
  subject(:fen_import_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::FenImport } }

  describe "#parse_fen" do
    let(:level_double) { instance_double(ConsoleGame::Chess::Level) }

    context "when value is a valid FEN new game string" do
      let(:new_game_placement_w) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }

      it "returns a hash with 6 internal hash data fields: turn_data, white_turn, castling_states, en_passant, half, and full" do
        result = fen_import_test.parse_fen(level_double, new_game_placement_w)
        expect(result.keys).to eq(%i[turn_data white_turn castling_states en_passant half full])
      end

      it "returns a hash where turn_data contains an array with 64 elements" do
        result = fen_import_test.parse_fen(level_double, new_game_placement_w)
        expect(result[:turn_data].size).to eq(64)
      end

      it "returns a hash where white_turn is set to true" do
        result = fen_import_test.parse_fen(level_double, new_game_placement_w)
        expect(result[:white_turn]).to be(true)
      end

      it "returns a hash where castling_states has :K, :Q, :k and :q as keys" do
        result = fen_import_test.parse_fen(level_double, new_game_placement_w)
        expect(result[:castling_states].keys).to eq(%i[K Q k q])
      end

      it "returns a hash where en_passant is nil" do
        result = fen_import_test.parse_fen(level_double, new_game_placement_w)
        expect(result[:en_passant]).to be_nil
      end

      it "returns a hash where half-move is 0" do
        result = fen_import_test.parse_fen(level_double, new_game_placement_w)
        expect(result[:half]).to eq(0)
      end

      it "returns a hash where full-move is 1" do
        result = fen_import_test.parse_fen(level_double, new_game_placement_w)
        expect(result[:full]).to eq(1)
      end
    end

    context "when default FEN start string is used" do
      it "returns a hash with 6 internal hash data fields: turn_data, white_turn, castling_states, en_passant, half, and full" do
        result = fen_import_test.parse_fen(level_double)
        expect(result.keys).to eq(%i[turn_data white_turn castling_states en_passant half full])
      end

      it "returns a hash where turn_data contains an array with 64 elements" do
        result = fen_import_test.parse_fen(level_double)
        expect(result[:turn_data].size).to eq(64)
      end

      it "returns a hash where white_turn is set to true" do
        result = fen_import_test.parse_fen(level_double)
        expect(result[:white_turn]).to be(true)
      end

      it "returns a hash where castling_states has :K, :Q, :k and :q as keys" do
        result = fen_import_test.parse_fen(level_double)
        expect(result[:castling_states].keys).to eq(%i[K Q k q])
      end

      it "returns a hash where en_passant is nil" do
        result = fen_import_test.parse_fen(level_double)
        expect(result[:en_passant]).to be_nil
      end

      it "returns a hash where half-move is 0" do
        result = fen_import_test.parse_fen(level_double)
        expect(result[:half]).to eq(0)
      end

      it "returns a hash where full-move is 1" do
        result = fen_import_test.parse_fen(level_double)
        expect(result[:full]).to eq(1)
      end
    end

    context "when value is an invalid FEN string" do
      let(:invalid_fen_string) { "Invalid fen string" }

      it "returns a hash of a standard new game as fallback" do
        result = fen_import_test.parse_fen(level_double, invalid_fen_string)
        expect(result.keys).to eq(%i[turn_data white_turn castling_states en_passant half full])
      end
    end
  end

  # describe "#fen_error" do
  #   context "when the method is called" do
  #     it "returns a string with the problematic FEN string attached" do
  #       skip "not ready"
  #     end
  #   end
  # end

  describe "#parse_piece_placement" do
    let(:level_double) { instance_double(ConsoleGame::Chess::Level) }

    context "when the value is a valid FEN string of a new game" do
      let(:standard_new_board) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR" }

      it "returns a hash with turn_data as key and contains a 1d array of the board state with 64 elements" do
        result = fen_import_test.send(:parse_piece_placement, standard_new_board, level_double)
        expect(result[:turn_data].size).to eq(64)
      end
    end

    context "when the value is a valid FEN string of an ongoing game" do
      let(:ongoing_game_board) { "r5rk/ppp4p/3p4/2b2Q2/3pPP2/2P2n2/PP3P1R/RNB4K" }

      it "returns a hash with turn_data as key and contains a 1d array of the board state with 64 elements" do
        result = fen_import_test.send(:parse_piece_placement, ongoing_game_board, level_double)
        expect(result[:turn_data].size).to eq(64)
      end
    end

    context "when the value is not a valid FEN string sequence" do
      let(:invalid_sequence) { "r5ABC/ppzzp4p/3p4/9/3pPP2/2P2n2/TEST/RNB4K" }

      it "returns nil" do
        result = fen_import_test.send(:parse_piece_placement, invalid_sequence, level_double)
        expect(result).to be_nil
      end
    end
  end

  # describe "#parse_active_color" do
  #   context "when value is a valid FEN active color data: w" do
  #     let(:active_color) { "w" }

  #     it "returns a hash where white_turn is set to true" do
  #       result = fen_import_test.send(:parse_active_color, active_color)
  #       expect(result).to eq({ white_turn: true })
  #     end
  #   end

  #   context "when value is a valid FEN active color data: b" do
  #     let(:active_color) { "b" }

  #     it "returns a hash where white_turn is set to true" do
  #       result = fen_import_test.send(:parse_active_color, active_color)
  #       expect(result).to eq({ white_turn: false })
  #     end
  #   end

  #   context "when value is invalid" do
  #     let(:active_color) { "c" }

  #     it "returns nil" do
  #       result = fen_import_test.send(:parse_active_color, active_color)
  #       expect(result).to be_nil
  #     end
  #   end
  # end

  describe "#parse_castling_str" do
    context "when value is a valid FEN castling sequence: KQkq" do
      let(:castling_state) { "KQkq" }

      it "returns a hash where all castling moves are possible" do
        result = fen_import_test.send(:parse_castling_str, castling_state)
        expect(result).to eq({ castling_states: { K: true, Q: true, k: true, q: true } })
      end
    end

    context "when value is a valid FEN castling sequence: Kq" do
      let(:castling_state) { "Kq" }

      it "returns a hash where white Kingside castling and black Queenside castling are possible" do
        result = fen_import_test.send(:parse_castling_str, castling_state)
        expect(result).to eq({ castling_states: { K: true, Q: false, k: false, q: true } })
      end
    end

    context "when value is a valid FEN castling sequence: k" do
      let(:castling_state) { "k" }

      it "returns a hash where only black Kingside castling is possible" do
        result = fen_import_test.send(:parse_castling_str, castling_state)
        expect(result).to eq({ castling_states: { K: false, Q: false, k: true, q: false } })
      end
    end

    context "when value is a valid FEN castling sequence is empty" do
      let(:castling_state) { "" }

      it "returns a hash where no castling moves are available" do
        result = fen_import_test.send(:parse_castling_str, castling_state)
        expect(result).to eq({ castling_states: { K: false, Q: false, k: false, q: false } })
      end
    end

    context "when value is not a valid FEN castling sequence" do
      let(:castling_state) { "ABcd" }

      it "returns nil" do
        result = fen_import_test.send(:parse_castling_str, castling_state)
        expect(result).to be_nil
      end
    end
  end

  describe "#parse_en_passant" do
    context "when value is a3" do
      let(:ep_state) { "a3" }

      it "returns a hash where en_passant key contains the same value" do
        result = fen_import_test.send(:parse_en_passant, ep_state)
        expect(result).to eq({ en_passant: %w[a4 a3] })
      end
    end

    context "when value is h6" do
      let(:ep_state) { "h6" }

      it "returns a hash where en_passant key contains the same value" do
        result = fen_import_test.send(:parse_en_passant, ep_state)
        expect(result).to eq({ en_passant: %w[h5 h6] })
      end
    end

    context "when value is -" do
      let(:ep_state) { "-" }

      it "returns a hash where en_passant key is set to nil" do
        result = fen_import_test.send(:parse_en_passant, ep_state)
        expect(result).to eq({ en_passant: nil })
      end
    end

    context "when value is h8" do
      let(:ep_state) { "h8" }

      it "returns nil" do
        result = fen_import_test.send(:parse_en_passant, ep_state)
        expect(result).to be_nil
      end
    end

    context "when value is invalid" do
      let(:ep_state) { "abc" }

      it "returns nil" do
        result = fen_import_test.send(:parse_en_passant, ep_state)
        expect(result).to be_nil
      end
    end
  end

  # describe "#parse_move_number" do
  #   context "when value is a number and type is half-move" do
  #     let(:move_num) { "2" }
  #     let(:type_is_half_move) { :half }

  #     it "returns a hash where key is set to half and value is converted to an integer" do
  #       result = fen_import_test.send(:parse_move_number, move_num, type_is_half_move)
  #       expect(result).to eq({ half: 2 })
  #     end
  #   end

  #   context "when value is a number and type is full-move" do
  #     let(:move_num) { "20" }
  #     let(:type_is_full_move) { :full }

  #     it "returns a hash where key is set to full and value is converted to an integer" do
  #       result = fen_import_test.send(:parse_move_number, move_num, type_is_full_move)
  #       expect(result).to eq({ full: 20 })
  #     end
  #   end

  #   context "when value is not a number and type is full-move" do
  #     let(:move_num) { "ABC" }
  #     let(:type_is_full_move) { :full }

  #     it "returns nil" do
  #       result = fen_import_test.send(:parse_move_number, move_num, type_is_full_move)
  #       expect(result).to be_nil
  #     end
  #   end

  #   context "when value is a number and type is not valid" do
  #     let(:move_num) { "123" }
  #     let(:invalid_type) { :not_valid }

  #     it "returns nil" do
  #       result = fen_import_test.send(:parse_move_number, move_num, invalid_type)
  #       expect(result).to be_nil
  #     end
  #   end
  # end

  describe "#piece_maker" do
    let(:level_double) { instance_double(ConsoleGame::Chess::Level) }

    context "when board position is 0, and placing a white rook to active level" do
      let(:pos) { 0 }
      let(:fen_notation) { "R" }

      it "returns a new Rook class object" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Rook)
      end

      it "where the Rook object's side is set to :white" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the Rook object's algebraic position is set to a1" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("a1")
      end
    end

    context "when board position is 8, and placing a white pawn to active level" do
      let(:pos) { 8 }
      let(:fen_notation) { "P" }

      it "returns a new Pawn class object" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Pawn)
      end

      it "where the Pawn object's side is set to :white" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the Pawn object's algebraic position is set to a2" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("a2")
      end
    end

    context "when board position is 2, and placing a white bishop to active level" do
      let(:pos) { 2 }
      let(:fen_notation) { "B" }

      it "returns a new bishop class object" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Bishop)
      end

      it "where the bishop object's side is set to :white" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the bishop object's algebraic position is set to c1" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("c1")
      end
    end

    context "when board position is 3, and placing a white queen to active level" do
      let(:pos) { 3 }
      let(:fen_notation) { "Q" }

      it "returns a new Queen class object" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Queen)
      end

      it "where the Queen object's side is set to :white" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the Queen object's algebraic position is set to d1" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("d1")
      end
    end

    context "when board position is 4, and placing a white king to active level" do
      let(:pos) { 4 }
      let(:fen_notation) { "K" }

      it "returns a new King class object" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::King)
      end

      it "where the King object's side is set to :white" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:white)
      end

      it "where the King object's algebraic position is set to e1" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("e1")
      end
    end

    context "when board position is 63, and placing a black rook to active level" do
      let(:pos) { 63 }
      let(:fen_notation) { "r" }

      it "returns a new Rook class object" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Rook)
      end

      it "where the Rook object's side is set to :black" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:black)
      end

      it "where the Rook object's algebraic position is set to h8" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("h8")
      end
    end

    context "when board position is 62, and placing a black knight to active level" do
      let(:pos) { 62 }
      let(:fen_notation) { "n" }

      it "returns a new Knight class object" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result).to be_a(ConsoleGame::Chess::Knight)
      end

      it "where the Knight object's side is set to :black" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.side).to eq(:black)
      end

      it "where the Knight object's algebraic position is set to g8" do
        result = fen_import_test.send(:piece_maker, pos, fen_notation, level_double)
        expect(result.info).to eq("g8")
      end
    end
  end

  # describe "#normalise_fen_rank" do
  #   context "when the value is a valid FEN string of rank 1 in a new game" do
  #     let(:standard_new_rank1) { "rnbqkbnr" }

  #     it "returns a 1D array of string where empty tiles are replaced with 0 and each letters are separated" do
  #       result = fen_import_test.send(:normalise_fen_rank, standard_new_rank1)
  #       expect(result).to eq(%w[r n b q k b n r])
  #     end

  #     it "returns a 1D array of string where the length of the array is 8" do
  #       result = fen_import_test.send(:normalise_fen_rank, standard_new_rank1)
  #       expect(result.size).to eq(8)
  #     end
  #   end

  #   context "when the value is a valid FEN string of rank 3 in a new game" do
  #     let(:standard_new_rank3) { "8" }

  #     it "returns a 1D array of string where empty tiles are replaced with 0 and each letters are separated" do
  #       result = fen_import_test.send(:normalise_fen_rank, standard_new_rank3)
  #       expect(result).to eq(%w[0 0 0 0 0 0 0 0])
  #     end

  #     it "returns a 1D array of string where the length of the array is 8" do
  #       result = fen_import_test.send(:normalise_fen_rank, standard_new_rank3)
  #       expect(result.size).to eq(8)
  #     end
  #   end

  #   context "when the value is a valid FEN string of rank 1 in an ongoing game" do
  #     let(:ongoing_game_board_rank1) { "r5rk" }

  #     it "returns a 1D array of string where empty tiles are replaced with 0 and each letters are separated" do
  #       result = fen_import_test.send(:normalise_fen_rank, ongoing_game_board_rank1)
  #       expect(result).to eq(%w[r 0 0 0 0 0 r k])
  #     end

  #     it "returns a 1D array of string where the length of the array is 8" do
  #       result = fen_import_test.send(:normalise_fen_rank, ongoing_game_board_rank1)
  #       expect(result.size).to eq(8)
  #     end
  #   end
  # end
end
