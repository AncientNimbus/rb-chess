# frozen_string_literal: true

require_relative "../lib/pgn_utils"

describe PgnUtils do
  describe "#to_pgn" do
    context "when session is a valid PGN ready hash" do
      let(:formatted_moves) { { 1 => "Nf3 c5", 2 => "c4 Nf6", 3 => "g3 Nc6", 4 => "Bg2 d6", 5 => "Nc3 g6" } }
      let(:session) do
        { event: "ch-USA Seniors 2024", site: "Saint Louis USA", date: Time.new(2024, 7, 25), round: 9.2, white: "Akopian, Vl",
          black: "Benjamin, Joe", result: "1/2-1/2", moves: formatted_moves }
      end
      it "returns a string containing seven tags roaster and moves sequence" do
        pgn_data = <<~DATA
          [Event "ch-USA Seniors 2024"]
          [Site "Saint Louis USA"]
          [Date "2024.7.25"]
          [Round "9.2"]
          [White "Akopian, Vl"]
          [Black "Benjamin, Joe"]
          [Result "1/2-1/2"]

          1. Nf3 c5 2. c4 Nf6 3. g3 Nc6 4. Bg2 d6 5. Nc3 g6 1/2-1/2
        DATA
        result = PgnUtils.to_pgn(session)
        expect(result).to eq(pgn_data)
      end

      xit "returns a string containing moves sequence when seven tags roaster is incomplete" do
      end
    end

    context "when session is invalid" do
      xit "returns nil when moves is missing" do
      end

      xit "returns nil when moves sequence is invalid" do
      end
    end
  end

  describe "#format_metadata" do
    let(:key) { :event }
    context "when key is a Symbol" do
      let(:value) { "Test Event" }
      it "changes to a capitalize string" do
        result = PgnUtils.send(:format_metadata, key, value)
        expect(result).to eq('[Event "Test Event"]')
      end
    end

    context "when value is a String object" do
      let(:value) { "Test Event" }
      it "returns a formatted string value" do
        result = PgnUtils.send(:format_metadata, key, value)
        expect(result).to eq('[Event "Test Event"]')
      end
    end

    context "when value is a Numeric object" do
      let(:integer) { 2 }
      let(:float) { 4.2 }
      it "returns a formatted string value if it is an Integer" do
        result = PgnUtils.send(:format_metadata, key, integer)
        expect(result).to eq('[Event "2"]')
      end
      it "returns a formatted string value if it is an Float" do
        result = PgnUtils.send(:format_metadata, key, float)
        expect(result).to eq('[Event "4.2"]')
      end
    end

    context "when value is a Time object" do
      let(:time) { Time.now.ceil }
      it "returns a formatted date as string value" do
        result = PgnUtils.send(:format_metadata, key, time)
        expect(result).to eq("[Event \"#{time.year}.#{time.mon}.#{time.day}\"]")
      end
    end

    context "when value is other data types" do
      let(:arr) { [1, 2, 3] }
      it "returns a formatted string value if it is an Array" do
        result = PgnUtils.send(:format_metadata, key, arr)
        expect(result).to eq('[Event "[1, 2, 3]"]')
      end
    end
  end

  describe "#format_moves" do
    context "when moves is a valid hash with algebraic value pairs" do
      let(:moves) { { 1 => "Nf3 c5", 2 => "c4 Nf6", 3 => "g3 Nc6", 4 => "Bg2 d6", 5 => "Nc3 g6" } }
      it "returns a valid PGN format as Array" do
        result = PgnUtils.send(:format_moves, moves)
        expect(result).to eq(["1. Nf3 c5", "2. c4 Nf6", "3. g3 Nc6", "4. Bg2 d6", "5. Nc3 g6"])
      end
    end
  end
end
