# frozen_string_literal: true

require_relative "../lib/pgn_utils"

describe PgnUtils do
  describe "#to_pgn" do
    context "when session is a valid PGN ready hash" do
      it "returns a string containing seven tags roaster and moves sequence" do
      end

      it "returns a string containing moves sequence when seven tags roaster is incomplete" do
      end
    end

    context "when session is invalid" do
      it "returns nil when moves is missing" do
      end

      it "returns nil when moves sequence is invalid" do
      end
    end
  end

  describe "#format_metadata" do
    context "when key is a Symbol" do
      it "changes to a capitalize string" do
      end
    end

    context "when value is a String object" do
      it "returns a formatted string value" do
      end
    end

    context "when value is a Numeric object" do
      it "returns a formatted string value" do
      end
    end

    context "when value is a Time object" do
      it "returns a formatted date as string value" do
      end
    end

    context "when value is other data types" do
      it "returns a formatted string value" do
      end
    end
  end

  describe "#format_moves" do
    context "when moves is a valid hash with algebraic value pairs" do
      it "returns a valid PGN format as string" do
      end
    end
  end
end
