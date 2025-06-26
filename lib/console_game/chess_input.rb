# frozen_string_literal: true

require_relative "input"

module ConsoleGame
  # Input controller for the game Chess
  class ChessInput < Input
    # == Console Commands ==

    # Exit sequences | command patterns: `exit`
    def quit(_arg = [])
      print_msg(s("cli.lobby.exit"), pre: "*")
      # exit
    end

    # Display help string | command pattern: `help`
    def help(_arr = [])
      print_msg("Type --exit to exit the program")
    end

    # Display system info | command pattern: `info`
    def info(_arr = [])
      p "Will print game info"
    end

    # Save session to player data | command pattern: `save`
    def save(_arr = [])
      p "Will save session to player session, then store player data to user profile"
    end

    # Load session from player data | command pattern: `load`
    def load(_arr = [])
      p "Will allow player to switch between other sessions stored within their own user profile"
    end

    # Export current game session as pgn file | command pattern: `export`
    def export(_arr = [])
      p "Will export session to local directory as a pgn file"
    end

    private

    # == Unities ==

    # Setup input commands
    def setup_commands
      super.merge({ "save" => method(:save), "load" => method(:load), "export" => method(:export) })
    end
  end
end
