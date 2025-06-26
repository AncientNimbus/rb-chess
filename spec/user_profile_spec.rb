# frozen_string_literal: true

require_relative "../lib/console_game/user_profile"

describe ConsoleGame::UserProfile do
  describe "#create_profile" do
    let(:username) { "Test User" }
    subject(:user) { described_class.new(username) }

    context "when the method is called" do
      it "generate a unique uuid" do
        Random.srand(42)
        random_id = Random.uuid
        result = user.create_profile
        expect(result.fetch(:uuid)).to_not eq(random_id)
      end

      it "saved_date field should be a Time object" do
        result = user.create_profile
        expect(result.fetch(:saved_date).class).to eq(Time)
      end
    end

    context "when a username is provided" do
      it "uses provided username instead of default value" do
        result = user.create_profile
        expect(result.fetch(:username)).to eq(username)
      end
    end

    context "when a username is not provided" do
      subject(:user) { described_class.new }
      it "uses provided username instead of default value" do
        result = user.create_profile
        expect(result.fetch(:username)).to eq("Arcade Player")
      end
    end
  end
end
