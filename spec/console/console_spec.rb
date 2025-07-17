# frozen_string_literal: true

require_relative "../../lib/console/console"

describe Console do
  subject(:console_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include Console } }

  describe "#build_table" do
    context "when table name is List of Sessions, column 1 is event data, and column 2 is a date data" do
      let(:head) { "List of Sessions" }
      let(:data) do
        {
          "1": { "event": "Q vs Picard", "date": Time.new(2025, 7, 10).strftime("%m/%d/%Y %I:%M %p") },
          "2": { "event": "Spock vs Data", "date": Time.new(2025, 7, 15).strftime("%m/%d/%Y %I:%M %p") },
          "3": { "event": "Voyager vs Enterprise", "date": Time.new(2025, 7, 18).strftime("%m/%d/%Y %I:%M %p") }
        }
      end

      let(:expected_output) do
        [
          "List of Sessions",
          "---------------------------------------------------------------------------",
          "Event                                                 | Date",
          "---------------------------------------------------------------------------",
          "* [1] - Q vs Picard                                     07/10/2025 12:00 AM",
          "* [2] - Spock vs Data                                   07/15/2025 12:00 AM",
          "* [3] - Voyager vs Enterprise                           07/18/2025 12:00 AM"
        ]
      end

      it "returns a table in a form of a string" do
        result = console_test.build_table(head: head, data: data)
        expect(result).to eq(expected_output)
      end
    end

    context "when arguements contain non-string element" do
      let(:head) { "List of Sessions" }
      let(:data) do
        {
          "1": { "event": "Q vs Picard", "date": Time.new(2025, 7, 10) },
          "2": { "event": "Spock vs Data", "date": Time.new(2025, 7, 15) }
        }
      end

      let(:expected_output) { "Non-string elements found, ops cancelled." }

      it "returns an user warning and exit the method early" do
        result = console_test.build_table(head: head, data: data)
        expect(result).to eq(expected_output)
      end
    end
  end
end
