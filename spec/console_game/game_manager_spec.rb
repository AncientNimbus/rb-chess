# frozen_string_literal: true

require_relative "../../lib/console_game/game_manager"

describe ConsoleGame::GameManager do
  subject(:game_manager_test) { described_class.new }

  describe "Test intro greet sequence" do
    context "when the program runs" do
      before do
        allow($stdout).to receive(:puts)
      end

      it "prints an intro and exit when the user type --exit" do
        allow(Readline).to receive(:readline).and_return("", "", "2", "1", "--load", "1", "--exit")

        expect { game_manager_test.run }.to raise_error(SystemExit)
      end
    end
  end
end
