# frozen_string_literal: true

require "yaml"
require "json"
require "paint"

# File operations helper module
# @author Ancient Nimbus
# @version 0.5.1
module NimbusFileUtils
  # Valid filename pattern
  FILENAME_REG = '[\sa-zA-Z0-9._-]+'
  class << self
    attr_accessor :locale, :locale_filename

    # Set program language
    # @param lang [String] default to English(en)
    # @param extname [String] default to `.yml`
    def set_locale(lang = "en", extname: ".yml")
      # localization target
      @locale = lang
      @locale_filename = formatted_filename(lang, extname)
    end

    # Return the root path.
    # @return [String] project root path
    def proj_root
      @proj_root ||= File.expand_path("../..", __dir__)
    end

    # Return cross-system friendly filename.
    # @param filename [String] file name
    # @param extname [String] file extension name
    # @return [String] Formatted filename
    def formatted_filename(filename, extname = "")
      raise ArgumentError, "Forbidden character detected" unless filename.match?(/\A[\sa-zA-Z0-9._-]+\z/)

      filename.downcase.tr(" ", "_") + extname
    end

    # Return the full path of a specific file.
    # @param filename [String]
    # @param dirs [Array<String>] `filepath("en", ".config", "locale")` will return <root...>/.config/locale/en
    def filepath(filename, *dirs)
      File.join(proj_root, *dirs, filename)
    end

    # Check if a file exist in the given file path.
    # @param filepath [String]
    # @param use_filetype [Boolean]
    # @param extname [String] file extension name
    def file_exist?(filepath, use_filetype: true, extname: ".yml")
      extname = "" unless use_filetype
      filepath += extname
      File.exist?(filepath)
    end

    # Returns a list of files within a given directory and file extensions
    # @param folder_path [String] folder path
    # @param extname [String] file extension name
    # @return [Array<String>]
    def file_list(folder_path, extname: ".yml")
      filenames = []
      Dir.new(folder_path).each_child { |entry| filenames << entry if File.extname(entry) == extname }
      filenames
    end

    # Writes the given data and save it to the specified file path.
    # @param filepath [String] The base path of the file to write (expects complete filepath with extension).
    # @param data [Object] The data to serialize and write.
    def write_to_disk(filepath, data) # rubocop:disable Metrics/MethodLength
      extname = File.extname(filepath)
      return "Operation error! File extension is missing." if extname.empty?

      File.open(filepath, "w") do |output|
        case extname
        when ".yml"
          return output.puts data.to_yaml
        when ".json"
          return output.puts data.to_json
        else
          return output.puts data
        end
      end
    end

    # Load file in YAML or JSON extension.
    # @param filepath [String] the base path of the file to write (extension is added automatically).
    # @param extname [String] set target file extension, default: `.yml`
    # @param symbols [Boolean] set whether to use symbols as key, default: true
    # @return [Hash]
    def load_file(filepath, extname: ".yml", symbols: true)
      raise ArgumentError, "Invalid extension: only .yml or .json is accepted" unless %w[.yml .json].include?(extname)

      return puts "File not found: #{filepath}" unless File.exist?(filepath)

      File.open(filepath, "r") do |file|
        data = extname == ".yml" ? handle_yaml(file) : handle_json(file)
        return symbols ? to_symbols(data) : data
      end
    end

    # Retrieves a localized string by key path from the specified locale file.
    # Returns a missing message if the locale or key is not found.
    # @param key_path [String] e.g., "welcome.greeting"
    # @param extname [String] set target file extension, default: `:yml`
    # @return [String]
    def get_string(key_path, extname: ".yml")
      path = filepath(locale_filename, ".config", "locale")
      @strings ||= load_file(path, extname: extname, symbols: false)

      locale_strings = @strings[locale]
      return "Missing locale: #{locale}" unless locale_strings

      keys = key_path.to_s.split(".")
      result = keys.reduce(locale_strings) do |val, key|
        val&.[](key)
      end

      result || "Missing string: '#{key_path}'"
    end

    private

    # Helper to handle yaml data
    # @param file [File]
    def handle_yaml(file)
      YAML.safe_load(file, permitted_classes: [Time, Symbol], aliases: true, freeze: true)
    end

    # Helper to handle json data
    # @param file [File]
    def handle_json(file)
      JSON.parse(file.read)
    end

    # Convert string keys to symbol keys.
    # @param obj [Object]
    # @return [Hash]
    def to_symbols(obj)
      case obj
      when Hash
        obj.transform_keys(&:to_sym).transform_values { |v| to_symbols(v) }
      when Array
        obj.map { |e| to_symbols(e) }
      else
        obj
      end
    end
  end

  # Pretty print a list of files with last modified date as metadata field
  # @param folder_path [String] folder path
  # @param filenames [Array<String>] filenames within the given directory
  # @param col1 [String] header name for the file name col
  # @param col2 [String] header name for the last modified name col
  # @param list_width [Integer] the width of the table
  def print_file_list(folder_path, filenames, col1: "List of Files", col2: "Last modified date", list_width: 80) # rubocop:disable Metrics/AbcSize
    puts "#{col1.ljust(list_width * 0.7)} | #{col2}"
    puts "-" * list_width
    filenames.each_with_index do |entry, i|
      prefix = "* [#{i + 1}] - "
      filename = File.basename(entry, File.extname(entry)).ljust(list_width * 0.6 - (prefix.size % 8))
      mod_time = File.new(folder_path + entry).mtime.strftime("%m/%d/%Y %I:%M %p")
      puts "#{prefix}#{filename} | #{mod_time}"
    end
  end

  # Retrieves a localized string and perform String interpolation and paint text if needed.
  # @param key_path [String] textfile keypath
  # @param subs [Hash] `{ demo: ["some text", :red] }`
  # @param paint_str [Array<Symbol, String, nil>]
  # @param extname [String]
  # @return [String] the translated and interpolated string
  def s(key_path, subs = {}, paint_str: [nil, nil], extname: ".yml")
    str = NimbusFileUtils.get_string(key_path, extname: extname)

    Paint % [str, *paint_str, subs]
  end

  # Textfile strings fetcher
  # @param sub [String] sub-head
  # @param keys [Array<String>] key
  # @return [Array<String>] array of textfile strings
  def tf_fetcher(sub, *keys, root: "")
    sub = ".#{sub}" unless sub.empty?
    keys.map { |key| s("#{root}#{sub}#{key}") }
  end
end
