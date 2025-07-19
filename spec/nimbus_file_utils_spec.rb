# frozen_string_literal: true

require "paint"
require_relative "../lib/nimbus_file_utils/nimbus_file_utils"

F = NimbusFileUtils

describe NimbusFileUtils do
  describe "#proj_root" do
    it "returns the full path of the project directory" do
      local_path = File.expand_path("../", __dir__)
      expect(F.proj_root).to eq(local_path)
    end
  end

  describe "#formatted_filename" do
    context "when the value contains a single word" do
      it "returns the same word if the word is lowercase" do
        filename = "enterprise"
        expect(F.formatted_filename(filename)).to eq("enterprise")
      end

      it "returns the word in lowercase if it contains uppercase characters" do
        filename = "Defiant"
        expect(F.formatted_filename(filename)).to eq("defiant")
      end
    end

    context "when the value contains multiple words" do
      it "returns a value where whitespaces are replaced with underscores if all words are lowercase" do
        filename = "deep space nine"
        expect(F.formatted_filename(filename)).to eq("deep_space_nine")
      end

      it "returns a lowercase value where whitespaces are replaced with underscores if the value contains uppercase characters" do
        filename = "Bird of Prey"
        expect(F.formatted_filename(filename)).to eq("bird_of_prey")
      end
    end

    context "when the format parameter is used" do
      it "returns a value with the format suffix" do
        filename = "USS-Enterprise"
        type = ".yml"
        expect(F.formatted_filename(filename, type)).to eq("uss-enterprise.yml")
      end
    end

    context "when the value contains forbidden characters" do
      it "raises an argument error" do
        filename = "Bad<|/:|>+===N'amE"
        expect { F.formatted_filename(filename) }.to raise_error(ArgumentError, "Forbidden character detected")
      end
    end
  end

  describe "#filepath" do
    local_path = File.expand_path("../", __dir__)
    filename = "emh.md"

    context "when the argument only contains the filename" do
      it "returns the full project filepath" do
        filepath = "#{local_path}/#{filename}"
        expect(F.filepath(filename)).to eq(filepath)
      end
    end

    context "when the argument contains the filename and one dir argument" do
      it "returns the full project filepath" do
        subfolder = "sys"
        filepath = "#{local_path}/#{subfolder}/#{filename}"
        expect(F.filepath(filename, subfolder)).to eq(filepath)
      end
    end

    context "when the argument contains the filename and multiple dir arguments" do
      it "returns the full project filepath" do
        subfolder1 = "officers"
        subfolder2 = "science"
        filepath = "#{local_path}/#{subfolder1}/#{subfolder2}/#{filename}"
        expect(F.filepath(filename, subfolder1, subfolder2)).to eq(filepath)
      end
    end
  end

  describe "#file_exist?" do
    context "when a valid filepath is provided and default argument is used" do
      let(:valid_yaml_file) { F.filepath("debug_en", ".config", "locale") }

      it "is a valid filepath, returns true" do
        expect(F.file_exist?(valid_yaml_file)).to be true
      end
    end

    context "when a valid filepath is provided and type argument is set to '.json'" do
      let(:valid_json_file) { F.filepath("debug_en", ".config", "locale") }

      it "is a valid filepath, return true" do
        skip "To update"
        expect(F.file_exist?(valid_json_file, type: ".json")).to be true
      end
    end

    context "when a valid filepath is provided and filetype suffix is set to false" do
      let(:valid_yaml_file) { F.filepath("debug_en.yml", ".config", "locale") }

      it "is a valid filepath, return true" do
        expect(F.file_exist?(valid_yaml_file, use_filetype: false)).to be true
      end
    end

    context "when an invalid filepath is provided and default argument is used" do
      let(:invalid_yaml_file) { F.filepath("debug_en", ".config") }

      it "is not a valid filepath, return false" do
        expect(F.file_exist?(invalid_yaml_file)).to be false
      end
    end
  end

  describe "#load_file" do
    let(:valid_yaml_file) { F.filepath("debug_en", ".config", "locale") }
    let(:valid_json_file) { F.filepath("debug_en", ".config", "locale") }

    context "when target file is a yaml and symbol keys format is set true" do
      symbol_hash = { debug_en: { test_msg: "Hello, you are using the debug_en.yml text file.", test_msg2: "This is %{adj}!", test_array: [{ obj: "nested" }, 123, ".yml"] } }
      it "returns a hash with symbols as keys" do
        skip "To update"
        expect(F.load_file(valid_yaml_file)).to eq(symbol_hash)
      end
    end

    context "when target file is a yaml and symbol keys format is set false" do
      string_hash = { "debug_en" => { "test_msg" => "Hello, you are using the debug_en.yml text file.", "test_msg2" => "This is %{adj}!", "test_array" => [{ "obj" => "nested" }, 123, ".yml"] } }
      it "returns a hash with string as keys" do
        skip "To update"
        expect(F.load_file(valid_yaml_file, symbols: false)).to eq(string_hash)
      end
    end

    context "when target file is a json and symbol keys format is set true" do
      symbol_hash = { debug_en: { test_msg: "Hello, you are using the debug_en.json text file.", test_msg2: "This is %{adj}!", test_array: [{ obj: "nested" }, 123, ".json"] } }
      it "returns a hash with symbols as keys" do
        skip "To update"
        expect(F.load_file(valid_yaml_file, format: :json)).to eq(symbol_hash)
      end
    end

    context "when target file is a json and symbol keys format is set false" do
      string_hash = { "debug_en" => { "test_msg" => "Hello, you are using the debug_en.json text file.", "test_msg2" => "This is %{adj}!", "test_array" => [{ "obj" => "nested" }, 123, ".json"] } }
      it "returns a hash with string as keys" do
        skip "To update"
        expect(F.load_file(valid_yaml_file, format: :json, symbols: false)).to eq(string_hash)
      end
    end

    context "when argument is invalid" do
      it "raises an argument error if an incorrect format symbol is provided" do
        skip "To update"
        expect { F.load_file(valid_yaml_file, format: :txt) }.to raise_error(ArgumentError, "Invalid format key: only :yml or :json is accepted")
      end

      it "prints a warning on the console with filepath attached if file does not exist" do
        skip "To update"
        path = F.filepath("bad_file")
        expect { F.load_file(path, format: :yml) }.to output("File not found: #{path}.yml\n").to_stdout
      end
    end
  end

  describe "#get_string" do
    F.set_locale("debug_en")
    context "when file is yaml" do
      before { F.instance_variable_set(:@strings, nil) }

      it "returns the target string if the key is valid" do
        str_key = "test_msg"
        result = F.get_string(str_key)
        expect(result).to eq("Hello, you are using the debug_en.yml text file.")
      end

      it "returns the target string if the key is valid and the is pointing to an array object" do
        str_key = "test_array"
        result = F.get_string(str_key)
        expect(result[1]).to eq(123)
      end

      it "returns missing string warning if the key is invalid" do
        str_key = "bad_msg"
        result = F.get_string(str_key)
        expect(result).to eq("Missing string: 'bad_msg'")
      end
    end

    context "when file is json" do
      before { F.instance_variable_set(:@strings, nil) }

      it "returns the target string if the key is valid" do
        skip "To update"
        str_key = "test_msg"
        result = F.get_string(str_key, format: :json)
        expect(result).to eq("Hello, you are using the debug_en.json text file.")
      end

      it "returns the target string if the key is valid and the is pointing to an array object" do
        skip "To update"
        str_key = "test_array"
        result = F.get_string(str_key, format: :json)
        expect(result[1]).to eq(123)
      end

      it "returns missing string warning if the key is invalid" do
        skip "To update"
        str_key = "bad_msg"
        result = F.get_string(str_key, format: :json)
        expect(result).to eq("Missing string: 'bad_msg'")
      end
    end
  end

  # describe "#s" do
  #
  # end
end
