# Changelog

All notable changes to this project will be documented in this file.

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
- Add the ability to use algebraic input

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
