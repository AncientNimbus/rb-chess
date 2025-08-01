# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/game"
require_relative "../../../lib/console_game/chess/level"
require_relative "../../../lib/console_game/user_profile"
require_relative "../../../lib/console_game/game_manager"
require_relative "../../../lib/nimbus_file_utils/nimbus_file_utils"

describe ConsoleGame::Chess::Game do
  NimbusFileUtils.set_locale("en")
  subject(:chess_manager) { described_class.new(game_manager) }

  let(:game_manager) { instance_double(ConsoleGame::GameManager, user: ConsoleGame::UserProfile.new) }
  let(:test_sessions) { { "1" => { event: "Chess Sessions Integration test", site: "Chess game menu", date: Time.new(2025, 7, 26), round: nil, white: "Ancient", black: "Nimbus", result: nil, mode: 1, moves: {}, fens: ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"], white_moves: [], black_moves: [] } } }
  let(:sides) { { white: ConsoleGame::Chess::ChessPlayer.new("Ancient", controller, :white), black: ConsoleGame::Chess::ChessPlayer.new("Nimbus", controller, :black) } }

  describe "Test new game session creation" do
    context "when user wishes to create a new game" do
      before do
        allow($stdout).to receive(:puts)
        chess_manager.instance_variable_set(:@sessions, test_sessions)
        allow(game_manager).to receive(:save_user_profile)
        allow(game_manager).to receive(:exit_arcade).and_raise(SystemExit)
      end

      it "opens level and exit successfully" do
        allow(Readline).to receive(:readline).and_return("", "", "", "1", "1", "", "", "1", "--help", "--help alg", "--help smith", "--exit")
        expect { chess_manager.start }.to raise_error(SystemExit)
      end
    end

    context "when user wishes to create a new game with computer player" do
      before do
        allow($stdout).to receive(:puts)
        chess_manager.instance_variable_set(:@sessions, test_sessions)
        allow(game_manager).to receive(:save_user_profile)
        allow(game_manager).to receive(:exit_arcade).and_raise(SystemExit)
      end

      it "opens level and exit successfully" do
        allow(Readline).to receive(:readline).and_return("", "", "", "1", "2", "", "2", "--exit")
        expect { chess_manager.start }.to raise_error(SystemExit)
      end
    end
  end

  describe "Test load game session" do
    context "when user wishes to load a valid ongoing game session" do
      before do
        allow($stdout).to receive(:puts)
        chess_manager.instance_variable_set(:@sessions, test_sessions)
        allow(game_manager).to receive(:save_user_profile)
        allow(game_manager).to receive(:exit_arcade).and_raise(SystemExit)
      end

      it "opens level and exit successfully" do
        allow(Readline).to receive(:readline).and_return("", "", "", "2", "1", "--exit")
        expect { chess_manager.start }.to raise_error(SystemExit)
      end
    end

    context "when user wishes to load a valid ongoing game session where opponent is a computer player" do
      let(:test_sessions) { { "1" => { event: "Chess Sessions Integration test", site: "Chess game menu", date: Time.new(2025, 7, 26), round: nil, white: "Ancient", black: "Computer", result: nil, mode: 2, moves: {}, fens: ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"], white_moves: [], black_moves: [] } } }

      before do
        allow($stdout).to receive(:puts)
        chess_manager.instance_variable_set(:@sessions, test_sessions)
        allow(game_manager).to receive(:save_user_profile)
        allow(game_manager).to receive(:exit_arcade).and_raise(SystemExit)
      end

      it "opens level and exit successfully" do
        allow(Readline).to receive(:readline).and_return("", "", "", "2", "1", "--exit")
        expect { chess_manager.start }.to raise_error(SystemExit)
      end
    end

    context "when user wishes to load an ongoing game session where the game mode is invalid" do
      let(:test_sessions) { { "1" => { event: "Chess Sessions Integration test", site: "Chess game menu", date: Time.new(2025, 7, 26), round: nil, white: "Ancient", black: "Computer", result: nil, mode: 3, moves: {}, fens: ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"], white_moves: [], black_moves: [] } } }

      before do
        allow($stdout).to receive(:puts)
        chess_manager.instance_variable_set(:@sessions, test_sessions)
        allow(chess_manager.level).to receive(:update_session_moves)
        allow(game_manager).to receive(:save_user_profile)
        allow(game_manager).to receive(:exit_arcade).and_raise(SystemExit)
      end

      it "exit load saves mode, enters new game mode and exit successfully" do
        allow(Readline).to receive(:readline).and_return("", "", "", "2", "1", "--exit")
        expect { chess_manager.start }.to raise_error(SystemExit)
      end
    end

    context "when user wishes to load an ongoing game session where computer opponent's name has been corrupted" do
      let(:test_sessions) { { "1" => { event: "Chess Sessions Integration test", site: "Chess game menu", date: Time.new(2025, 7, 26), round: nil, white: "Ancient", black: "Bad Computer", result: nil, mode: 2, moves: {}, fens: ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"], white_moves: [], black_moves: [] } } }

      before do
        allow($stdout).to receive(:puts)
        chess_manager.instance_variable_set(:@sessions, test_sessions)
        allow(chess_manager.level).to receive(:update_session_moves)
        allow(game_manager).to receive(:save_user_profile)
        allow(game_manager).to receive(:exit_arcade).and_raise(SystemExit)
      end

      it "exit load saves mode, enters new game mode and exit successfully" do
        allow(Readline).to receive(:readline).and_return("", "", "", "2", "1", "--exit")
        expect { chess_manager.start }.to raise_error(SystemExit)
      end
    end

    context "when user loads a valid ended game session" do
      let(:test_sessions) { { "1" => { event: "Chess Sessions Integration test", site: "Chess game menu", date: Time.new(2025, 7, 26), round: nil, white: "Ancient", black: "Nimbus", result: nil, mode: 1, moves: {}, fens: ["rnbqkbnr/ppppp2p/5p2/6pQ/8/4P3/PPPP1PPP/RNB1KBNR b KQkq - 1 1"], white_moves: [], black_moves: [] } } }

      before do
        allow($stdout).to receive(:puts)
        chess_manager.instance_variable_set(:@sessions, test_sessions)
        allow(game_manager).to receive(:save_user_profile)
        allow(game_manager).to receive(:exit_arcade).and_raise(SystemExit)
      end

      it "opens level and exit successfully" do
        allow(Readline).to receive(:readline).and_return("", "", "", "2", "1", "y", "--exit")
        expect { chess_manager.start }.to raise_error(SystemExit)
      end
    end
  end
end
