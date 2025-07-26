# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/utilities/session_utils"
require_relative "../../../lib/console_game/chess/chess_player"
require_relative "../../../lib/console_game/chess/chess_computer"
# require_relative "../../../lib/console_game/chess/utilities/fen_export"

describe ConsoleGame::Chess::SessionUtils do
  subject(:session_utils_test) { dummy_class.new }

  let(:chess_player) { ConsoleGame::Chess::ChessPlayer }
  let(:chess_computer) { ConsoleGame::Chess::ChessComputer }

  let(:dummy_class) do
    Class.new do
      include ConsoleGame::Chess::SessionUtils
    end
  end

  describe "#assign_sides" do
    context "when player 1 side is white" do
      let(:player_one) { instance_double(chess_player, side: :white) }
      let(:player_two) { instance_double(chess_player, side: :black) }

      it "returns a players assignment hash where player 1 is white and player 2 is black" do
        result = session_utils_test.send(:assign_sides, player_one, player_two)
        expect(result).to eq({ white: player_one, black: player_two })
      end
    end

    context "when player 1 side is black" do
      let(:player_one) { instance_double(chess_player, side: :black) }
      let(:player_two) { instance_double(chess_player, side: :white) }

      it "returns a players assignment hash where player 1 is black and player 2 is white" do
        result = session_utils_test.send(:assign_sides, player_one, player_two)
        expect(result).to eq({ white: player_two, black: player_one })
      end
    end
  end

  describe "#sessions_list" do
    context "when each session in the data hash contains event as String and date as Time" do
      let(:valid_hash) do
        { "1": { event: "Player 1 vs Player 2", date: Time.new(2025, 7, 1), mode: 1 },
          "2": { event: "Player 1 vs Player 2", date: Time.new(2025, 7, 2), mode: 2 } }
      end

      it "returns the hash with two fields where event is a string and date is a formatted string" do
        result = session_utils_test.send(:sessions_list, valid_hash)
        expect(result).to eq({ "1": { date: "07/01/2025 12:00 AM", event: "Player 1 vs Player 2" },
                               "2": { date: "07/02/2025 12:00 AM", event: "Player 1 vs Player 2" } })
      end
    end

    context "when each session in the data hash contains event as String and date as String" do
      let(:valid_hash) do
        { "1": { event: "Player 1 vs Player 2", date: "2025-07-25 12:31:45 +0100", mode: 1 },
          "2": { event: "Player 1 vs Player 2", date: "2025-07-26 12:31:45 +0100", mode: 2 } }
      end

      it "returns the hash with two fields where event is a string and date is a formatted string" do
        result = session_utils_test.send(:sessions_list, valid_hash)
        expect(result).to eq({ "1": { date: "07/25/2025 12:31 PM", event: "Player 1 vs Player 2" },
                               "2": { date: "07/26/2025 12:31 PM", event: "Player 1 vs Player 2" } })
      end
    end
  end
end
