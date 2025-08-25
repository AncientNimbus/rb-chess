# Changelog

All notable changes to this project will be documented in this file.

## [0.9.2] - 2025-08-25

### 🚀 Features

- Gemification (#74)

### 🐛 Bug Fixes

- Update helper text for algebraic input

### 📚 Documentation

- Add gameplay footage to README

### ⚙️ Miscellaneous Tasks

- Update CHANGELOG

## [0.9.0] - 2025-08-05

### 🚀 Features

- *(UX)* Improve prompt handling
- Update MovesSimulation to check other pieces
- *(UX)* Improve PGN export messaging
- *(UX)* Change king's colour during checkmate
- *(UX)* Add player greetings on new & load game
- Improve FenImport's edge case handling
- Further refine FenImport's edge case handling
- Add the ability to import a game via FEN (#70)
- Add missing player messages (#71)

### 🐛 Bug Fixes

- Resolve a crash when exiting from load game
- Resolve an issue related to castling and check
- Move that will result in check restricted

### 💼 Other

- Remove board refresh in #draw method
- Table formatting and adjust print spacing (#72)

### 📚 Documentation

- Update CHANGELOG
- Update README for v0.9.0

### 🧪 Testing

- Add test cases for PgnExport
- Integration test for info and export command
- Add tests for Fool's mate and Legal's mate
- Test case for loading a checked session

### ⚙️ Miscellaneous Tasks

- Rspec automated test script for pr workflow

## [0.8.0] - 2025-08-01

### 🚀 Features

- *(UX)* Add a spinner to certain prompt messages
- Prompt user to start another session
- Replace hardcoded version with variable
- Add underlying code to support endgame msg
- Add the support to output endgame condition
- Ability to print various endgame messages
- *(UX)* Add warning message during promotion
- *(UX)* Improve message clarity
- Integrate new message to game flow
- Add a filter option to #to_alg_pos
- Add support to convert promo move to PGN
- Add support to convert castling move to PGN
- Update data structure to support PGN export
- Add the ability to save PGN moves
- Add support to append + & # marker to PGN
- Add support to export session as .pgn file

### 🐛 Bug Fixes

- Address a crash during load session flow

### 🚜 Refactor

- Decouple Chess game from GameManager
- Move #shut_down_msg back to manager
- Centralise print responsibility
- Optimise king castling method
- Move #draw logic to endgame_logic
- Create SessionUtils module for Chess
- Optimise chess session setup process
- Change PieceLookup from module to class
- Mini optimisation when using PieceLookup
- Move simulation logic to a service class
- Decouple PieceAnalysis from Level class
- Decouple endgame logic from Level class
- Make use of delegators in EndgameLogic
- Revert previous change in EndgameLogic
- Decouple fen_export from Level
- Move shared logics to ChessUtils module
- Decouple Logic from Level class
- Optimise core game loop
- Extract player action as a method
- Convert FenImport to a service class
- Decouple FenImport from Level
- Optimise Level class
- Optimise metadata workflow
- Optimise player class creation workflow
- Optimise chess Game class
- Extract session creation as a service
- Optimise PieceLookup class
- Change output value of #regexp_algebraic
- Optimise Time object usage

### 📚 Documentation

- Update CHANGELOG
- Update README

### 🎨 Styling

- Update EndgameLogic pattern signature
- Update Level class layout
- Streamline pieces initialization

### 🧪 Testing

- Test cases for Game class and SessionUtils
- Add integration test suite for GameManager
- New test cases for error handling on load
- Update fen_export test cases

### ⚙️ Miscellaneous Tasks

- Update Gemfile requirements
- Update gemfile
- Update gemfile
- Cleanup chess_input_spec file
- Update test workflow file
- Merge branch 'main'
- Docstring tidying
- Move player classes to player folder

## [0.7.0] - 2025-07-24

### 🚀 Features

- Add support for input hot swapping
- Add support to count fullmove and store turn
- *(tf)* Add chess help text to textfile
- *(tf)* Add new game strings to textfile
- Add safe exit when yaml file is corrupted
- *(tf)* Add new game level strings to textfile
- Replace string in menu with textfile strings
- Replace texts in GameManager with TF data
- *(UX)* Swap board setting strings with TF data
- *(UX)* Improve intro flow sequence
- *(UX)* Add new command string to chess input
- Ability to load another session mid-game
- *(UX)* Replace hardcoded game messages
- Add #print_turn to Board class
- *(UX)* Replace hardcoded strings in Level

### 🐛 Bug Fixes

- Address a regexp pattern issue in #pick_from
- Resolve a bug when validating checkmate
- Address a visual bug in preview mode
- Address a visual bug when using preview mode

### 💼 Other

- Check detection by simulating next move

### 🚜 Refactor

- Optimise #write_to_disk
- Add an option to not print the board
- Optimise Level initialization flow
- Optimise various methods in Level class
- Optimise various methods in Chess
- Restore methods for clarity
- Optimise FenExport
- Simplify method definitions
- Optimise #add_pos_to_blunder_tracker
- Optimise #add_pos_to_blunder_tracker pt2
- Optimise Level refresh call from 4 to 2
- Update methods scope settings
- Optimise nimbus_file_utils module
- Optimise chess Level fetch methods
- Change #print_msg behavior to return nil
- Update scope for #update_board_state
- Move simulations out from King class
- Move simulation logic to piece_analysis
- Migrate lookup logics to PieceLookup

### 📚 Documentation

- Update CHANGELOG
- Add Action badge to README

### 🧪 Testing

- Integration test via EndgameLogic module
- Migrate file_utils tests from past project
- Update dummy_user.json with new data format
- Add test suite for Display module
- Add test suite for ChessInput class
- Add more test cases for ChessInput class
- Add integration test suite for Level class
- En passant and promotion integration test
- Kingside/Queenside castling integration tests
- ComputerPlayer & commands integration test
- Add automated test script to Actions
- Update test case for nimbus_file_utils_spec
- Update rspec_full_track.yml

### ⚙️ Miscellaneous Tasks

- Move various logic modules to logics folder
- Cleanup unused gem dependency from project
- Add debug assets for automated test cases
- Update rspec_full_track.yml

## [0.6.0] - 2025-07-19

### 🚀 Features

- Add #build_table to Console module
- Add logics to display loadable sessions
- Add logic to check for Stalemate
- Add logic to check for insufficient material
- Add logic to check for fifty-move rule
- Add logic to check #threefold_repetition?
- Add the ability to play with computer player
- Add support to load Player vs AI sessions

### 🐛 Bug Fixes

- Address an issue when user load a chess game
- Add a new flow to prevent a load game crash
- #insufficient_material validation logics
- Resolve an issue in insufficient material flow
- Address a crash bug during move preview
- Address an issue during FEN export
- Resolve a bug during checkmate detection

### 🚜 Refactor

- Move draw logics to EndgameLogic
- Optmise #insufficient_material flow
- Move movement specific logics to Logic
- Optimise Level class
- Optimise methods in Level class
- Optimise #alg_map
- Optimise Level save flow

### 📚 Documentation

- Update CHANGELOG

### 🧪 Testing

- Add test cases for #all_paths
- Add test cases for #path

## [0.5.0] - 2025-07-16

### 🚀 Features

- Add #parse_active_color
- Add #parse_en_passant and test cases
- Add #parse_move_number and test cases
- Add all import logics to parse FEN string
- Integrate new data structure to Level
- Add logic to correctly process en passant
- Add logic to store last move
- Add #convert_turn_data to convert game data
- Add support for FEN export
- Add the ability to generate FEN string
- Add logic to support autosaving
- Add core logic to support load game

### 🐛 Bug Fixes

- Address a load order issue
- Resolve an issue when checking castling status
- Resolve an issue with Rook's movement
- Resolve a highlighting bug during promotion
- Address a bug occurred when King is checked

### 🚜 Refactor

- Move chess display logic to board class
- Move analysis logic to a module
- Optimise #fetch_all and #fetch_piece
- Move player's actions to Player class
- Move more player actions logic to Player
- Further remove logics from Level.rb
- Move FEN related logics to a new module
- Optimise #normalise_fen_rank
- Optimise #turn_data
- Update #fen_error to use a fallback value
- Remove unnecessary reference for Players
- Optimise #convert_turn_data
- Optimise FenUtils module
- Split FenUtils to Fen import and export

### 📚 Documentation

- Update CHANGELOG

### 🧪 Testing

- Update test suites for logic module
- Add test cases SmithNotation module
- Add test cases for AlgebraicNotation module
- Add test cases for #parse_castling
- Add more test cases for algebraic module
- Add test cases for #piece_maker
- Add test cases for #to_turn_data

### ⚙️ Miscellaneous Tasks

- Update PGN utilities location

## [0.4.0] - 2025-07-13

### 🚀 Features

- Add the ability to display possible moves
- Add chess game loop POC
- Add algebraic pattern to ChessInput class
- Add #regexp_algebraic to build input pattern
- Add the ability to play with Smith notation
- Add the ability to flip the board
- Add the ability to promote pawn via input
- Add new command pattern board
- Add the ability to promote pawn via Smith
- Add parsing methods for algebraic notation
- Add the ability to use with algebraic input

### 🐛 Bug Fixes

- Address an issue where icons are not loading
- Address a rendering issue when board is large

### 🚜 Refactor

- #prompt_user to have finer control
- Organise level.rb
- Optimise #turn_action method call
- Move Smith notation logics to a module
- Move algebraic logic to a module
- Optimise core game loop
- Rewrite logical flow for algebraic

### 📚 Documentation

- Update CHANGELOG

### 🎨 Styling

- Improve variable names for clarity

### ⚙️ Miscellaneous Tasks

- Organise project file structure

## [0.3.0] - 2025-07-08

### 🚀 Features

- Add logic to flip the board (a-h, h-a)
- Setup class files for various pieces
- Add init values to chess pieces
- Add logic to calculate valid movements
- Add movement logic for Knight
- Add logic to calculate all pieces movements
- Add algebraic notation generator
- Integrate algebraic map into chess piece
- Add coloring to chess pieces
- Add the ability parse FEN and print board
- Add Level class to handle core game loop
- Add utility methods #to_1d & #to_matrix
- Add the ability to move K, Q, B, R & P
- Add logic to store capture positions
- Add Pawn double move and capturing logics
- Add the ability check pawn's position
- Add the ability to promote pawn
- Add logics to perform En passant
- Add en passant reset when move is not used
- Add the ability to generate all valid moves
- Add the ability to calculate blunders
- Improve checkmate logic
- Further improve checkmate logic
- Add all logic needed for detecting checkmate
- Add the ability to limit piece selections
- Add logic to support castling

### 🐛 Bug Fixes

- Address a crash related to filename creation
- Resolve an issue found in targets variable

### 💼 Other

- Create LICENSE

### 🚜 Refactor

- Optimise #build_board
- Cleanup and remove magic numbers
- Modify #build_board output value
- Optimise #not_adjacent?
- Rename #movements to #explore_path
- Optimise #to_turn_data
- Optimise how pieces reference level obj
- Optimise En passant logics
- Move checkmate logic to King class
- Optimise King and ChessPiece class

### 📚 Documentation

- Update CHANGELOG
- Update docstring

### 🧪 Testing

- Add test cases for Chess logic
- Update test cases for chess logic
- Update logic test cases to test new feature
- Add new test case for chess logic

### ⚙️ Miscellaneous Tasks

- Rename class for extra clarity
- Migrate reusable logics from past project
- Update Gemfile and README

## [0.2.0] - 2025-06-30

### 🚀 Features

- #load_profile now display a list of profiles
- Add the ability to handle --save & --load
- Add support for command --self
- Add the ability to use the --play command
- Add new base class: Input
- Integrate Input to GameManager
- Add subclass ChessInput
- Add #regexp_range to handle range prompts
- Add override #handle_input to input control
- Add #game_selection to Chess class
- Add ChessComputer subclass
- Add ChessPlayer subclass
- Add logic for #new_game
- Add workflow to create play session
- Add the ability to store multiple sessions
- Add display.rb and logic.rb to chess
- Add the ability to colour each cell
- Add the ability to change side decorator
- Add #build_board and #frame to display
- Add the ability to change the board size
- *(tf)* Update textfile

### 🐛 Bug Fixes

- Improves #regexp_range to support multi digit
- Resolve a crash issue during load profiles
- Resolve a crash when user_data is empty
- Correct ranks display order

### 🚜 Refactor

- Optimise multiple methods in file_utils
- Optimise #write_to_disk
- Optimise #load_profile
- Optimise #setup_commands in console_menu
- Optimise #regexp_range
- Decouple file_utils usage from console
- Change the scope of #print_file_list
- Add #print_msg to support multiline
- Improves #prompt_user internal logics
- Extract logic from #select_profile
- #pick_from returns value instead of idx
- Improve prompt flow in chess
- Update #edit_name logic
- #create_profile to use default hash
- #init_data to use default hash
- Restructure Chess module
- Update require paths for Console module
- Update #format_row to take hash and arr
- Update variable names in display
- Optimise #build_board

### 📚 Documentation

- Update docstring

### 🎨 Styling

- Rename #handle_input to #ask
- Improves #prompt_user message styling
- Add better warning message to #pick_from
- Migrate from colorize to paint in Player

### ⚙️ Miscellaneous Tasks

- Create CHANGELOG.md for v0.1.0
- Reorganise files by namespace
- Add cliff.toml
- Move ChessComputer to console_game
- Add new gem: simplecov

## [0.1.0] - 2025-06-24

### 🚀 Features

- Add new strings for console interface
- *(tf)* Add chess board design
- *(tf)* Update chess board design
- *(tf)* Update chessboard design
- *(tf)* Breakdown board design as parts
- *(tf)* Add splash screen and intro message
- *(tf)* Add help strings
- *(tf)* Add new menu strings
- Adapt console, game manager and FileUtils
- Add user_profile class
- Add pgn_utils to handle chess data
- Add #parse_pgn and #parse_pgn_metadata
- Add #parse_pgn_moves to parse imported moves
- Match import and export data structure
- Add #write_to_disk method
- Add new console command patterns to console_menu
- Add helper method #regexp_capturing_gp
- Add sequence to get username
- Add the ability to save profile to disk
- Add the ability to load profile from disk

### 🐛 Bug Fixes

- An issue where regexp is blocking commands
- Improves #handle_input input handling
- #handle_command when kernel #exit called

### 💼 Other

- File_utils and pgn_utils integration test

### 🚜 Refactor

- #format_metadata to handle various types
- #parse_pgn_metadata date handling
- Update local variable name in #load_file
- Move ConsoleMenu class to dedicated file
- Update internal variable name
- #command? to accept more flags types
- #command? to use a safer loop pattern
- Decouple methods from ConsoleMenu

### 📚 Documentation

- Update README.md
- Update README.md

### 🧪 Testing

- Create test cases for pgn_utils
- Add new test cases to pgn_utils
- Add tests for pgn_utils
- Update test cases in pgn_utils_spec
- The serialisation format in yaml and json
- The serialisation format in yaml and json

### ⚙️ Miscellaneous Tasks

- Initial commit
- Setting up project environment
- Add Simple Todo to issue templates
- Merge branch 'main'
- Migrate scripts from connect-four project

<!-- generated by git-cliff -->
