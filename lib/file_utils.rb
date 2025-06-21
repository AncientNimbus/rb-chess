# frozen_string_literal: true

require "yaml"
require "json"
require "paint"

# Filer operations helper module
# @author Ancient Nimbus
# @version 0.4.0
module NimbusFileUtils
  class << self
    attr_accessor :locale

    # Set program language
    # @param lang [String] default to English(en)
    def set_locale(lang = "en")
      # localization target
      @locale = lang
    end

    # Return the root path.
    # @return [String] project root path
    def proj_root
      @proj_root ||= File.expand_path("../", __dir__)
    end

    # Return cross-system friendly filename.
    # @param filename [String]
    # @return [String] Formatted filename
    def formatted_filename(filename, format = "")
      raise ArgumentError, "Forbidden character detected" unless filename.match?(/\A[\sa-zA-Z0-9._-]+\z/)

      filename.downcase.tr(" ", "_") + format
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
    # @param type [String]
    def file_exist?(filepath, use_filetype: true, type: ".yml")
      type = "" unless use_filetype
      filepath += type
      File.exist?(filepath)
    end

    # Load file in YAML or JSON format.
    # @param filepath [String] the base path of the file to write (extension is added automatically).
    # @param format [Symbol] set target file format, default: `:yml`
    # @param symbols [Boolean] set whether to use symbols as key, default: true
    # @return [Hash]
    def load_file(filepath, format: :yml, symbols: true)
      raise ArgumentError, "Invalid format key: only :yml or :json is accepted" unless %i[yml json].include?(format)

      filepath += format == :yml ? ".yml" : ".json"
      return puts "File not found: #{filepath}" unless File.exist?(filepath)

      File.open(filepath, "r") do |str|
        data = if format == :yml
                 YAML.safe_load(str, permitted_classes: [Time, Symbol], aliases: true, freeze: true)
               else
                 JSON.parse(str.read)
               end
        return symbols ? to_symbols(data) : data
      end
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

    # Retrieves a localized string by key path from the specified locale file.
    # Returns a missing message if the locale or key is not found.
    # @param key_path [String] e.g., "welcome.greeting"
    # @param format [Symbol] set target file format, default: `:yml`
    # @return [String]
    def get_string(key_path, format: :yml)
      path = filepath(locale, ".config", "locale")
      @strings ||= load_file(path, format: format, symbols: false)

      locale_strings = @strings[locale]
      return "Missing locale: #{locale}" unless locale_strings

      keys = key_path.to_s.split(".")
      result = keys.reduce(locale_strings) do |val, key|
        val&.[](key)
      end

      result || "Missing string: '#{key_path}'"
    end

    # Retrieves a localized string and perform String interpolation and paint text if needed.
    # @param key_path [String]
    # @param subs [Hash]
    # @param paint_str [Array<Symbol, String, nil>]
    # @param format [Symbol]
    # @return [String] the translated and interpolated string
    def s(key_path, subs = {}, paint_str: [nil, nil], format: :yml)
      str = get_string(key_path, format: format)

      Paint % [str, *paint_str, subs]
    end
  end
end
