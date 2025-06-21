# frozen_string_literal: true

require "securerandom"
require_relative "file_utils"

module ConsoleGame
  # User Profile class
  class UserProfile
    attr_accessor :username

    def initialize(username = "Arcade Player")
      @username = username
    end

    # Create a user profile
    def create_profile
      { uuid: SecureRandom.uuid, username: username, saved_date: Time.now.ceil, appdata: nil, stats: nil }
    end
  end
end
