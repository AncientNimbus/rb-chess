# frozen_string_literal: true

require_relative "lib/console_game/chess/version"

Gem::Specification.new do |s|
  s.author = "Ancient Nimbus"
  s.name = "chess_cli"
  s.files = Dir["lib/**/*.rb"] + Dir["bin/*"]
  s.files += Dir[".config/locale/**/*.yml"]
  s.files += Dir["user_data/**/*"] + Dir["user_data/**/.keep"]
  s.summary = "A colourful terminal Chess, support Smith & Algebraic input, FEN I/O, user profile management and more."
  s.version = ConsoleGame::Chess::VER

  s.description = <<~INFO
    A colourful terminal Chess, support Smith & Algebraic Notation input.

    Core feature:
    - FEN session import / export
    - PGN file export
    - User Profile Management
    - Multiple chess session per profile
    - Input hot-swapping
    - Session hot-swapping
    - Chessboard customization
  INFO
  s.email = ["rb@ttfn.lol"]
  s.homepage = "https://github.com/AncientNimbus/rb-chess"
  s.license = "BSD-3-Clause"
  s.metadata = {
    "changelog_uri" => "https://github.com/AncientNimbus/rb-chess/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://ancientnimbus.github.io/rb-chess/doc/",
    "homepage_uri" => "https://github.com/AncientNimbus/rb-chess",
    "source_code_uri" => "https://github.com/AncientNimbus/rb-chess",
    "code_coverage_uri" => "https://ancientnimbus.github.io/rb-chess/coverage/#_AllFiles"
  }
  s.required_ruby_version = ">= 3.4"

  s.executables << "chess_cli"
  s.add_dependency "paint", "~> 2.3"
  s.add_dependency "reline", "~> 0.6.2"
  s.add_dependency "whirly", "~> 0.3.0"
  s.post_install_message = "Thanks for installing Chess powered by Ruby Arcade!"
end
