# frozen_string_literal: true

require_relative "../../../lib/console_game/game_manager"
require_relative "../../../lib/console_game/chess/player/chess_player"
require_relative "../../../lib/console_game/chess/level"
require_relative "../../../lib/console_game/chess/input/chess_input"
require_relative "../../../lib/nimbus_file_utils/nimbus_file_utils"

describe ConsoleGame::Chess::ChessInput do
  NimbusFileUtils.set_locale("en")
  subject(:chess_input_test) { described_class.new(game_manager) }

  let(:game_manager) { instance_double(ConsoleGame::GameManager) }
  let(:level) { instance_double(ConsoleGame::Chess::Level) }

  before do
    allow($stdout).to receive(:puts)
  end

  describe "#turn_action" do
    let(:player) { instance_double(ConsoleGame::Chess::ChessPlayer) }

    context "when input scheme is set to check for Smith notation" do
      it "calls the preview_move method in ChessPlayer class if value is h8" do
        allow(Readline).to receive(:readline).and_return("h8")
        allow(player).to receive(:preview_move).and_return(true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:preview_move).with("h8")
      end

      it "calls the direct_move method in ChessPlayer class if value is e2e4" do
        allow(Readline).to receive(:readline).and_return("e2e4")
        allow(player).to receive(:direct_move).and_return(true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:direct_move).with("e2", "e4")
      end

      it "calls the direct_preview method in ChessPlayer class if value is e7e8q" do
        allow(Readline).to receive(:readline).and_return("e7e8q")
        allow(player).to receive(:direct_promote).and_return(true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:direct_promote).with("e7", "e8", "q")
      end

      it "calls the invalid_input method in ChessPlayer class if value is empty" do
        allow(Readline).to receive(:readline).and_return("")
        allow(player).to receive(:invalid_input).and_return(true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:invalid_input).with("")
      end
    end

    context "when input scheme is set to check for Algebraic notation" do
      before do
        chess_input_test.input_scheme = chess_input_test.alg_reg
      end

      it "calls the fetch_and_move method in ChessPlayer class if value is e4" do
        allow(Readline).to receive(:readline).and_return("e4")
        allow(player).to receive_messages(side: :white, fetch_and_move: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:fetch_and_move).with(:white, :p, "e4")
      end

      it "calls the fetch_and_move method in ChessPlayer class if value is Nc3" do
        allow(Readline).to receive(:readline).and_return("Nc3")
        allow(player).to receive_messages(side: :white, fetch_and_move: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:fetch_and_move).with(:white, :n, "c3")
      end

      it "calls the direct_promote method in ChessPlayer class if value is a8=Q" do
        allow(Readline).to receive(:readline).and_return("a8=Q")
        allow(player).to receive_messages(side: :white, direct_promote: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:direct_promote).with("a7", "a8", :q)
      end

      it "calls the direct_promote method in ChessPlayer class if value is b8=R" do
        allow(Readline).to receive(:readline).and_return("b8=R")
        allow(player).to receive_messages(side: :white, direct_promote: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:direct_promote).with("b7", "b8", :r)
      end

      it "calls the direct_move method in ChessPlayer class if value is O-O-O and side is white" do
        allow(Readline).to receive(:readline).and_return("O-O-O")
        allow(player).to receive_messages(side: :white, direct_move: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:direct_move).with("e1", "c1")
      end

      it "calls the direct_move method in ChessPlayer class if value is O-O-O and side is black" do
        allow(Readline).to receive(:readline).and_return("O-O-O")
        allow(player).to receive_messages(side: :black, direct_move: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:direct_move).with("e8", "c8")
      end

      it "calls the direct_move method in ChessPlayer class if value is O-O and side is white" do
        allow(Readline).to receive(:readline).and_return("O-O")
        allow(player).to receive_messages(side: :white, direct_move: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:direct_move).with("e1", "g1")
      end

      it "calls the direct_move method in ChessPlayer class if value is O-O and side is black" do
        allow(Readline).to receive(:readline).and_return("O-O")
        allow(player).to receive_messages(side: :black, direct_move: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:direct_move).with("e8", "g8")
      end

      it "calls the invalid_input method in ChessPlayer class if value is empty" do
        allow(Readline).to receive(:readline).and_return("")
        allow(player).to receive_messages(side: :white, invalid_input: true)
        chess_input_test.turn_action(player)
        expect(player).to have_received(:invalid_input).with("")
      end
    end
  end

  describe "#make_a_move" do
    let(:player) { instance_double(ConsoleGame::Chess::ChessPlayer) }

    context "when input scheme is set to check for Smith notation" do
      it "calls the preview_move method in ChessPlayer class if value is h8" do
        allow(Readline).to receive(:readline).and_return("h8")
        allow(player).to receive(:move_piece).and_return(true)
        chess_input_test.make_a_move(player)
        expect(player).to have_received(:move_piece).with("h8")
      end

      it "calls the invalid_input method in ChessPlayer class if value is empty" do
        allow(Readline).to receive(:readline).and_return("")
        allow(player).to receive(:invalid_input).and_return(true)
        chess_input_test.make_a_move(player)
        expect(player).to have_received(:invalid_input).with("")
      end
    end
  end

  describe "#promote_a_pawn" do
    context "when input scheme is set to check for Smith notation" do
      it "returns a single letter string if input is q" do
        allow(Readline).to receive(:readline).and_return("q")
        result = chess_input_test.promote_a_pawn
        expect(result).to eq("q")
      end

      it "returns a single letter string if input is b" do
        allow(Readline).to receive(:readline).and_return("b")
        result = chess_input_test.promote_a_pawn
        expect(result).to eq("b")
      end

      it "returns a single letter string if input is r" do
        allow(Readline).to receive(:readline).and_return("r")
        result = chess_input_test.promote_a_pawn
        expect(result).to eq("r")
      end

      it "returns a single letter string if input is n" do
        allow(Readline).to receive(:readline).and_return("n")
        result = chess_input_test.promote_a_pawn
        expect(result).to eq("n")
      end
    end
  end

  describe "#quit" do
    context "when the method is called" do
      before do
        chess_input_test.instance_variable_set(:@level, level)
        allow(level).to receive(:update_session_moves)
        allow(level).to receive(:session).and_return({ date: "" })
        allow(game_manager).to receive(:save_user_profile)
        allow(game_manager).to receive(:exit_arcade).and_return(SystemExit)
      end

      it "exits the program" do
        expect(chess_input_test.quit).to be SystemExit
      end
    end
  end

  describe "#save" do
    context "when Chess Level object is nil" do
      it "changes the input scheme to detect Smith notation" do
        result = chess_input_test.save
        expect(result).to be_nil
      end
    end
  end

  describe "#load" do
    context "when Chess Level object is nil" do
      it "returns nil" do
        result = chess_input_test.load
        expect(result).to be_nil
      end
    end
  end

  describe "#export" do
    context "when Chess Level object is nil" do
      it "returns nil" do
        result = chess_input_test.export
        expect(result).to be_nil
      end
    end
  end

  describe "#smith" do
    context "when Chess Level object is present" do
      let(:real_level) { ConsoleGame::Chess::Level.new(chess_input_test, {}, {}) }

      it "changes the input scheme to detect Smith notation" do
        chess_input_test.instance_variable_set(:@level, real_level)
        chess_input_test.smith
        expect(chess_input_test.input_scheme).to eq(chess_input_test.smith_reg)
      end
    end

    context "when Chess Level object is nil" do
      it "returns nil" do
        result = chess_input_test.smith
        expect(result).to be_nil
      end
    end
  end

  describe "#alg" do
    context "when Chess Level object is present" do
      let(:real_level) { ConsoleGame::Chess::Level.new(chess_input_test, {}, {}) }

      it "changes the input scheme to detect Algebraic notation" do
        chess_input_test.instance_variable_set(:@level, real_level)
        chess_input_test.alg
        expect(chess_input_test.input_scheme).to eq(chess_input_test.alg_reg)
      end
    end

    context "when Chess Level object is nil" do
      it "returns nil" do
        result = chess_input_test.alg
        expect(result).to be_nil
      end
    end
  end

  describe "#board" do
    context "when Chess Level object is present" do
      let(:real_level) { ConsoleGame::Chess::Level.new(chess_input_test, { white: "nil", black: "nil" }, {}) }

      before do
        allow(real_level.board).to receive(:adjust_board_size)
        allow(real_level.board).to receive(:flip_setting)
      end

      it "update the board size if the optional argument is size" do
        chess_input_test.instance_variable_set(:@level, real_level)
        real_level.board.flip_board = false
        chess_input_test.board(["size"])
        expect(real_level.board).to have_received(:adjust_board_size)
      end

      it "update the board size if the optional argument is flip" do
        chess_input_test.instance_variable_set(:@level, real_level)
        chess_input_test.board(["flip"])
        expect(real_level.board).to have_received(:flip_setting)
      end

      it "returns nil and prints a user warning if optional argument is invalid" do
        chess_input_test.instance_variable_set(:@level, real_level)
        result = chess_input_test.board(["abc"])
        expect(result).to be_nil
      end
    end

    context "when Chess Level object is nil" do
      it "returns nil" do
        result = chess_input_test.board
        expect(result).to be_nil
      end
    end
  end
end
