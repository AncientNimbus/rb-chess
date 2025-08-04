# frozen_string_literal: true

require "time"
require_relative "chess_utils"
require_relative "pgn_utils"
require_relative "../../../nimbus_file_utils/nimbus_file_utils"

module ConsoleGame
  module Chess
    # PGN Export is a class that focuses on converting internal game data to PGN file standard
    # @author Ancient Nimbus
    class PgnExport
      include ChessUtils
      include ::PgnUtils
      include ::NimbusFileUtils

      # PGN Export method entry point
      # @return [Hash]
      def self.export_session(...) = new(...).export_session

      # @!attribute [r] session
      #   @return [Hash] game session data
      attr_reader :session, :date, :sub_path, :filename, :path

      # Alias for NimbusFileUtils
      F = NimbusFileUtils

      def initialize(session)
        @date = session[:date]
        @session = session.slice(*TAGS.keys, :moves)
        @sub_path = %w[user_data pgn_export]
      end

      # Export session as pgn file
      # @param session [Hash] expects a single chess session, invalid moves data will result operation being cancelled.
      # @return [Hash]
      def export_session
        process_time_field
        pgn_filepath
        export_data = to_pgn
        F.write_to_disk(path, export_data)
        { path:, filename:, export_data: }
      end

      private

      # Create file name and return full file path
      def pgn_filepath
        name = build_name
        begin
          make_filename(name)
          make_filepath
          append_file_num(name)
        rescue ArgumentError
          name = handle_filename_err
          retry
        end
      end

      # Format filename
      # @param name [String]
      def make_filename(name) = @filename = F.formatted_filename(name, DOT_PGN)

      # Format filepath
      def make_filepath = @path = F.filepath(filename, *sub_path)

      # Append number suffix if file exist
      # @param name [String]
      def append_file_num(name)
        count = 0
        while F.file_exist?(path, use_filetype: false)
          count += 1
          make_filename("#{name}_#{count}")
          make_filepath
        end
      end

      # Error handling when forbidden character is found in filename
      # Likely due to my #formatted_filename method is a little too strict
      # @return [String] default name
      def handle_filename_err
        puts "\n! Forbidden characters found in event name, a default filename will be used."
        "chess session"
      end

      # Returns PGN ready string
      # @return [String]
      def to_pgn = PgnUtils.to_pgn(session.slice(*TAGS.keys, :moves))

      # Helper to revert string time back to Time object
      def process_time_field = session[:date] = Time.strptime(date, STR_TIME)

      # Format filename
      def build_name = "#{session[:event]}_#{session[:date].strftime('%Y_%m_%d')}"
    end
  end
end
