# frozen_string_literal: true

require_relative "chess_player"

module ConsoleGame
  module Chess
    # Chess computer player class
    class ChessComputer < ChessPlayer
      def initialize(name = "", controller = nil, color = nil)
        super
      end

      private

      # Process player action
      # Computer player's move
      def player_action
        selection = level.usable_pieces[side].sample

        assign_piece(selection)
        target = piece_at_hand.possible_moves.to_a.sample

        move_piece(target)
      end
    end
  end
end
