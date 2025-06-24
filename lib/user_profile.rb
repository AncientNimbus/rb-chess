# frozen_string_literal: true

require "securerandom"
require_relative "file_utils"

module ConsoleGame
  # User Profile class
  class UserProfile
    attr_reader :profile
    attr_accessor :username

    def initialize(username = "")
      @username = username.empty? ? "Arcade Player" : username
      @profile = create_profile
    end

    # Create a user profile
    def create_profile
      { uuid: SecureRandom.uuid, username: username, saved_date: Time.now.ceil, appdata: {}, stats: {} }
    end
  end
end
