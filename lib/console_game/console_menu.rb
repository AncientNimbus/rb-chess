# frozen_string_literal: true

require_relative "input"

module ConsoleGame
  # Input controller for console menu
  class ConsoleMenu < Input
    # == Console Commands ==

    # Exit sequences | command patterns: `exit`, `ttfn`
    def quit(_arg = [])
      print_msg(s("cli.lobby.exit"))
      game_manager.exit_arcade
    end

    # Display help string | command pattern: `help`
    def help(_arr = [])
      print_msg(s("cli.help"))
    end

    # Display system info | command pattern: `info`
    def info(_arr = [])
      print_msg(s("cli.menu"))
    end

    # Save user profile to disk | command pattern: `save`
    def save(_arr = [])
      game_manager.save_user_profile
    end

    # Load user profile from disk | command pattern: `load`
    def load(_arr = [])
      game_manager.switch_user_profile
    end

    # Launch a game | command pattern: `play <launch code>`
    # @param arr [Array<String>] optional arguments
    def play(arr = [])
      return print_msg(s("cli.play.gm_err")) unless game_manager

      app_name = arr[0]
      if game_manager.apps.key?(app_name)
        game_manager.apps[app_name].call
      else
        print_msg(s("cli.play.run_err"))
      end
    end

    # Display user info | command pattern: `self`
    def self(_arr = [])
      profile = game_manager.user.profile
      user_color = :yellow
      p "Debug: #{profile}"
      print_msg(s("cli.self.msg",
                  { uuid: [profile[:uuid], user_color],
                    date: [profile[:saved_date].strftime("%m/%d/%Y %I:%M %p"), user_color],
                    name: [profile[:username], user_color],
                    visit: [profile[:stats][:launch_count], user_color] }))
    end

    # == Unities ==

    # Setup input commands
    def setup_commands
      super.merge({ "ttfn" => method(:quit), "save" => method(:save), "load" => method(:load),
                    "play" => method(:play), "self" => method(:self) })
    end
  end
end
