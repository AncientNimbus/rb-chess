# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/input/smith_notation"

describe ConsoleGame::Chess::SmithNotation do
  subject(:smith_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::SmithNotation } }

  describe "#validate_smith" do
    context "when input value is a valid entry to trigger preview move" do
      it "returns a command pattern hash where type is preview_move and position is extracted into an Array" do
        input = "e2"
        result = smith_test.send(:validate_smith, input)
        expect(result).to eq({ type: :preview_move, args: ["e2"] })
      end
    end

    context "when input value is a valid entry to trigger direct move" do
      it "returns a command pattern hash where type is direct_move and position is extracted into an Array" do
        input = "e2e4"
        result = smith_test.send(:validate_smith, input)
        expect(result).to eq({ type: :direct_move, args: %w[e2 e4] })
      end
    end

    context "when input value is a valid entry to trigger direct promote" do
      it "returns a command pattern hash where type is direct_promote and position is extracted into an Array" do
        input = "e7e8q"
        result = smith_test.send(:validate_smith, input)
        expect(result).to eq({ type: :direct_promote, args: %w[e7 e8 q] })
      end
    end

    context "when input value is invalid" do
      it "returns a command pattern hash where type is invalid_input and input value is store into an Array" do
        input = "Invalid"
        result = smith_test.send(:validate_smith, input)
        expect(result).to eq({ type: :invalid_input, args: ["Invalid"] })
      end
    end
  end

  describe "#regexp_smith" do
    context "when the method is call" do
      it "returns a regular expression pattern for Smith notation as string" do
        result = smith_test.send(:regexp_smith)
        expect(result).to eq("(?:[a-h][1-8])|(?:[a-h][1-8]){2}(?:[qrbn])?")
      end
    end
  end
end
