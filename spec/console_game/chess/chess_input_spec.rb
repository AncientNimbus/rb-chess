# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/chess_player"
require_relative "../../../lib/console_game/chess/input/chess_input"
require_relative "../../../lib/nimbus_file_utils/nimbus_file_utils"

describe ConsoleGame::Chess::ChessInput do
  NimbusFileUtils.set_locale("en")
  subject(:chess_input_test) { described_class.new(:game_manger) }

  let(:game_manager) { instance_double(ConsoleGame::GameManager) }
  let(:level) { instance_double(ConsoleGame::Chess::Level) }

  describe "#turn_action" do
    let(:player) { instance_double(ConsoleGame::Chess::ChessPlayer) }

    before do
      allow($stdout).to receive(:puts)
    end

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

    before do
      allow($stdout).to receive(:puts)
    end

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
end
