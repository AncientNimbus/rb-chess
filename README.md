# ♟️Ruby Chess 

[![Rspec Test Fulltrack](https://github.com/AncientNimbus/rb-chess/actions/workflows/rspec_full_track.yml/badge.svg)](https://ancientnimbus.github.io/rb-chess/coverage/#_AllFiles)
![Status](https://img.shields.io/badge/Status-In_Development-cccc00)


Welcome to the Chess project repo, it is my implementation of a terminal based Chess game written in Ruby, with user experience set as the primary focus.

---

# Introduction

> [!NOTE]
>
> Main branch version: `v0.9.0`
>
> Development Stage: `Complete (Pre-release)`
>
> This version includes most of the features I planned for this project and it is now fully playable and ready for play-testing. Checkout **Getting Started** and **How to play** sections for guidance.
>
> There are a couple more user refinements I wish to add, but I am pretty happy with the current outcome.
>
> While all the core logics have been tested, you are likely to come across some bugs and issues. Shall you encounter any problems or have any questions about the project, please feel free to open an issue. 
>
> All feedbacks are welcomed and appreciated.

## Motivations

In this chess project, my primary goals are to validate my working knowledge in Ruby, effective use of OOP, system design, and refine my software development workflow such as project management & scope estimations.

This project is also presented as my final learning outcome for the Ruby course in the Full Stack Ruby on Rails path developed by [The Odin Project](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby).

I had a lot of fun working on this project, and discovered many new things about Ruby. While the journey is far from over, completing this project is a major milestone to cross.

Without further ado, read on below to learn more about my chess project.

## Core User Features

Complete Chess Experience

- Legal moves only
- Pawn specific: En passant and Promotion
- King specific: Castling
- Check and Checkmate detection
- Draw detection based on the following rules:
  - Stalemate
  - Fifty-move rule
  - Threefold repetition
  - Insufficient Material

Game modes 

1. Player vs. Player (PvP) - Locally play with two players

2. Player vs. Computer (PvE) - Difficulty: Easy

Session load options

1. New Game
2. Load Game
3. Import Game via [FEN record](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation)

Save & Resume

- Session is automatically save at the end of each turn
- Load and resume any session without having to restart the program

Input modes

- **Smith Notation** (Default): Coordinate-based system (`e2e3` to move directly or enter `e2` to preview, enter `e4` to complete the move)

- **Algebraic Notation**: The official standard for chess notation (`e4`, `Nc3`, `bxc8=Q`)

Export capabilities

- View the FEN record of the current turn via the `--info` command
- Export your session as a `.pgn` file and import it to your preferred online chess engine

## Quality of Life improvements

User Profile Management

- A mini console system - **Ruby Arcade** is purpose built for this project to offer support for multiple user profiles

Input hot-swapping 

- Notation input preference is interchangeable throughout the program

Session hot-swapping 

- Load or start a new chess without having to restart the program

Chessboard customisations

- Two chessboard sizes can be swap via the `--board size` command
- Chessboard flip settings can be enabled/disabled via the `--board flip` command

Contextual highlights

- Meaningful text highlights are used throughout the program to act as an aid

# Getting Started

Follow the simple steps below to get started:

1. Ensure that Ruby `3.4.x` and Bundler are correctly installed on your device (This project is developed using Ruby version `3.4.2`)
2. Clone the repo or download the project from Releases `v0.9.x` 
3. In your terminal, open the directory:

  ```
  cd rb-chess/
  ```
4. Installed the required Gems:
  ```
  bundle install
  ```
5. You are ready to launch the program:
  ```
  bundle exec ruby main.rb
  ```


# How to play

> [!TIP]
> Instructions can be found throughout the program via the command `--help`, more detailed introductions will be added here shortly.


# Technical Specifications

**Project Scope for v1.0.0**
- Terminal based
- Game mode 1: Local Player vs Player
- Game mode 2: Local Player vs AI (Difficulty: Basic)

**Technical Documentations can be found below:**

**Test**

|      |      |
| ---- | ---- |
|      |      |
|      |      |
|      |      |

- [Codebase documentation](https://ancientnimbus.github.io/rb-chess/doc/)
- [Code coverage report](https://ancientnimbus.github.io/rb-chess/coverage/#_AllFiles)

For more details regarding the development of this project, feel free to checkout the [Wiki](https://github.com/AncientNimbus/rb-chess/wiki) page.

## Gems used

- [Paint](https://github.com/janlelis/paint)
- [Whirly](https://github.com/janlelis/whirly)
- [RSpec](https://rspec.info/)
- [Rubocop](https://rubocop.org/)
- [Yard](https://yardoc.org/)
- [SimpleCov](https://github.com/simplecov-ruby/simplecov)

## Additional Resources

The chessboard design is published as a [gist](https://gist.github.com/AncientNimbus/c85f5a4289f95e1fd6fc27a7a93be310), feel free to adapt it to your own project.

---

