# ♟️Ruby Chess 

[![Gem Version](https://badge.fury.io/rb/chess_cli.svg)](https://badge.fury.io/rb/chess_cli)
[![Rspec Test Fulltrack](https://github.com/AncientNimbus/rb-chess/actions/workflows/rspec_full_track.yml/badge.svg)](https://ancientnimbus.github.io/rb-chess/coverage/#_AllFiles)
![Status](https://img.shields.io/badge/Status-Pre_Release-2db84d)

<p align="center">
<img width="746" height="400" alt="chess-boot-screen" src="https://github.com/user-attachments/assets/c7e7e032-aaa7-4f91-9657-e98558ab736d" />
</p>


Welcome to the Chess project repo, it is my implementation of a terminal based [Chess](https://www.instructables.com/Playing-Chess/) game written in Ruby, with user experience set as the primary focus.

---


# Introduction

> [!NOTE]
>
> Main branch version: `v0.9.2`
>
> Release branch version: `v0.9.2`
>
> This version includes most of the features I planned for this project and it is now fully playable and ready for play-testing. Checkout **Getting Started** and **How to play** sections for guidance.
>
> There are a couple more user refinements I wish to add, but I am pretty happy with the current outcome.
>
> While all the core logics have been tested, you are likely to come across bugs and issues. Shall you encounter any problems or have any questions about the project, please feel free to open an issue. 
>
> All feedback is welcome and appreciated.

[Gameplay footage for v0.9.0](https://www.youtube.com/shorts/7rKmVUZ2Aq4)
<details>
  <summary><b>Gamplay Preview - v0.9.0 (Spoiler)</b></summary>

**A classic fool's mate** (Terminal: Warp)
<p align="center">
<img width="746" height="559" alt="fools-mate" src="https://github.com/user-attachments/assets/4f8c3cd3-7a97-4ad7-b819-932b0d15cdec" />
</p>

**Legal's mate is another classic** (Terminal: iTerm)
<p align="center">
<img width="746" height="820" alt="legals-mate" src="https://github.com/user-attachments/assets/ded67f03-e062-4942-96ac-ad7fcbd9e208" />
</p>


</details>

## Motivations

In this chess project, my primary goals are to validate my working knowledge in Ruby, effective use of OOP, system design, and refine my software development workflow such as project management & scope estimations.

This project is also presented as my final learning outcome for the Ruby course in the Full Stack Ruby on Rails path developed by [The Odin Project](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby).

I had a lot of fun working on this project, and have discovered many new things about Ruby. While the journey is far from over, completing this project is a major milestone to cross.

Without further ado, read on below to learn more about my chess project.

## Core User Features

**Complete Chess Experience**

- Legal moves only
- Pawn specific: En passant and Promotion
- King specific: Castling
- Check and Checkmate detection
- Draw detection based on the following rules:
  - Stalemate
  - Fifty-move rule
  - Threefold repetition
  - Insufficient Material

**Game mode options** 

1. Player vs. Player (PvP) - Locally play with two players
2. Player vs. Computer (PvE) - Difficulty: Easy

**Session load options**

1. New Game
2. Load Game
3. Import Game via [FEN record](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation)

**Save & Resume**

- Session is automatically saved at the end of each turn
- Load and resume any session without having to restart the program

**Input mode options**

- [**Smith Notation**](https://en.wikipedia.org/wiki/Chess_notation#Notation_systems) (Default) - Coordinate-based system (`e2e3` to move directly or enter `e2` to preview, enter `e4` to complete the move)

- [**Algebraic Notation**](https://www.chessable.com/blog/chess-notation-for-beginners/) - The official standard for chess notation (`e4`, `Nc3`, `bxc8=Q`)

**Export capabilities**

- View the FEN record of the current turn via the `--info` command
- [PGN Export](https://en.wikipedia.org/wiki/Portable_Game_Notation) - Save your session as a `.pgn` file and import it to your preferred online [chess engine](https://lichess.org/paste)

## Quality of Life Improvements

**User Profile Management**

- A mini console system - **Ruby Arcade** is purpose built for this project to offer support for multiple user profiles

**Preview mode on Smith Notation**

In addition to direct move such as `e2e4`, this input mode also supports a preview feature where players have the ability see all the possible movements of a given chess piece.

To use it, select a chess piece such as `e2` and hit enter, the board will display all movements with distinctive highlights. In the following prompt, confirm your move such as `e4` to complete your turn.

Note: This mode respects the [Touch-move](https://en.wikipedia.org/wiki/Touch-move_rule) rule, meaning once a chess piece is selected, you must play it this turn.

**Input hot-swapping** 

- Notation input preference is interchangeable throughout the program

**Session hot-swapping** 

- Load or start a new chess without having to restart the program

**Chessboard customisations**

- Two chessboard sizes can be swap via the `--board size` command
- Chessboard flip settings can be enabled/disabled via the `--board flip` command
- The default chessboard design is inspired by [Lichess.org](https://lichess.org/)

**Contextual highlights**

- Meaningful text highlights are used throughout the program to act as a visual aid
- The input prompt prefix is inspired by [GitHub CLI](https://cli.github.com/)

# Getting Started

Follow the simple steps below to get started:

Ensure that Ruby `3.4.x` and Bundler are correctly installed on your device (This project is developed using Ruby version `3.4.2`)

### Recommended: Install via RubyGems.org

1. Install the gem to your local environment:

```
gem install chess_cli
```

2. Run the game!

```
chess_cli
```

3. To uninstall the game:

```
gem uninstall chess_cli
```

<details>
  <summary><h3>Alternatively: Build From Source Code</h3></summary>
  
### Build From Source Code

1. Clone the repo or download the project from Releases `v0.9.x` 

2. In your terminal, open the directory:

  ```
  cd rb-chess/
  ```
4. Build the gem locally:
  ```
  gem build chess_cli.gemspec
  ```
5. Install the gem to your local environment:
  ```
  gem install chess_cli
  ```

6. Run the game!

```
chess_cli
```

7. To uninstall the game:

```
gem uninstall chess_cli
```
</details>

# How to Play

> [!TIP]
> Instructions can be found throughout the program via the command `--help`.
>
> You can exit the program at any point via the `--exit` command.
>
> The command system is context aware, so its usage availability depends on the location you are at.

See the example below on how to launch chess as a new player:

<details>
  <summary><b>Stage 1: Welcome to Ruby Arcade</b></summary>

1. A boot screen is printed, adjust your terminal window size if needed (Recommended size: `80x35`)
2. You will be prompted to create or load a user profile
   - Enter `1` to create a new profile
4. Give your profile a username such as `Ruby Chess Tester`
5. Your profile will be created automatically and can be found at the `/rb-chess/user_data/` directory.
6. You have successfully entered the lobby, enter `--help` to see a list of commands.
</details>

<details>
  <summary><b>Stage 2: Launching Chess</b></summary>

1. To launch chess, simply type the following:

```
--play chess
```

2. A boot screen is printed, the instructions shall hopefully get you orientated with the program easier.
3. You will be prompted to select a load mode
   - Enter `1` to create a new game
4. You will be prompted to select a game mode
   - Enter `1` to play locally with a friend (or by yourself) or `2` to play with a computer player
   - In this example, I will enter `1` to create a Player vs. Player session
5. You will be given the option to rename both players (mode 1 only), you can skip this by pressing enter.
6. Next, indicate which side would you like to play.
   - Enter `1` to play as White
7. You have successfully created a Player vs. Player chess session
</details>

<details>
  <summary><b>Stage 3a: Play a turn using Smith Notation</b></summary>



Note: This game opted to use Smith notation as a default input option as it has a simpler learning curve.

1. Type the `--help smith` command will print a simple user guide while in-game

**Direct move**

- To select a piece and move with a single prompt:

```
e2e4
```

Promote a pawn

- To promote a pawn to a queen and move with a single prompt:

```
e7e8q
```

**Preview then move**

- To use preview mode, first select a piece:

```
e2
```

- After previewing, enter the desire location to move:

```
e4
```

Promote a pawn

- To promote a pawn to a bishop, first select a pawn at h7:

```
h7
```

- After previewing, enter the desire location to move:

```
h8
```

- You will be prompted to promote the pawn, in this case b is entered to represent bishop:

```
b
```

</details>

<details>
  <summary><b>Stage 3b: Play a turn using Algebraic Notation</b></summary>



Note: Preview mode is not available for Algebraic notation due to usage consideration.

1. To use Algebraic Notation as an input option. First type the `--alg` command and press enter to confirm the selection

2. Type the `--help alg` command will print a simple user guide while in-game

**Move a chess piece**

- Move a pawn to e4

```
e4
```

- Move a queen to a1

```
Qa1
```

**Capture a chess piece**

- Pawn captures e4 from d file

```
dxe4
```

- Bishop captures c5 from f file

```
Bxc5 / Bfxc5
```

**Castling**

- Kingside castling

```
O-O
```

- Queenside castling

```
O-O-O
```

**Promote a pawn**

- Move and promote to a queen

```
e8=Q
```

- Capture and promote to a rook

```
bxc1=R
```

- In the event where you have forgotten to enter promote option, an additional prompt will appear as fallback

```
# First prompt (Move pawn to c8)
c8
# Second prompt (Promote to queen)
q
```

</details>

<details>
  <summary><b>Stage 4: Using commands in Chess</b></summary>
Note: As a reminder, `--help` will display all available commands for chess.

- Print session details and FEN record for the current turn:

```
--info
```

- Load or create another session in game:

```
--load
```

- Toggle between standard or large chessboard:

```
--board size
```

- Toggle chessboard flip settings (when play as black the board file index starts from h to a):

```
--board flip
```

- Export current session as a `.pgn` file
- The exported file can be found at the `/rb-chess/user_data/pgn_export/` directory.

```
--export
```
</details>

# Technical Details 

## **Project Scope for v1.0.0**

- [x] Terminal based
- [x] Colourful chessboard within unicode and terminal environment constrains 
- [x] Full Chess rules
- [x] Game mode 1: Local Player vs Player
- [x] Game mode 2: Local Player vs AI (Difficulty: Easy)
- [x] Flexible yet butterfingers-proof user input system
- [x] Persistence data serialisation 
- [x] FEN I/O
- [x] Turn-based FEN Generation
- [x] PGN Export
- [x] Implement command pattern interface

## Stretch goals

- [ ] Adjust computer’s response rate
- [ ] Custom board theme

## Known Issues

> [!WARNING]
> Below are a list of of known issues found during testing
>
> 1. PGN export might not include the last move if it is made by White
> 2. FEN import will reset the full move counter, this is a minor issue as it won’t affect the actual gameplay
>

## Data Serialisation

I would like to briefly highlight some of the key characteristics of the user serialisation structure for this project. The core objectives are to preserve game state optimally, provide multi-sessions and multi-user support.

When designing the data structure for the chess game, I referenced the metadata field used by PGN as a starting point, this ensures that it is compliance from the start and allow easy data conversion. As the development progresses, I realised that it is easier to rebuild game state using FEN data string, hence `fens` field is added to the serialisation structure.

Since all the data related to chess is grouped under the `chess` field, this user profile should be robust enough to handle other games or services without corrupting chess specific data. 

Lastly, all data values are saved with primitive types to ensure maximum compatibly across different platforms. Therefore, it is language agnostic.

<details>
  <summary><b>Click to see a sample of an user profile</b></summary>

```json
{
  "uuid": "bdfe89d5-d9eb-4397-b203-5f1a7eccd639",
  "username": "Nimbus",
  "saved_date": "2025-08-05 16:55:53 +0100",
  "appdata": {
    "chess": {
      "1": {
        "event": "Nimbus vs Spock Status Checkmate",
        "site": "Ruby Arcade Terminal Chess by Ancient Nimbus",
        "date": "08/05/2025 04:55 PM",
        "round": null,
        "white": "Nimbus",
        "black": "Spock",
        "result": null,
        "mode": 1,
        "moves": {
          "1": ["f4", "e5"],
          "2": ["g4", "Qh4#"]
        },
        "white_moves": ["f4", "g4"],
        "black_moves": ["e5", "Qh4"],
        "fens": [
          "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
          "rnbqkbnr/pppppppp/8/8/5P2/8/PPPPP1PP/RNBQKBNR b KQkq - 0 1",
          "rnbqkbnr/pppp1ppp/8/4p3/5P2/8/PPPPP1PP/RNBQKBNR w KQkq - 0 2",
          "rnbqkbnr/pppp1ppp/8/4p3/5PP1/8/PPPPP2P/RNBQKBNR b KQkq - 0 2",
          "rnb1kbnr/pppp1ppp/8/4p3/5PPq/8/PPPPP2P/RNBQKBNR w KQkq - 1 3"
        ]
      }
    }
  },
  "stats": {
    "launch_count": 1
  }
}
```
</details>





## Technical Documentations

**Test Coverage Summary**

| Metric                         | Value               |
| ------------------------------ | ------------------- |
| Test Suites                    | 17                  |
| Test cases                     | 338                 |
| Chess related scripts coverage | 100%                |
| Overall coverage               | 99.01%              |
| Lines covered (Libs + Chess)   | 1711 (Total: ≈1750) |
| Avg. Hits per line             | 2335.8              |
|                                |                     |

- [Codebase documentation](https://ancientnimbus.github.io/rb-chess/doc/)
- [Code coverage report](https://ancientnimbus.github.io/rb-chess/coverage/#_AllFiles)

For more details regarding the development of this project, feel free to checkout the [Wiki](https://github.com/AncientNimbus/rb-chess/wiki) page (New article coming soon).

## Gems Used

- [Paint](https://github.com/janlelis/paint)
- [Whirly](https://github.com/janlelis/whirly)
- [RSpec](https://rspec.info/)
- [Rubocop](https://rubocop.org/)
- [Yard](https://yardoc.org/)
- [SimpleCov](https://github.com/simplecov-ruby/simplecov)

## Additional Resources

The chessboard design is published as a [gist](https://gist.github.com/AncientNimbus/c85f5a4289f95e1fd6fc27a7a93be310), feel free to adapt it to your own project.

---

