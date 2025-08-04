# frozen_string_literal: true

require "whirly"

module ConsoleGame
  # Wait Utils class uses the whirly gem to enhance user experience when interacting with the terminal.
  # @author Ancient Nimbus
  class WaitUtils
    def self.wait_msg(...) = new(...).wait_msg

    attr_reader :msg, :time

    def initialize(msg, time: 0)
      @msg = msg
      @time = time
    end

    # Wait event via whirly
    def wait_msg
      Whirly.start spinner: "random_dots", status: msg, color: false, stop: "⣿" do
        sleep time
      end
    end
  end
end
