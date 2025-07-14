# frozen_string_literal: true

require_relative "../lib/console_game/chess/utilities/pgn_utils"

describe PgnUtils do
  describe "#parse_pgn" do
    context "when argument is a valid pgn file as String" do
      pgn_data = <<~DATA
        [Event "ch-USA Seniors 2024"]
        [Site "Saint Louis USA"]
        [Date "2024.07.25"]
        [Round "9.2"]
        [White "Akopian, Vl"]
        [Black "Benjamin, Joe"]
        [Result "1/2-1/2"]

        1.Nf3 Nf6 2.c4 g6 3.g3 Bg7 4.Bg2 O-O 5.O-O c6 6.d4 d6 7.Nc3 Bf5 8.b3 Ne4
        9.Bb2 Nxc3 10.Bxc3 Be4 11.Rc1 d5 12.Nd2 Bxg2 13.Kxg2 Nd7 14.e4 dxe4 15.Nxe4 Nf6
        16.Nxf6+ Bxf6 17.d5 Qd6 18.dxc6 Qxc6+ 19.Qf3 Bxc3 20.Qxc6 bxc6 21.Rxc3 Rfd8
        22.Re1 e6 23.Re5 a5 24.Rc5 Ra6 25.a3 Kf8 26.b4 axb4 27.axb4 Rb6 28.b5 cxb5
        29.cxb5 Ke7 30.g4 Rd5 31.Rc7+ Rd7 32.Rxd7+ Kxd7 33.Rb3 f5 34.gxf5 gxf5 35.Kg3 e5
        36.Kh4 Rh6+ 37.Kg5 Rxh2 38.b6 Kc8 39.Kxf5 Rxf2+ 40.Kxe5 Kb7 41.Rh3 Kxb6 42.Rxh7 Re2+
        43.Kf5 Rf2+ 44.Ke5 Re2+ 45.Kf5 Rf2+ 46.Ke5 Re2+  1/2-1/2
      DATA
      it "returns a session object as Hash" do
        result = described_class.parse_pgn(pgn_data)
        expect(result).to eq({ moves: { 1 => %w[Nf3 Nf6], 2 => %w[c4 g6], 3 => %w[g3 Bg7], 4 => %w[Bg2 O-O], 5 => %w[O-O c6], 6 => %w[d4 d6], 7 => %w[Nc3 Bf5], 8 => %w[b3 Ne4], 9 => %w[Bb2 Nxc3], 10 => %w[Bxc3 Be4], 11 => %w[Rc1 d5], 12 => %w[Nd2 Bxg2], 13 => %w[Kxg2 Nd7], 14 => %w[e4 dxe4], 15 => %w[Nxe4 Nf6], 16 => ["Nxf6+", "Bxf6"], 17 => %w[d5 Qd6], 18 => ["dxc6", "Qxc6+"], 19 => %w[Qf3 Bxc3], 20 => %w[Qxc6 bxc6], 21 => %w[Rxc3 Rfd8], 22 => %w[Re1 e6], 23 => %w[Re5 a5], 24 => %w[Rc5 Ra6], 25 => %w[a3 Kf8], 26 => %w[b4 axb4], 27 => %w[axb4 Rb6], 28 => %w[b5 cxb5], 29 => %w[cxb5 Ke7], 30 => %w[g4 Rd5], 31 => ["Rc7+", "Rd7"], 32 => ["Rxd7+", "Kxd7"], 33 => %w[Rb3 f5], 34 => %w[gxf5 gxf5], 35 => %w[Kg3 e5], 36 => ["Kh4", "Rh6+"], 37 => %w[Kg5 Rxh2], 38 => %w[b6 Kc8], 39 => ["Kxf5", "Rxf2+"], 40 => %w[Kxe5 Kb7], 41 => %w[Rh3 Kxb6], 42 => ["Rxh7", "Re2+"], 43 => ["Kf5", "Rf2+"], 44 => ["Ke5", "Re2+"], 45 => ["Kf5", "Rf2+"], 46 => ["Ke5", "Re2+"] }, event: "ch-USA Seniors 2024", site: "Saint Louis USA", date: Time.new(2024, 7, 25), round: "9.2", white: "Akopian, Vl", black: "Benjamin, Joe", result: "1/2-1/2" })
      end
    end
  end

  describe "#to_pgn" do
    context "when session is a valid PGN ready hash" do
      let(:formatted_moves) do
        { 1 => %w[Nf3 Nf6], 2 => %w[c4 g6], 3 => %w[g3 Bg7], 4 => %w[Bg2 O-O], 5 => %w[O-O c6],
          6 => %w[d4 d6], 7 => %w[Nc3 Bf5], 8 => %w[b3 Ne4], 9 => %w[Bb2 Nxc3], 10 => %w[Bxc3 Be4], 11 => %w[Rc1 d5], 12 => %w[Nd2 Bxg2], 13 => %w[Kxg2 Nd7], 14 => %w[e4 dxe4], 15 => %w[Nxe4 Nf6], 16 => ["Nxf6+", "Bxf6"], 17 => %w[d5 Qd6], 18 => ["dxc6", "Qxc6+"], 19 => %w[Qf3 Bxc3], 20 => %w[Qxc6 bxc6], 21 => %w[Rxc3 Rfd8], 22 => %w[Re1 e6], 23 => %w[Re5 a5], 24 => %w[Rc5 Ra6], 25 => %w[a3 Kf8], 26 => %w[b4 axb4], 27 => %w[axb4 Rb6], 28 => %w[b5 cxb5], 29 => %w[cxb5 Ke7], 30 => %w[g4 Rd5], 31 => ["Rc7+", "Rd7"], 32 => ["Rxd7+", "Kxd7"], 33 => %w[Rb3 f5], 34 => %w[gxf5 gxf5], 35 => %w[Kg3 e5], 36 => ["Kh4", "Rh6+"], 37 => %w[Kg5 Rxh2], 38 => %w[b6 Kc8], 39 => ["Kxf5", "Rxf2+"], 40 => %w[Kxe5 Kb7], 41 => %w[Rh3 Kxb6], 42 => ["Rxh7", "Re2+"], 43 => ["Kf5", "Rf2+"], 44 => ["Ke5", "Re2+"], 45 => ["Kf5", "Rf2+"], 46 => ["Ke5", "Re2+"] }
      end
      let(:session) do
        { event: "ch-USA Seniors 2024", site: "Saint Louis USA", date: Time.new(2024, 7, 25), round: 9.2, white: "Akopian, Vl",
          black: "Benjamin, Joe", result: "1/2-1/2", moves: formatted_moves }
      end
      let(:incomplete_session) do
        { result: "1/2-1/2", moves: formatted_moves }
      end

      let(:pgn_data_complete) do
        <<~DATA
          [Event "ch-USA Seniors 2024"]
          [Site "Saint Louis USA"]
          [Date "2024.7.25"]
          [Round "9.2"]
          [White "Akopian, Vl"]
          [Black "Benjamin, Joe"]
          [Result "1/2-1/2"]

          1. Nf3 Nf6 2. c4 g6 3. g3 Bg7 4. Bg2 O-O 5. O-O c6 6. d4 d6 7. Nc3 Bf5 8. b3 Ne4 9. Bb2 Nxc3 10. Bxc3 Be4 11. Rc1 d5 12. Nd2 Bxg2 13. Kxg2 Nd7 14. e4 dxe4 15. Nxe4 Nf6 16. Nxf6+ Bxf6 17. d5 Qd6 18. dxc6 Qxc6+ 19. Qf3 Bxc3 20. Qxc6 bxc6 21. Rxc3 Rfd8 22. Re1 e6 23. Re5 a5 24. Rc5 Ra6 25. a3 Kf8 26. b4 axb4 27. axb4 Rb6 28. b5 cxb5 29. cxb5 Ke7 30. g4 Rd5 31. Rc7+ Rd7 32. Rxd7+ Kxd7 33. Rb3 f5 34. gxf5 gxf5 35. Kg3 e5 36. Kh4 Rh6+ 37. Kg5 Rxh2 38. b6 Kc8 39. Kxf5 Rxf2+ 40. Kxe5 Kb7 41. Rh3 Kxb6 42. Rxh7 Re2+ 43. Kf5 Rf2+ 44. Ke5 Re2+ 45. Kf5 Rf2+ 46. Ke5 Re2+ 1/2-1/2
        DATA
      end

      let(:pgn_data_incomplete) do
        <<~DATA
          [Result "1/2-1/2"]

          1. Nf3 Nf6 2. c4 g6 3. g3 Bg7 4. Bg2 O-O 5. O-O c6 6. d4 d6 7. Nc3 Bf5 8. b3 Ne4 9. Bb2 Nxc3 10. Bxc3 Be4 11. Rc1 d5 12. Nd2 Bxg2 13. Kxg2 Nd7 14. e4 dxe4 15. Nxe4 Nf6 16. Nxf6+ Bxf6 17. d5 Qd6 18. dxc6 Qxc6+ 19. Qf3 Bxc3 20. Qxc6 bxc6 21. Rxc3 Rfd8 22. Re1 e6 23. Re5 a5 24. Rc5 Ra6 25. a3 Kf8 26. b4 axb4 27. axb4 Rb6 28. b5 cxb5 29. cxb5 Ke7 30. g4 Rd5 31. Rc7+ Rd7 32. Rxd7+ Kxd7 33. Rb3 f5 34. gxf5 gxf5 35. Kg3 e5 36. Kh4 Rh6+ 37. Kg5 Rxh2 38. b6 Kc8 39. Kxf5 Rxf2+ 40. Kxe5 Kb7 41. Rh3 Kxb6 42. Rxh7 Re2+ 43. Kf5 Rf2+ 44. Ke5 Re2+ 45. Kf5 Rf2+ 46. Ke5 Re2+ 1/2-1/2
        DATA
      end

      it "returns a string containing seven tags roaster and moves sequence" do
        result = described_class.to_pgn(session)
        expect(result).to eq(pgn_data_complete)
      end

      it "returns a string containing moves sequence when seven tags roaster is incomplete" do
        result = described_class.to_pgn(incomplete_session)
        expect(result).to eq(pgn_data_incomplete)
      end
    end

    context "when session is valid pgn hash and incomplete" do
      it "returns a string containing seven tags roaster and moves sequence" do
        skip "Todo"
      end
    end

    context "when session is invalid" do
      it "returns nil when moves is missing" do
        skip "Todo"
      end

      # it "returns nil when moves sequence is invalid" do
      #   skip "Todo"
      # end
    end
  end

  describe "#format_metadata" do
    let(:key) { :event }

    context "when key is a Symbol" do
      let(:value) { "Test Event" }

      it "changes to a capitalize string" do
        result = described_class.send(:format_metadata, key, value)
        expect(result).to eq('[Event "Test Event"]')
      end
    end

    context "when value is a String object" do
      let(:value) { "Test Event" }

      it "returns a formatted string value" do
        result = described_class.send(:format_metadata, key, value)
        expect(result).to eq('[Event "Test Event"]')
      end
    end

    context "when value is a Numeric object" do
      let(:integer) { 2 }
      let(:float) { 4.2 }

      it "returns a formatted string value if it is an Integer" do
        result = described_class.send(:format_metadata, key, integer)
        expect(result).to eq('[Event "2"]')
      end

      it "returns a formatted string value if it is an Float" do
        result = described_class.send(:format_metadata, key, float)
        expect(result).to eq('[Event "4.2"]')
      end
    end

    context "when value is a Time object" do
      let(:time) { Time.now.ceil }

      it "returns a formatted date as string value" do
        result = described_class.send(:format_metadata, key, time)
        expect(result).to eq("[Event \"#{time.year}.#{time.mon}.#{time.day}\"]")
      end
    end

    context "when value is other data types" do
      let(:arr) { [1, 2, 3] }

      it "returns a formatted string value if it is an Array" do
        result = described_class.send(:format_metadata, key, arr)
        expect(result).to eq('[Event "[1, 2, 3]"]')
      end
    end
  end

  describe "#parse_pgn_metadata" do
    context "when argument string contains a valid PGN standard tag" do
      it "returns a Symbol value key and String value if value is String" do
        data = '[Event "ch-USA Seniors 2024"]'
        result = described_class.send(:parse_pgn_metadata, data)
        expect(result).to eq([:event, "ch-USA Seniors 2024"])
      end

      it "returns a Symbol value key and Time value if value is a String with date data" do
        data = '[Date "2024.07.25"]'
        result = described_class.send(:parse_pgn_metadata, data)
        expect(result).to eq([:date, Time.new(2024, 7, 25)])
      end
    end

    context "when argument is not a valid pgn standard tag" do
      let(:data) { '[Test "Wrong data"]' }

      it "raise an argument error" do
        expect { described_class.send(:parse_pgn_metadata, data) }.to raise_error(ArgumentError, "test is not a valid metadata field, please verify data integrity")
      end
    end
  end

  describe "#handle_date" do
    context "when value is 2025.06.23" do
      let(:str_date) { "2025.06.23" }

      it "returns a Time object where date is 2025-6-23" do
        result = described_class.send(:handle_date, str_date)
        expect(result).to eq(Time.new(2025, 6, 23))
      end
    end

    context "when value is 2025.06.??" do
      let(:str_date) { "2025.06.??" }

      it "returns a Time object where date is 2025-06-01" do
        result = described_class.send(:handle_date, str_date)
        expect(result).to eq(Time.new(2025, 6, 1))
      end
    end

    context "when value is 2025.??.??" do
      let(:str_date) { "2025.??.??" }

      it "returns a Time object where date is 2025-01-01" do
        result = described_class.send(:handle_date, str_date)
        expect(result).to eq(Time.new(2025, 1, 1))
      end
    end

    context "when value is ??.??.??" do
      let(:str_date) { "??.??.??" }

      it "returns a Time object where date is 0001-01-01" do
        result = described_class.send(:handle_date, str_date)
        expect(result).to eq(Time.new(1, 1, 1))
      end
    end
  end

  describe "#format_moves" do
    context "when moves is a valid hash with algebraic value pairs" do
      let(:moves) { { 1 => %w[Nf3 Nf6], 2 => %w[c4 g6], 3 => %w[g3 Bg7], 4 => %w[Bg2 O-O], 5 => %w[O-O c6] } }

      it "returns a valid PGN format as Array" do
        result = described_class.send(:format_moves, moves)
        expect(result).to eq(["1. Nf3 Nf6", "2. c4 g6", "3. g3 Bg7", "4. Bg2 O-O", "5. O-O c6"])
      end
    end
  end

  describe "#parse_pgn_moves" do
    context "when argument is a valid, cleaned, PGN moves sting array" do
      let(:cleaned_pgn_moves_data) { ["1.", "Nf3", "Nf6", "2.", "c4", "g6", "3.", "g3", "Bg7", "4.", "Bg2", "O-O", "5.", "O-O", "c6", "6.", "d4", "d6", "7.", "Nc3", "Bf5", "8.", "b3", "Ne4", "9.", "Bb2", "Nxc3", "10.", "Bxc3", "Be4", "11.", "Rc1", "d5", "12.", "Nd2", "Bxg2", "13.", "Kxg2", "Nd7", "14.", "e4", "dxe4", "15.", "Nxe4", "Nf6", "16.", "Nxf6+", "Bxf6", "17.", "d5", "Qd6", "18.", "dxc6", "Qxc6+", "19.", "Qf3", "Bxc3", "20.", "Qxc6", "bxc6", "21.", "Rxc3", "Rfd8", "22.", "Re1", "e6", "23.", "Re5", "a5", "24.", "Rc5", "Ra6", "25.", "a3", "Kf8", "26.", "b4", "axb4", "27.", "axb4", "Rb6", "28.", "b5", "cxb5", "29.", "cxb5", "Ke7", "30.", "g4", "Rd5", "31.", "Rc7+", "Rd7", "32.", "Rxd7+", "Kxd7", "33.", "Rb3", "f5", "34.", "gxf5", "gxf5", "35.", "Kg3", "e5", "36.", "Kh4", "Rh6+", "37.", "Kg5", "Rxh2", "38.", "b6", "Kc8", "39.", "Kxf5", "Rxf2+", "40.", "Kxe5", "Kb7", "41.", "Rh3", "Kxb6", "42.", "Rxh7", "Re2+", "43.", "Kf5", "Rf2+", "44.", "Ke5", "Re2+", "45.", "Kf5", "Rf2+", "46.", "Ke5", "Re2+", "1/2-1/2"] }

      it "returns a valid hash object" do
        result = described_class.send(:parse_pgn_moves, cleaned_pgn_moves_data)
        expect(result).to eq({ 1 => %w[Nf3 Nf6], 2 => %w[c4 g6], 3 => %w[g3 Bg7], 4 => %w[Bg2 O-O], 5 => %w[O-O c6],
                               6 => %w[d4 d6], 7 => %w[Nc3 Bf5], 8 => %w[b3 Ne4], 9 => %w[Bb2 Nxc3], 10 => %w[Bxc3 Be4], 11 => %w[Rc1 d5], 12 => %w[Nd2 Bxg2], 13 => %w[Kxg2 Nd7], 14 => %w[e4 dxe4], 15 => %w[Nxe4 Nf6], 16 => ["Nxf6+", "Bxf6"], 17 => %w[d5 Qd6], 18 => ["dxc6", "Qxc6+"], 19 => %w[Qf3 Bxc3], 20 => %w[Qxc6 bxc6], 21 => %w[Rxc3 Rfd8], 22 => %w[Re1 e6], 23 => %w[Re5 a5], 24 => %w[Rc5 Ra6], 25 => %w[a3 Kf8], 26 => %w[b4 axb4], 27 => %w[axb4 Rb6], 28 => %w[b5 cxb5], 29 => %w[cxb5 Ke7], 30 => %w[g4 Rd5], 31 => ["Rc7+", "Rd7"], 32 => ["Rxd7+", "Kxd7"], 33 => %w[Rb3 f5], 34 => %w[gxf5 gxf5], 35 => %w[Kg3 e5], 36 => ["Kh4", "Rh6+"], 37 => %w[Kg5 Rxh2], 38 => %w[b6 Kc8], 39 => ["Kxf5", "Rxf2+"], 40 => %w[Kxe5 Kb7], 41 => %w[Rh3 Kxb6], 42 => ["Rxh7", "Re2+"], 43 => ["Kf5", "Rf2+"], 44 => ["Ke5", "Re2+"], 45 => ["Kf5", "Rf2+"], 46 => ["Ke5", "Re2+"] })
      end
    end
  end

  describe "#clean_pgn_moves" do
    context "when argument is a valid, unformatted PGN moves string array" do
      let(:raw_pgn_moves_data) { ["", "1. Nf3 Nf6 2. c4 g6 3. g3 Bg7 4. Bg2 O-O 5. O-O c6 6. d4 d6 7. Nc3 Bf5 8. b3 Ne4 9. Bb2 Nxc3 10. Bxc3 Be4 11. Rc1 d5 12. Nd2 Bxg2 13. Kxg2 Nd7 14. e4 dxe4 15. Nxe4 Nf6 16. Nxf6+ Bxf6 17. d5 Qd6 18. dxc6 Qxc6+ 19. Qf3 Bxc3 20. Qxc6 bxc6 21. Rxc3 Rfd8 22. Re1 e6 23. Re5 a5 24. Rc5 Ra6 25. a3 Kf8 26. b4 axb4 27. axb4 Rb6 28. b5 cxb5 29. cxb5 Ke7 30. g4 Rd5 31. Rc7+ Rd7 32. Rxd7+ Kxd7 33. Rb3 f5 34. gxf5 gxf5 35. Kg3 e5 36. Kh4 Rh6+ 37. Kg5 Rxh2 38. b6 Kc8 39. Kxf5 Rxf2+ 40. Kxe5 Kb7 41. Rh3 Kxb6 42. Rxh7 Re2+ 43. Kf5 Rf2+ 44. Ke5 Re2+ 45. Kf5 Rf2+ 46. Ke5 Re2+ 1/2-1/2"] }

      it "returns an array of strings in an usable format" do
        result = described_class.send(:clean_pgn_moves, raw_pgn_moves_data)
        expect(result).to eq(["1.", "Nf3", "Nf6", "2.", "c4", "g6", "3.", "g3", "Bg7", "4.", "Bg2", "O-O", "5.", "O-O", "c6", "6.", "d4", "d6", "7.", "Nc3", "Bf5", "8.", "b3", "Ne4", "9.", "Bb2", "Nxc3", "10.", "Bxc3", "Be4", "11.", "Rc1", "d5", "12.", "Nd2", "Bxg2", "13.", "Kxg2", "Nd7", "14.", "e4", "dxe4", "15.", "Nxe4", "Nf6", "16.", "Nxf6+", "Bxf6", "17.", "d5", "Qd6", "18.", "dxc6", "Qxc6+", "19.", "Qf3", "Bxc3", "20.", "Qxc6", "bxc6", "21.", "Rxc3", "Rfd8", "22.", "Re1", "e6", "23.", "Re5", "a5", "24.", "Rc5", "Ra6", "25.", "a3", "Kf8", "26.", "b4", "axb4", "27.", "axb4", "Rb6", "28.", "b5", "cxb5", "29.", "cxb5", "Ke7", "30.", "g4", "Rd5", "31.", "Rc7+", "Rd7", "32.", "Rxd7+", "Kxd7", "33.", "Rb3", "f5", "34.", "gxf5", "gxf5", "35.", "Kg3", "e5", "36.", "Kh4", "Rh6+", "37.", "Kg5", "Rxh2", "38.", "b6", "Kc8", "39.", "Kxf5", "Rxf2+", "40.", "Kxe5", "Kb7", "41.", "Rh3", "Kxb6", "42.", "Rxh7", "Re2+", "43.", "Kf5", "Rf2+", "44.", "Ke5", "Re2+", "45.", "Kf5", "Rf2+", "46.", "Ke5", "Re2+", "1/2-1/2"])
      end
    end
  end
end
