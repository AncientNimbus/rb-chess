# frozen_string_literal: true

require "securerandom"
require_relative "../nimbus_file_utils/nimbus_file_utils"

module ConsoleGame
  # User Profile class
  class UserProfile
    attr_reader :profile, :filepath
    attr_accessor :username

    def initialize(username = "", user_profile = nil)
      @username = username.empty? ? "Arcade Player" : username
      @profile = user_profile.nil? ? create_profile : load_profile(user_profile)
    end

    # Create a user profile
    def create_profile
      { uuid: SecureRandom.uuid, username: username, saved_date: Time.now.ceil, appdata: {}, stats: {} }
    end

    # Save user profile
    def save_profile(extname: ".json")
      filename ||= F.formatted_filename(username, extname)
      @filepath ||= F.filepath(filename, "user_data")

      profile[:saved_date] = Time.now.ceil
      F.write_to_disk(filepath, profile)
    end

    # load user profile
    def load_profile(user_profile, _extname: ".json")
      integrity_check(user_profile)
    end

    private

    # Profile integrity check
    def integrity_check(imported_profile)
      imported_profile[:saved_date] = to_time(imported_profile[:saved_date])
      imported_profile
    end

    # convert string time field to TIme object for internal use
    # @param str_date [String] expects a valid date format
    def to_time(str_date)
      return str_date if str_date.is_a?(Time)

      Time.new(str_date)
    end
  end
end
