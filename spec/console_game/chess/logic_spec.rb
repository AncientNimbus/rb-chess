# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/logics/logic"

describe ConsoleGame::Chess::Logic do
  subject(:logic_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::Logic } }

  describe "#all_paths" do
    context "when position is 27 and the requested movements directions are set to all with all ranges set to max" do
      subject(:movements) { { n: :max, ne: :max, e: :max, se: :max, s: :max, sw: :max, w: :max, nw: :max } }

      let(:pos) { 27 }

      it "returns a hash of integer arrays where directions are use as keys" do
        result = logic_test.send(:all_paths, movements, pos)
        expect(result).to eq({ e: [27, 28, 29, 30, 31], n: [27, 35, 43, 51, 59], ne: [27, 36, 45, 54, 63], nw: [27, 34, 41, 48], s: [27, 19, 11, 3], se: [27, 20, 13, 6], sw: [27, 18, 9, 0], w: [27, 26, 25, 24] })
      end
    end

    context "when position is 27 and the requested movements directions are set to all with all ranges set to 1" do
      subject(:movements) { { n: 1, ne: 1, e: 1, se: 1, s: 1, sw: 1, w: 1, nw: 1 } }

      let(:pos) { 27 }

      it "returns a hash of integer arrays where directions are use as keys" do
        result = logic_test.send(:all_paths, movements, pos)
        expect(result).to eq({ e: [27, 28], n: [27, 35], ne: [27, 36], nw: [27, 34], s: [27, 19], se: [27, 20], sw: [27, 18], w: [27, 26] })
      end
    end

    context "when position is 28 and the requested movements directions are set to diagonal with all ranges set to max" do
      subject(:movements) { { n: nil, ne: :max, e: nil, se: :max, s: nil, sw: :max, w: nil, nw: :max } }

      let(:pos) { 28 }

      it "returns a hash of integer arrays where directions are use as keys" do
        result = logic_test.send(:all_paths, movements, pos)
        expect(result).to eq({ ne: [28, 37, 46, 55], nw: [28, 35, 42, 49, 56], se: [28, 21, 14, 7], sw: [28, 19, 10, 1] })
      end
    end

    context "when position is 0 and the requested movements directions are set to horizontal and vertical with all ranges set to max" do
      subject(:movements) { { n: :max, ne: nil, e: :max, se: nil, s: :max, sw: nil, w: :max, nw: nil } }

      let(:pos) { 0 }

      it "returns a hash of integer arrays where directions are use as keys" do
        result = logic_test.send(:all_paths, movements, pos)
        expect(result).to eq({ e: [0, 1, 2, 3, 4, 5, 6, 7], n: [0, 8, 16, 24, 32, 40, 48, 56] })
      end
    end
  end

  describe "#path" do
    context "when position is 27 and the requested direction is set to east with range set to max" do
      let(:pos) { 27 }
      let(:path) { :e }
      let(:range) { :max }

      it "returns an integer array" do
        result = logic_test.send(:path, pos, path, range: range)
        expect(result).to eq([27, 28, 29, 30, 31])
      end
    end

    context "when position is 0 and the requested direction is set to north east with range set to max" do
      let(:pos) { 0 }
      let(:path) { :ne }
      let(:range) { :max }

      it "returns an integer array" do
        result = logic_test.send(:path, pos, path, range: range)
        expect(result).to eq([0, 9, 18, 27, 36, 45, 54, 63])
      end
    end

    context "when position is 63 and the requested direction is set to south with range set to 1" do
      let(:pos) { 63 }
      let(:path) { :s }
      let(:range) { 1 }

      it "returns an integer array" do
        result = logic_test.send(:path, pos, path, range: range)
        expect(result).to eq([63, 55])
      end
    end

    context "when position is 63 and the requested direction is set to north with range set to 1" do
      let(:pos) { 63 }
      let(:path) { :n }
      let(:range) { :max }

      it "returns an empty array" do
        result = logic_test.send(:path, pos, path, range: range)
        expect(result).to eq([])
      end
    end

    context "when position is 63 and the requested direction is set to south west with range set to nil" do
      let(:pos) { 63 }
      let(:path) { :sw }
      let(:range) { :nil }

      it "returns an empty array" do
        result = logic_test.send(:path, pos, path, range: range)
        expect(result).to eq([])
      end
    end
  end

  describe "#alg_map" do
    let(:alg_map) { { a1: 0, a2: 8, a3: 16, a4: 24, a5: 32, a6: 40, a7: 48, a8: 56, b1: 1, b2: 9, b3: 17, b4: 25, b5: 33, b6: 41, b7: 49, b8: 57, c1: 2, c2: 10, c3: 18, c4: 26, c5: 34, c6: 42, c7: 50, c8: 58, d1: 3, d2: 11, d3: 19, d4: 27, d5: 35, d6: 43, d7: 51, d8: 59, e1: 4, e2: 12, e3: 20, e4: 28, e5: 36, e6: 44, e7: 52, e8: 60, f1: 5, f2: 13, f3: 21, f4: 29, f5: 37, f6: 45, f7: 53, f8: 61, g1: 6, g2: 14, g3: 22, g4: 30, g5: 38, g6: 46, g7: 54, g8: 62, h1: 7, h2: 15, h3: 23, h4: 31, h5: 39, h6: 47, h7: 55, h8: 63 } }

    it "returns a hash with algebraic notation as keys, positional grid number as values" do
      result = logic_test.send(:alg_map)
      expect(result).to eq(alg_map)
    end
  end

  describe "#opposite_of" do
    context "when side is :white" do
      let(:side) { :white }

      it "returns :black" do
        result = logic_test.send(:opposite_of, side)
        expect(result).to eq(:black)
      end
    end

    context "when side is :black" do
      let(:side) { :black }

      it "returns :black" do
        result = logic_test.send(:opposite_of, side)
        expect(result).to eq(:white)
      end
    end

    context "when side is invalid" do
      let(:invalid_symbol) { :something_else }
      let(:not_a_symbol) { ":white" }

      it "returns nil if symbol is :something_else" do
        result = logic_test.send(:opposite_of, invalid_symbol)
        expect(result).to be_nil
      end

      it "returns nil" do
        result = logic_test.send(:opposite_of, not_a_symbol)
        expect(result).to be_nil
      end
    end
  end

  describe "#pathfinder" do
    context "when starting value is 0, and bound is a 8 x 8 grid, requesting an array with 8 elements" do
      start_value = 0
      arr = nil
      arr_length = 8
      bound = [8, 8]

      it "returns an empty array when direction is the north west" do
        direction = :nw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the north" do
        direction = :n
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([0, 8, 16, 24, 32, 40, 48, 56])
      end

      it "returns a sequence of positions to the north east" do
        direction = :ne
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([0, 9, 18, 27, 36, 45, 54, 63])
      end

      it "returns a sequence of positions to the east" do
        direction = :e
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([0, 1, 2, 3, 4, 5, 6, 7])
      end

      it "returns an empty array when direction is the south east" do
        direction = :se
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south" do
        direction = :s
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south west" do
        direction = :sw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the west" do
        direction = :w
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end
    end

    context "when starting value is 6, where bound and array size are using constant value set within the script (8 x 8 grid)" do
      start_value = 6
      arr = nil
      let(:preset) { ConsoleGame::Chess::Logic::PRESET }
      let(:arr_length) { 4 }
      let(:bound) { preset[:bound] }

      it "returns a sequence of positions to the north west" do
        direction = :nw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([6, 13, 20, 27])
      end

      it "returns a sequence of positions to the north" do
        direction = :n
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([6, 14, 22, 30])
      end

      it "returns an empty array when direction is the north east" do
        direction = :ne
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the east" do
        direction = :e
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south east" do
        direction = :se
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south" do
        direction = :s
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south west" do
        direction = :sw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the west" do
        direction = :w
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([6, 5, 4, 3])
      end
    end

    context "when starting value is 9, and bound is a 8 x 8 grid, requesting an array with max number of elements within bound" do
      start_value = 9
      arr = nil
      arr_length = :max
      bound = [8, 8]

      it "returns a sequence of positions to the north west" do
        direction = :nw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 16])
      end

      it "returns a sequence of positions to the north" do
        direction = :n
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 17, 25, 33, 41, 49, 57])
      end

      it "returns a sequence of positions to the north east" do
        direction = :ne
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 18, 27, 36, 45, 54, 63])
      end

      it "returns a sequence of positions to the east" do
        direction = :e
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 10, 11, 12, 13, 14, 15])
      end

      it "returns a sequence of positions to the south east" do
        direction = :se
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 2])
      end

      it "returns a sequence of positions to the south" do
        direction = :s
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 1])
      end

      it "returns a sequence of positions to the south west" do
        direction = :sw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 0])
      end

      it "returns a sequence of positions to the west" do
        direction = :w
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 8])
      end
    end

    context "when starting value is 32, and bound is a 8 x 8 grid, requesting an array with 4 elements" do
      start_value = 32
      arr = nil
      arr_length = 4
      bound = [8, 8]

      it "returns an empty array when direction is the north west" do
        direction = :nw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the north" do
        direction = :n
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 40, 48, 56])
      end

      it "returns a sequence of positions to the north east" do
        direction = :ne
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 41, 50, 59])
      end

      it "returns a sequence of positions to the east" do
        direction = :e
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 33, 34, 35])
      end

      it "returns a sequence of positions to the south east" do
        direction = :se
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 25, 18, 11])
      end

      it "returns a sequence of positions to the south" do
        direction = :s
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 24, 16, 8])
      end

      it "returns an empty array when direction is the south west" do
        direction = :sw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the west" do
        direction = :w
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end
    end

    context "when starting value is 38, and bound is a 8 x 8 grid, requesting an array with 5 elements" do
      start_value = 38
      arr = nil
      arr_length = 5
      bound = [8, 8]

      it "returns an empty array when direction is the north west" do
        direction = :nw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the north" do
        direction = :n
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the north east" do
        direction = :ne
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the east" do
        direction = :e
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south east" do
        direction = :se
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the south" do
        direction = :s
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([38, 30, 22, 14, 6])
      end

      it "returns a sequence of positions to the south west" do
        direction = :sw
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([38, 29, 20, 11, 2])
      end

      it "returns a sequence of positions to the west" do
        direction = :w
        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([38, 37, 36, 35, 34])
      end
    end

    context "when it is an edge case, and bound is a 8 x 8 grid" do
      arr = nil
      arr_length = 4
      bound = [8, 8]
      it "returns a sequence of positions to the east when no argument is provided" do
        result = logic_test.send(:pathfinder)
        expect(result).to eq([0, 1, 2, 3, 4, 5, 6, 7])
      end

      it "returns an empty array when starting value is larger than bound" do
        start_value = 64
        direction = :e

        result = logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when starting value is smaller than bound" do
        start_value = -1
        direction = :e

        expect do
          logic_test.send(:pathfinder, start_value, direction, arr, length: arr_length, bound: bound)
        end.to raise_error(ArgumentError, "#{start_value} is out of bound!")
      end

      it "raise an error when direction symbol is incorrect" do
        start_value = 41
        direction = :test
        expect do
          # logic_test.pathfinder(start_value, direction)
          logic_test.send(:pathfinder, start_value, direction)
        end.to raise_error(ArgumentError, "Invalid path: test")
      end
    end
  end

  describe "#out_of_bound?" do
    context "when value is negative, and bound is a 8 x 8 grid" do
      bound = [8, 8]
      it "returns true if value is -1" do
        value = -1
        result = logic_test.send(:out_of_bound?, value, bound)
        expect(result).to be true
      end
    end

    context "when value is positive and greater than bound, where bound is a 8 x 8 grid" do
      bound = [8, 8]
      it "returns true if value is 64" do
        value = 64
        result = logic_test.send(:out_of_bound?, value, bound)
        expect(result).to be true
      end
    end

    context "when value is positive and within bound, where bound is a 8 x 8 grid" do
      bound = [8, 8]
      it "returns false if value is 63" do
        value = 63
        result = logic_test.send(:out_of_bound?, value, bound)
        expect(result).to be false
      end
    end
  end

  describe "#not_adjacent?" do
    context "when direction is east and start value is 5, where bound is a 8 x 8 grid" do
      direction = :e
      it "returns true when the last array value is out of bound" do
        arr = [5, 6, 7, 8]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value of the previous value" do
        arr = [5, 7]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value of the previous value" do
        arr = [5, 6]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be false
      end
    end

    context "when direction is west and start value is 42, where bound is a 8 x 8 grid" do
      direction = :w
      it "returns true when the last array value is out of bound" do
        arr = [42, 41, 40, 39]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value of the previous value" do
        arr = [42, 40]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value of the previous value" do
        arr = [42, 41]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be false
      end
    end

    context "when direction is north east and start value is 29, where bound is a 8 x 8 grid" do
      direction = :ne
      it "returns true when the last array value is out of bound" do
        arr = [29, 38, 47, 56]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value one row above" do
        arr = [29, 39]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value one row above" do
        arr = [29, 38]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be false
      end
    end

    context "when direction is north west and start value is 25, where bound is a 8 x 8 grid" do
      direction = :nw

      it "returns true when the last array value is out of bound" do
        arr = [25, 32, 39]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value one row above" do
        arr = [25, 31]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value one row above" do
        arr = [25, 32]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be false
      end
    end

    context "when direction is south east and start value is 42, where bound is a 8 x 8 grid" do
      direction = :se

      it "returns true when the last array value is out of bound" do
        arr = [42, 33, 24, 15]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value one row below" do
        arr = [42, 32]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value one row below" do
        arr = [42, 33]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be false
      end
    end

    context "when direction is south west and start value is 25, where bound is a 8 x 8 grid" do
      direction = :sw

      it "returns true when the last array value is out of bound" do
        arr = [25, 16, 7]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value one row below" do
        arr = [25, 16, 6]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value one row below" do
        arr = [25, 16]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be false
      end
    end

    context "when it is an edge case, and bound is a 8 x 8 grid" do
      it "returns false when direction is out of scope" do
        direction = :n
        arr = [0, 1, 2, 3]
        result = logic_test.send(:not_adjacent?, direction, arr)
        expect(result).to be false
      end
    end
  end

  describe "#to_pos" do
    context "when coord is a valid integer array, and bound is a 8 x 8 grid, converts coordinates to position" do
      bound = [8, 8]
      it "returns position value 0 when coordinates is [0, 0]" do
        coord = [0, 0]
        result = logic_test.send(:to_pos, coord, bound: bound)
        expect(result).to eq(0)
      end

      it "returns position value 27 when coordinates is [3, 3]" do
        coord = [3, 3]
        result = logic_test.send(:to_pos, coord, bound: bound)
        expect(result).to eq(27)
      end

      it "returns position value 46 when coordinates is [5, 6]" do
        coord = [5, 6]
        result = logic_test.send(:to_pos, coord, bound: bound)
        expect(result).to eq(46)
      end
    end

    context "when coord is not a valid integer array, and bound is a 8 x 8 grid" do
      bound = [8, 8]
      it "raise an error if the coord larger than bound" do
        coord = [7, 8]
        expect do
          logic_test.send(:to_pos, coord, bound: bound)
        end.to raise_error(ArgumentError, "#{coord} is out of bound!")
      end

      it "raise an error if the coord smaller than bound" do
        coord = [-1, 0]
        expect do
          logic_test.send(:to_pos, coord, bound: bound)
        end.to raise_error(ArgumentError, "#{coord} is out of bound!")
      end
    end
  end

  describe "#to_coord" do
    context "when pos is a valid value, and bound is a 8 x 8 grid, converts position to coordinates" do
      bound = [8, 8]
      it "returns coordinates value [0, 0] when positional value is 0" do
        pos = 0
        expect(logic_test.send(:to_coord, pos, bound: bound)).to eq([0, 0])
      end

      it "returns coordinates value [3, 3] when positional value is 27" do
        pos = 27
        expect(logic_test.send(:to_coord, pos, bound: bound)).to eq([3, 3])
      end

      it "returns coordinates value [5, 6] when positional value is 46" do
        pos = 46
        expect(logic_test.send(:to_coord, pos, bound: bound)).to eq([5, 6])
      end
    end

    context "when pos is not a valid value, and bound is a 8 x 8 grid" do
      bound = [8, 8]
      it "raise an error if the value is larger than bound" do
        pos = 64
        expect do
          logic_test.send(:to_coord, pos, bound: bound)
        end.to raise_error(ArgumentError, "#{pos} is out of bound!")
      end

      it "raise an error if the value is smaller than bound" do
        pos = -1
        expect do
          logic_test.send(:to_coord, pos, bound: bound)
        end.to raise_error(ArgumentError, "#{pos} is out of bound!")
      end
    end
  end
end
