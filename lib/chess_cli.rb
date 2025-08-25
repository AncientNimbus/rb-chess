# frozen_string_literal: true

require_relative "console_game/game_manager"

# Chess CLI Wrapper
class ChessCLI
  # Run Chess CLI
  def self.run(lang: "en")
    ConsoleGame::GameManager.new(lang:).run
  end
end
