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
        export_data = to_pgn
        F.write_to_disk(pgn_filepath, export_data)
        { path:, filename:, export_data: }
      end

      private

      # Create file name and return full file path
      # @return [String] valid filepath
      def pgn_filepath
        name = build_name
        count = 0
        @filename = F.formatted_filename(name, DOT_PGN)
        @path = F.filepath(filename, *sub_path)
        while F.file_exist?(path, use_filetype: false)
          count += 1
          @filename = F.formatted_filename("#{name}_#{count}", DOT_PGN)
          @path = F.filepath(filename, *sub_path)
        end
        path
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
