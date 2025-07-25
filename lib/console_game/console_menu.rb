# frozen_string_literal: true

require_relative "input"

module ConsoleGame
  # Input controller for console menu
  class ConsoleMenu < Input
    # == Console Commands ==

    # Exit sequences | command patterns: `exit`, `ttfn`
    def quit(_args = [])
      print_msg(s("cli.lobby.exit"))
      super
    end

    # Display help string | command pattern: `help`
    def help(_args = []) = print_msg(s("cli.help"))

    # Display system info | command pattern: `info`
    def info(_args = []) = print_msg(s("cli.menu"))

    # Save user profile to disk | command pattern: `save`
    def save(_args = []) = game_manager.save_user_profile

    # Load user profile from disk | command pattern: `load`
    def load(_args = []) = game_manager.switch_user_profile

    # Launch a game | command pattern: `play <launch code>`
    # @param args [Array<String>] optional arguments
    def play(args = [])
      return print_msg(s("cli.play.gm_err")) unless game_manager

      app = args[0]
      game_manager.apps.key?(app) ? game_manager.launch(app) : print_msg(s("cli.play.run_err"), pre: "! ")
    end

    # Display user info | command pattern: `self`
    def self(_args = [])
      profile = game_manager.user.profile
      user_color = :yellow
      # p "Debug: #{profile}"
      print_msg(s("cli.self.msg",
                  { uuid: [profile[:uuid], user_color],
                    date: [profile[:saved_date].strftime("%m/%d/%Y %I:%M %p"), user_color],
                    name: [profile[:username], user_color],
                    visit: [profile[:stats][:launch_count], user_color] }))
    end

    private

    # Easter egg | command pattern: `lol`
    def lol(_args = [])
      Whirly.start spinner: "random_dots", status: s("cli.lol.title").sample do
        sleep 3
        Whirly.status = s("cli.lol.sub").sample
        sleep 1.5
        msgs = s("cli.lol.msgs")
        print_msg(msgs[command_usage[:lol] % msgs.size], pre: "* ")
      end
    end

    # == Unities ==

    # Setup input commands
    def setup_commands = super.merge({ "save" => method(:save), "load" => method(:load), "play" => method(:play),
                                       "self" => method(:self), "lol" => method(:lol) })
  end
end
