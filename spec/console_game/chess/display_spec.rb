# frozen_string_literal: true

require "paint"
require_relative "../../../lib/console_game/chess/logics/display"
require_relative "../../../lib/console_game/chess/pieces/chess_piece"
require_relative "../../../lib/console_game/chess/pieces/king"
require_relative "../../../lib/console_game/chess/pieces/queen"

describe ConsoleGame::Chess::Display do
  subject(:display_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::Display } }

  describe "#build_board" do
    context "when chessboard is empty" do
      let(:expected_value) do
        [
          "╔═══╦════════════════════════╦═══╗",
          "║ ◇ ║\e[39m a \e[0m\e[39m b \e[0m\e[39m c \e[0m\e[39m d \e[0m\e[39m e \e[0m\e[39m f \e[0m\e[39m g \e[0m\e[39m h \e[0m║ ◇ ║",
          "╠═══╬════════════════════════╬═══╣",
          "║ 8 ║\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m║ 8 ║",
          "║ 7 ║\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m║ 7 ║",
          "║ 6 ║\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m║ 6 ║",
          "║ 5 ║\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m║ 5 ║",
          "║ 4 ║\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m║ 4 ║",
          "║ 3 ║\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m║ 3 ║",
          "║ 2 ║\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m║ 2 ║",
          "║ 1 ║\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m\e[39;48;2;139;87;66m   \e[0m\e[39;48;2;205;170;125m   \e[0m║ 1 ║",
          "╠═══╬════════════════════════╬═══╣",
          "║ ◆ ║\e[39m a \e[0m\e[39m b \e[0m\e[39m c \e[0m\e[39m d \e[0m\e[39m e \e[0m\e[39m f \e[0m\e[39m g \e[0m\e[39m h \e[0m║ ◆ ║",
          "╚═══╩════════════════════════╩═══╝"
        ]
      end

      it "returns an array of string with ANSI codes applied as text colour and background colour values" do
        result = display_test.send(:build_board)
        # puts result
        expect(result).to eq(expected_value)
      end
    end
  end

  describe "#paint_tile" do
    context "when value is a King" do
      subject(:item) { ConsoleGame::Chess::King.new }

      let(:tile_w) { 3 }
      let(:bg_color) { "#8b5742" }

      it "returns a string with ANSI codes applied as text colour and background colour values" do
        result = display_test.send(:paint_tile, item, tile_w, bg_color)
        expect(result).to eq("\e[38;2;240;255;255;48;2;139;87;66m ♚ \e[0m")
      end
    end

    context "when value is a Queen" do
      subject(:item) { ConsoleGame::Chess::Queen.new }

      let(:tile_w) { 3 }
      let(:bg_color) { "#8b5742" }

      it "returns a string with ANSI codes applied as text colour and background colour values" do
        result = display_test.send(:paint_tile, item, tile_w, bg_color)
        expect(result).to eq("\e[38;2;240;255;255;48;2;139;87;66m ♛ \e[0m")
      end
    end

    context "when value is a Hash" do
      subject(:item) { { icon: "◇", color: "#00ff7f" } }

      let(:tile_w) { 3 }
      let(:bg_color) { "#8b5742" }

      it "returns a string with ANSI codes applied as text colour and background colour values" do
        result = display_test.send(:paint_tile, item, tile_w, bg_color)
        expect(result).to eq("\e[48;2;139;87;66m ◇ \e[0m")
      end
    end

    context "when value is a String" do
      subject(:item) { "X" }

      let(:tile_w) { 3 }
      let(:bg_color) { "#8b5742" }

      it "returns a string with ANSI codes applied as text colour and background colour values" do
        result = display_test.send(:paint_tile, item, tile_w, bg_color)
        expect(result).to eq("\e[39;48;2;139;87;66m X \e[0m")
      end
    end
  end

  describe "#to_quadratic" do
    context "when value is 1" do
      let(:value) { 1 }

      it "returns 3" do
        result = display_test.send(:to_quadratic, value)
        expect(result).to eq(3)
      end
    end

    context "when value is 2" do
      let(:value) { 2 }

      it "returns 7" do
        result = display_test.send(:to_quadratic, value)
        expect(result).to eq(7)
      end
    end

    context "when value is 3" do
      let(:value) { 3 }

      it "returns 13" do
        result = display_test.send(:to_quadratic, value)
        expect(result).to eq(13)
      end
    end
  end

  describe "#to_matrix" do
    context "when value is a 1D array and bound is 8" do
      let(:flat_arr) { [*1..63] }
      let(:expected_arr) do
        [
          [1, 2, 3, 4, 5, 6, 7, 8], [9, 10, 11, 12, 13, 14, 15, 16],
          [17, 18, 19, 20, 21, 22, 23, 24], [25, 26, 27, 28, 29, 30, 31, 32],
          [33, 34, 35, 36, 37, 38, 39, 40], [41, 42, 43, 44, 45, 46, 47, 48],
          [49, 50, 51, 52, 53, 54, 55, 56], [57, 58, 59, 60, 61, 62, 63]
        ]
      end

      it "returns a nested 2D array" do
        result = display_test.send(:to_matrix, flat_arr)
        expect(result).to eq(expected_arr)
      end
    end
  end
end
