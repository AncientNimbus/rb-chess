# frozen_string_literal: true

require_relative "../../../lib/console_game/chess/logic"

describe ConsoleGame::Chess::Logic do
  subject(:logic_test) { dummy_class.new }

  let(:dummy_class) { Class.new { include ConsoleGame::Chess::Logic } }

  describe "#direction" do
    context "when starting value is 0, and bound is a 8 x 8 grid, requesting an array with 8 elements" do
      start_value = 0
      arr = nil
      arr_length = 8
      bound = [8, 8]

      it "returns an empty array when direction is the north west" do
        direction = :nw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the north" do
        direction = :n
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([0, 8, 16, 24, 32, 40, 48, 56])
      end

      it "returns a sequence of positions to the north east" do
        direction = :ne
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([0, 9, 18, 27, 36, 45, 54, 63])
      end

      it "returns a sequence of positions to the east" do
        direction = :e
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([0, 1, 2, 3, 4, 5, 6, 7])
      end

      it "returns an empty array when direction is the south east" do
        direction = :se
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south" do
        direction = :s
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south west" do
        direction = :sw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the west" do
        direction = :w
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end
    end

    context "when starting value is 6, where bound and array size are using constant value set within the script (8 x 8 grid)" do
      start_value = 6
      arr = nil
      let(:preset) { ConsoleGame::Chess::Logic::PRESET }
      let(:arr_length) { preset[:length] }
      let(:bound) { preset[:bound] }

      it "returns a sequence of positions to the north west" do
        direction = :nw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([6, 13, 20, 27])
      end

      it "returns a sequence of positions to the north" do
        direction = :n
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([6, 14, 22, 30])
      end

      it "returns an empty array when direction is the north east" do
        direction = :ne
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the east" do
        direction = :e
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south east" do
        direction = :se
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south" do
        direction = :s
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south west" do
        direction = :sw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the west" do
        direction = :w
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([6, 5, 4, 3])
      end
    end

    context "when starting value is 9, and bound is a 8 x 8 grid, requesting an array with 4 elements" do
      start_value = 9
      arr = nil
      arr_length = 4
      bound = [8, 8]

      it "returns an empty array when direction is the north west" do
        direction = :nw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the north" do
        direction = :n
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 17, 25, 33])
      end

      it "returns a sequence of positions to the north east" do
        direction = :ne
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 18, 27, 36])
      end

      it "returns a sequence of positions to the east" do
        direction = :e
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([9, 10, 11, 12])
      end

      it "returns an empty array when direction is the south east" do
        direction = :se
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south" do
        direction = :s
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south west" do
        direction = :sw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the west" do
        direction = :w
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end
    end

    context "when starting value is 32, and bound is a 8 x 8 grid, requesting an array with 4 elements" do
      start_value = 32
      arr = nil
      arr_length = 4
      bound = [8, 8]

      it "returns an empty array when direction is the north west" do
        direction = :nw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the north" do
        direction = :n
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 40, 48, 56])
      end

      it "returns a sequence of positions to the north east" do
        direction = :ne
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 41, 50, 59])
      end

      it "returns a sequence of positions to the east" do
        direction = :e
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 33, 34, 35])
      end

      it "returns a sequence of positions to the south east" do
        direction = :se
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 25, 18, 11])
      end

      it "returns a sequence of positions to the south" do
        direction = :s
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([32, 24, 16, 8])
      end

      it "returns an empty array when direction is the south west" do
        direction = :sw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the west" do
        direction = :w
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
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
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the north" do
        direction = :n
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the north east" do
        direction = :ne
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the east" do
        direction = :e
        result = logic_test.direction(5, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when direction is the south east" do
        direction = :se
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns a sequence of positions to the south" do
        direction = :s
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([38, 30, 22, 14, 6])
      end

      it "returns a sequence of positions to the south west" do
        direction = :sw
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([38, 29, 20, 11, 2])
      end

      it "returns a sequence of positions to the west" do
        direction = :w
        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([38, 37, 36, 35, 34])
      end
    end

    context "when it is an edge case, and bound is a 8 x 8 grid" do
      arr = nil
      arr_length = 4
      bound = [8, 8]
      it "returns a sequence of positions to the east when no argument is provided" do
        result = logic_test.direction
        expect(result).to eq([0, 1, 2, 3])
      end

      it "returns an empty array when starting value is larger than bound" do
        start_value = 64
        direction = :e

        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "returns an empty array when starting value is smaller than bound" do
        start_value = -1
        direction = :e

        result = logic_test.direction(start_value, direction, arr, length: arr_length, bound: bound)
        expect(result).to eq([])
      end

      it "raise an error when direction symbol is incorrect" do
        start_value = 41
        direction = :test
        expect do
          logic_test.direction(start_value, direction)
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

  describe "#not_one_unit_apart?" do
    context "when direction is east and start value is 5, where bound is a 8 x 8 grid" do
      direction = :e
      row = 8
      it "returns true when the last array value is out of bound" do
        arr = [5, 6, 7, 8]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value of the previous value" do
        arr = [5, 7]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value of the previous value" do
        arr = [5, 6]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be false
      end
    end

    context "when direction is west and start value is 42, where bound is a 8 x 8 grid" do
      direction = :w
      row = 8
      it "returns true when the last array value is out of bound" do
        arr = [42, 41, 40, 39]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value of the previous value" do
        arr = [42, 40]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value of the previous value" do
        arr = [42, 41]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be false
      end
    end

    context "when direction is north east and start value is 29, where bound is a 8 x 8 grid" do
      direction = :ne
      row = 8
      it "returns true when the last array value is out of bound" do
        arr = [29, 38, 47, 56]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value one row above" do
        arr = [29, 39]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value one row above" do
        arr = [29, 38]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be false
      end
    end

    context "when direction is north west and start value is 25, where bound is a 8 x 8 grid" do
      direction = :nw
      row = 8
      it "returns true when the last array value is out of bound" do
        arr = [25, 32, 39]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value one row above" do
        arr = [25, 31]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value one row above" do
        arr = [25, 32]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be false
      end
    end

    context "when direction is south east and start value is 42, where bound is a 8 x 8 grid" do
      direction = :se
      row = 8
      it "returns true when the last array value is out of bound" do
        arr = [42, 33, 24, 15]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value one row below" do
        arr = [42, 32]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value one row below" do
        arr = [42, 33]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be false
      end
    end

    context "when direction is south west and start value is 25, where bound is a 8 x 8 grid" do
      direction = :sw
      row = 8
      it "returns true when the last array value is out of bound" do
        arr = [25, 16, 7, -2]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns true when the last array value is not the next immediate value one row below" do
        arr = [25, 16, 6]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be true
      end

      it "returns false when the last array value is the next immediate value one row below" do
        arr = [25, 16]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be false
      end
    end

    context "when it is an edge case, and bound is a 8 x 8 grid" do
      row = 8
      it "returns false when direction is out of scope" do
        direction = :n
        arr = [0, 1, 2, 3]
        result = logic_test.send(:not_one_unit_apart?, direction, arr, row)
        expect(result).to be false
      end
    end
  end

  describe "#to_pos" do
    context "when coord is a valid integer array, and bound is a 8 x 8 grid, converts coordinates to position" do
      bound = [8, 8]
      it "returns position value 0 when coordinates is [0, 0]" do
        coord = [0, 0]
        result = logic_test.to_pos(coord, bound: bound)
        expect(result).to eq(0)
      end

      it "returns position value 27 when coordinates is [3, 3]" do
        coord = [3, 3]
        result = logic_test.to_pos(coord, bound: bound)
        expect(result).to eq(27)
      end

      it "returns position value 46 when coordinates is [5, 6]" do
        coord = [5, 6]
        result = logic_test.to_pos(coord, bound: bound)
        expect(result).to eq(46)
      end
    end

    context "when coord is not a valid integer array, and bound is a 8 x 8 grid" do
      bound = [8, 8]
      it "raise an error if the coord larger than bound" do
        coord = [7, 8]
        expect do
          logic_test.to_pos(coord, bound: bound)
        end.to raise_error(ArgumentError, "#{coord} is out of bound!")
      end

      it "raise an error if the coord smaller than bound" do
        coord = [-1, 0]
        expect do
          logic_test.to_pos(coord, bound: bound)
        end.to raise_error(ArgumentError, "#{coord} is out of bound!")
      end
    end
  end

  describe "#to_coord" do
    context "when pos is a valid value, and bound is a 8 x 8 grid, converts position to coordinates" do
      bound = [8, 8]
      it "returns coordinates value [0, 0] when positional value is 0" do
        pos = 0
        expect(logic_test.to_coord(pos, bound: bound)).to eq([0, 0])
      end

      it "returns coordinates value [3, 3] when positional value is 27" do
        pos = 27
        expect(logic_test.to_coord(pos, bound: bound)).to eq([3, 3])
      end

      it "returns coordinates value [5, 6] when positional value is 46" do
        pos = 46
        expect(logic_test.to_coord(pos, bound: bound)).to eq([5, 6])
      end
    end

    context "when pos is not a valid value, and bound is a 8 x 8 grid" do
      bound = [8, 8]
      it "raise an error if the value is larger than bound" do
        pos = 64
        expect do
          logic_test.to_coord(pos, bound: bound)
        end.to raise_error(ArgumentError, "#{pos} is out of bound!")
      end

      it "raise an error if the value is smaller than bound" do
        pos = -1
        expect do
          logic_test.to_coord(pos, bound: bound)
        end.to raise_error(ArgumentError, "#{pos} is out of bound!")
      end
    end
  end
end
