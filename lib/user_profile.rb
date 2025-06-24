# frozen_string_literal: true

require "securerandom"
require_relative "file_utils"

module ConsoleGame
  # User Profile class
  class UserProfile
    attr_reader :profile, :filepath
    attr_accessor :username

    def initialize(username = "", user_profile = nil)
      @username = username.empty? ? "Arcade Player" : username
      @profile = user_profile.nil? ? create_profile : user_profile
    end

    # Create a user profile
    def create_profile
      { uuid: SecureRandom.uuid, username: username, saved_date: Time.now.ceil, appdata: {}, stats: {} }
    end

    # Save user profile
    def save_profile(format: :json)
      filename ||= F.formatted_filename(username)
      @filepath ||= F.filepath(filename, "user_data")
      F.write_to_disk(filepath, profile, format: format)
    end

    # load user profile
    def load_profile(format: :json)
      data = F.load_file(filepath, format: format)
      p data
    end
  end
end
